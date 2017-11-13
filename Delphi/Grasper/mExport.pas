unit mExport;

interface

uses
  API_MVC_DB,
  API_Yandex,
  eExportField,
  eLevel,
  eLink,
  eRule,
  eRecord,
  FireDAC.Comp.Client;

type
  TCacheRecord = record
    Key: string;
    Value: string;
  end;

  TModelExport = class(TModelDB)
  private
    ////////////////////////////////////////////////////////////////////////////
    FFileName: string;
    FCache: TArray<TCacheRecord>;
    function CreateLinkslist(aJobID: Integer): TFDQuery;
    procedure AddToCSVString(var aString: string; aValue: string);
    procedure AddToCSVValue(var aValue: string; aText: string);
    procedure ProcessLink(aExportFields: TExportFieldList; aLinkID: Integer);
    procedure WriteHeader(aExportFields: TExportFieldList);
    procedure WriteToFile(aString: string);
    ////////////////////////////////////////////////////////////////////////////
  protected
    procedure CustomHandle(aExportField: TExportField; aLink: TLink;
      aRecList: TRecordList; var aCSVValue: string); virtual;
    function GetVal(aLink: TLink; aKey: string): string;
  published
    procedure ExportToCSV;
  end;

implementation

uses
  System.SysUtils,
  System.Generics.Collections,
  API_Files,
  eJob;

function TModelExport.GetVal(aLink: TLink; aKey: string): string;
var
  CacheRec: TCacheRecord;
begin
  for CacheRec in FCache do
    if CacheRec.Key = aKey then
      Exit(CacheRec.Value);

  Result := aLink.GetFirstValueByKey(aKey);

  CacheRec.Key := aKey;
  CacheRec.Value := Result;
  FCache := FCache + [CacheRec];
end;

procedure TModelExport.CustomHandle(aExportField: TExportField; aLink: TLink;
  aRecList: TRecordList; var aCSVValue: string);
begin
end;

procedure TModelExport.WriteHeader(aExportFields: TExportFieldList);
var
  CSVString: string;
  ExportField: TExportField;
begin
  for ExportField in aExportFields do
    begin
      if ExportField.IsEnabled then
        AddToCSVString(CSVString, ExportField.Title);
    end;

  WriteToFile(CSVString);
end;

procedure TModelExport.AddToCSVValue(var aValue: string; aText: string);
begin
  if aValue <> '' then
    aValue := aValue + #13#10 + aText
  else
    aValue := aText;
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

procedure TModelExport.ProcessLink(aExportFields: TExportFieldList; aLinkID: Integer);
var
  CSVString: string;
  CSVValue: string;
  ExportField: TExportField;
  i: Integer;
  InvertCSVString: TArray<string>;
  Link: TLink;
  Rec: TRecord;
  RecList: TRecordList;
begin
  FCache := [];

  Link := TLink.Create(FDBEngine, aLinkID);
  try
    for i := aExportFields.Count - 1 downto 0 do
      begin
        CSVValue := '';

        ExportField := aExportFields[i];
        if not ExportField.IsEnabled then Continue;

        if ExportField.RuleRecID > 0 then
          RecList := Link.CreateRecListByKey(ExportField.RuleRec.Key)
        else
          RecList := TRecordList.Create(True);
        try
          for Rec in RecList do
            AddToCSVValue(CSVValue, Rec.Value);

          // custom proc
          CustomHandle(ExportField, Link, RecList, CSVValue);
        finally
          if Assigned(RecList) then FreeAndNil(RecList);
        end;

        InvertCSVString := [CSVValue] + InvertCSVString;
      end;

    CSVString := '';
    for CSVValue in InvertCSVString do
      AddToCSVString(CSVString, CSVValue);

    WriteToFile(CSVString);
  finally
    Link.Free;
  end;

  {Link := TLink.Create(FDBEngine, aLinkID);
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
  end;}
end;

function TModelExport.CreateLinkslist(aJobID: Integer): TFDQuery;
begin
  Result := TFDQuery.Create(nil);

  Result.SQL.Text :=
    'select l.Id ' +
    'from links l ' +
    'join groups g on g.id = l.group_id ' +
    'join link2link l2l on l2l.child_link_id = l.id ' +
    'where not exists (select Id from link2link l2l where l2l.parent_link_id = l.Id) ' +
    'and exists (select Id from records r where r.link_id = l.Id) ' +
    'and g.job_id = :JobID ' +
    'group by l2l.parent_link_id '+
    'order by l.handle_time, level';

  Result.ParamByName('JobID').AsInteger := aJobID;
  FDBEngine.OpenQuery(Result, False);
end;

procedure TModelExport.ExportToCSV;
var
  Job: TJob;
  dsQuery: TFDQuery;
begin
  Job := (FObjData.Items['Job'] as TJob);
  try
    // create file
    FFileName := GetCurrentDir + '\Export\' +Job.ID.ToString + '_' + IntToStr(Trunc(Now))+'.csv';
    TFilesEngine.CreateFile(FFileName);

    // header
    WriteHeader(Job.ExportFields);

    dsQuery := CreateLinkslist(Job.ID);
    while not dsQuery.EOF do
      begin
        ProcessLink(Job.ExportFields, dsQuery.FieldByName('Id').AsInteger);
        dsQuery.Next;
      end;
  finally
    dsQuery.Free;
    Job.Free;
  end;
end;

end.
