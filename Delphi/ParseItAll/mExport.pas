unit mExport;

interface

uses
  API_MVC_DB,
  API_Yandex,
  eLevel,
  eRule,
  eLink;

type
  TModelExport = class(TModelDB)
  private
    FFileName: string;

    FTranslater: TYaTranslater;

    function GetRuleKeysFromLevel(aLevel: TJobLevel): TArray<string>;
    function GetKeysFromRule(aRule: TJobRule): TArray<string>;
    procedure GetLinkslist(aJobID: Integer; aKeys: TArray<string>);
    procedure ProcessLinkResults(aLinkID: Integer; aKeys:TArray<string>);
    procedure AddToCSVString(var aString: string; aValue: string);
    procedure AddToValueString(var aString: string; aValue: string);
    procedure WriteToFile(aString: string);

    procedure TryGetTranslate(var aValueStrings: string; aKey: string; aLink: TLink);
  published
    procedure ExportToCSV;
  end;

implementation

uses
  System.SysUtils,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  API_Files,
  eJob,
  eRecord;

procedure TModelExport.TryGetTranslate(var aValueStrings: string; aKey: string; aLink: TLink);
var
  ruKey, ruValue: string;
  Lang: string;
  Rec: TRecord;
begin
  if aValueStrings <> '' then Exit;

  if aKey = 'en_title' then ruKey := 'ru_title';
  if aKey = 'en_content' then ruKey := 'ru_content';
  if aKey = 'en_country' then ruKey := 'ru_country';
  if aKey = 'en_address' then ruKey := 'ru_address';

  if aKey = 'ua_title' then ruKey := 'ru_title';
  if aKey = 'ua_content' then ruKey := 'ru_content';
  if aKey = 'ua_country' then ruKey := 'ru_country';
  if aKey = 'ua_address' then ruKey := 'ru_address';

  if ruKey = '' then Exit;

  for Rec in aLink.GetRecordsByKey(ruKey) do
    begin
      ruValue := Rec.Value;
      Break;
    end;

  if aKey.Contains('en_') then Lang := 'en';
  if aKey.Contains('ua_') then Lang := 'uk';

  if ruValue <> '' then
    try
      aValueStrings := FTranslater.Translate(Lang, ruValue);
    except

    end;
end;

procedure TModelExport.AddToValueString(var aString: string; aValue: string);
begin
  if aString <> '' then
    aString := aString + #13#10 + aValue
  else
    aString := aValue;
end;

procedure TModelExport.AddToCSVString(var aString: string; aValue: string);
begin
  if aString <> '' then
    aString := aString + ';';

  aValue := StringReplace(aValue, '"', #39, [rfReplaceAll, rfIgnoreCase]);
  aString := aString + '"' + aValue + '"';
end;

procedure TModelExport.WriteToFile(aString: string);
begin
  TFilesEngine.AppendToFile(FFileName, aString);
end;

procedure TModelExport.ProcessLinkResults(aLinkID: Integer; aKeys:TArray<string>);
var
  Link: TLink;
  Key, Value: string;
  CSVString, ValueStrings: string;
  RecList: TObjectList<TRecord>;
  Rec: TRecord;
begin
  Link := TLink.Create(FDBEngine, aLinkID);
  try
    CSVString := '';

    for Key in aKeys do
      begin
        if Key = 'ctime'
        then
          ValueStrings := DateTimeToStr(Link.HandleTime)
        else
        if Key = 'ru_source' then
          ValueStrings := Link.Link
        else
        if Key = 'en_source' then
          ValueStrings := Link.Link
        else
        if Key = 'ua_source' then
          ValueStrings := Link.Link
        else
          begin
            RecList := Link.GetRecordsByKey(Key);
            try
              ValueStrings := '';
              for Rec in RecList do
                begin
                  AddToValueString(ValueStrings, Rec.Value);
                  break;
                end;
            finally
              RecList.Free;
            end;
          end;

        // translate
        TryGetTranslate(ValueStrings, Key, Link);

        AddToCSVString(CSVString, ValueStrings);
      end;

    WriteToFile(CSVString);
  finally
    FreeAndNil(Link);
  end;
end;

procedure TModelExport.GetLinkslist(aJobID: Integer; aKeys: TArray<string>);
var
  dsQuery: TFDQuery;
begin
  dsQuery := TFDQuery.Create(nil);
  try
    dsQuery.SQL.Text :=
      'select l.Id ' +
      'from links l ' +
      'join link2link l2l on l2l.child_link_id = l.id ' +
      'where not exists (select Id from link2link l2l where l2l.parent_link_id = l.Id) ' +
      'and exists (select Id from records r where r.link_id = l.Id) ' +
      'and l.job_id = :JobID ' +
      'group by l2l.parent_link_id '+
    //  'order by l.id';
      'order by l.handle_time, level';

    dsQuery.ParamByName('JobID').AsInteger := aJobID;
    FDBEngine.OpenQuery(dsQuery, False);

    while not dsQuery.EOF do
      begin
        ProcessLinkResults(dsQuery.FieldByName('Id').AsInteger, aKeys);
        dsQuery.Next;
      end;
  finally
    dsQuery.Free;
  end;
end;

function TModelExport.GetKeysFromRule(aRule: TJobRule): TArray<string>;
var
  RuleRuleRel: TRuleRuleRel;
begin
  Result := [];

  if aRule.Rec <> nil then
    Result := Result + [aRule.Rec.Key];

  for RuleRuleRel in aRule.ChildRuleRels do
    Result := Result + GetKeysFromRule(RuleRuleRel.ChildRule);
end;

function TModelExport.GetRuleKeysFromLevel(aLevel: TJobLevel): TArray<string>;
//var
  //LevelRuleRel: TLevelRuleRel;
begin
  Result := [];

  //for LevelRuleRel in aLevel.RuleRels do
  //  Result := Result + GetKeysFromRule(LevelRuleRel.Rule);
end;

procedure TModelExport.ExportToCSV;
var
  i: Integer;
  Job: TJob;
  Level: TJobLevel;
  Keys: TArray<string>;
  Key: string;
  CSVString: string;
begin
  Job := (FObjData.Items['Job'] as TJob);

  Keys := ['ctime'];
  for i := 0 to Job.Levels.Count - 1 do
    begin
      Level := Job.Levels[i];
      Keys := Keys + GetRuleKeysFromLevel(Level);
    end;
  Keys := Keys + ['ru_source', 'en_source', 'ua_source'];

  // create file
  FFileName := GetCurrentDir + '\Export\' +Job.ID.ToString + '_' + IntToStr(Trunc(Now))+'.csv';
  TFilesEngine.CreateFile(FFileName);

  // header
  CSVString := '';
  for Key in Keys do
    AddToCSVString(CSVString, Key);
  WriteToFile(CSVString);

  // traslater
  FTranslater := TYaTranslater.Create;

  GetLinkslist(Job.ID, Keys);
end;

end.
