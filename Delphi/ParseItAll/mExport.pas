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

    FRuTitle: string;
    FEnTitle: string;
    FUaTitle: string;

    FRuCity: string;
    FEnCity: string;
    FUaCity: string;

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
  //if aValueStrings <> '' then Exit;

  if (aKey = 'ru_title') then
    if (aValueStrings.Length < 5) then
      ruKey := 'en_title'
    else
      exit;

  if aKey = 'en_country' then ruKey := 'ru_country';
  if aKey = 'ua_title' then ruKey := 'ru_title';
  if aKey = 'ua_country' then ruKey := 'ru_country';
  if aKey = 'ua_address' then ruKey := 'ru_address';
  if aKey = 'ua_city' then ruKey := 'ru_city';

  if aKey = 'ru_content' then
    aValueStrings := Format(aValueStrings, [
      FRuTitle,
      FRuCity,
      FRuTitle,
      FRuCity
    ]);

  if aKey = 'en_content' then
    aValueStrings := Format(aValueStrings, [
      FEnTitle,
      FEnCity,
      FEnTitle,
      FEnCity
    ]);

  if aKey = 'ua_content' then
    aValueStrings := Format(aValueStrings, [
      FUaTitle,
      FUaCity,
      FUaTitle,
      FUaCity
    ]);

  if ruKey = '' then Exit;

  for Rec in aLink.GetRecordsByKey(ruKey) do
    begin
      ruValue := Rec.Value;
      Break;
    end;

  if aKey.Contains('en_') then Lang := 'en';
  if aKey.Contains('ru_') then Lang := 'ru';
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
  i: Integer;
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
        if Key = 'category_identifier' then
          ValueStrings := 'Hotels'
        else
        if Key = 'ru_content' then
          ValueStrings :=
        '%s– отличная гостиница в городе %s для приема как жителей'+
        ' так и гостей города. Просторное здание, уютные номера с прекрасным ремонтом и'+
        ' современной техникой позволят замечательно отдохнуть, переночевать или просто'+
        ' отвлечься. Огромный опыт работы и профессиональная команда сотрудников отеля'+
        ' помогут в решении любых вопросов по заселению, размещению, оформлению'+
        ' документов и Вы получите гарантированно положительный результат. '+
        'Вы точно останетесь довольны качеством обслуживания нашего отеля и будете'+
        ' рекомендовать %s из города %s своим друзьям и знакомым.'
        else
        if Key = 'en_content' then
          ValueStrings :=
        '%s – a perfect hotel in the city %s for accommodation'+
        ' of both residents  and visitors of the city. Spacious edifice, comfortable'+
        ' rooms with beautiful furnishing and modern appliances provide superb leisure,'+
        ' overnight stay and recreation. Huge practical experience and professional'+
        ' team of employees provide assistance in settling the matters of accommodation,'+
        ' allocation and drawing up of documents, securing your guaranteed positive'+
        ' result.  You will be definitely satisfied by the quality of service in our'+
        ' hotel and will recommend %s from the city %s to your'+
        ' friends and acquaintances.'
        else
        if Key = 'ua_content' then
          ValueStrings :=
        '%s – чудовий готель в місті %s для прийому як мешканців'+
        ' так і гостей міста. Простора будівля, комфортні номера з чудовим ремонтом і'+
        ' сучасною технікою, дадуть можливість чудесно відпочити, переночувати чи'+
        ' просто відволіктись від буденності. Багатий стаж роботи і професійна команда'+
        ' персоналу готелю, допоможуть у вирішенні різних питань відносно заселення, '+
        'розміщення, оформлення документів і Ви обов’язково отримаєте позитивний'+
        ' результат. Ви залишитеся задоволеними якістю обслуговування нашого готелю'+
        ' і будете  рекомендувати %s з міста %s своїм друзям і'+
        ' знайомим.'
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
        if Key = 'ru_title' then
            FRuTitle := ValueStrings;

        if Key = 'en_title' then
            FEnTitle := ValueStrings;

        if Key = 'ua_title' then
            FUaTitle :=  ValueStrings;

        if Key = 'ru_city' then
            FRuCity := ValueStrings;

        if Key = 'en_city' then
            FEnCity := ValueStrings;

        if Key = 'ua_city' then
            FUaCity :=  ValueStrings;

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
      'join groups g on g.id = l.group_id ' +
      'join link2link l2l on l2l.child_link_id = l.id ' +
      'where not exists (select Id from link2link l2l where l2l.parent_link_id = l.Id) ' +
      'and exists (select Id from records r where r.link_id = l.Id) ' +
      'and g.job_id = :JobID ' +
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
begin
  Result := [];
  Result := Result + GetKeysFromRule(aLevel.BodyRule);
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
  Keys := Keys + ['category_identifier', 'ua_title', 'ua_city', 'ua_country', 'ua_address'];
  Keys := Keys + ['en_country'];
  Keys := Keys + ['ru_content', 'en_content', 'ua_content'];
  Keys := Keys + ['ru_contacts', 'en_contacts', 'ua_contacts'];
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
