unit mExportRoman;

interface

uses
  API_Yandex,
  eExportField,
  eLink,
  eRecord,
  mExport,
  System.Generics.Collections;

type
  TCacheTrans = record
    Key: string;
    SourceVal: string;
    TransVal: string;
  end;

  TModelExportRoman = class(TModelExport)
  protected
    FTranslater: TYaTranslater;
    FTransCache: TArray<TCacheTrans>;
    function GetTrans(aKey, aSourceValue: string): string;
    procedure CustomHandle(aExportField: TExportField; aLink: TLink;
      aRecList: TRecordList; var aCSVValue: string); override;
  public
    constructor Create(aData: TDictionary<string, variant>;
      aObjData: TObjectDictionary<string, TObject>); override;
    destructor Destroy; override;
  end;

  TModelExportRomanH = class(TModelExportRoman)
  private
    procedure CustomHandle(aExportField: TExportField; aLink: TLink;
      aRecList: TRecordList; var aCSVValue: string); override;
  end;

  TModelExportRomanR = class(TModelExportRoman)
  private
    procedure CustomHandle(aExportField: TExportField; aLink: TLink;
      aRecList: TRecordList; var aCSVValue: string); override;
  end;

  TModelExportRomanS = class(TModelExportRoman)
  private
    procedure CustomHandle(aExportField: TExportField; aLink: TLink;
      aRecList: TRecordList; var aCSVValue: string); override;
  end;

implementation

uses
  System.SysUtils;

procedure TModelExportRomanS.CustomHandle(aExportField: TExportField; aLink: TLink;
  aRecList: TRecordList; var aCSVValue: string);
var
  RecList: TRecordList;
  Rec: TRecord;
begin
  inherited;

  if aExportField.Title = 'ru_content' then
    begin
      aCSVValue := Format(
        '%s – отличное место в городе %s для местных жителей и гостей города.'+
        ' Прекрасное место, которое никого не оставит равнодушным.'+
        ' Завораживающая и манящая атмосфера, дарящая незабываемые впечатления.'+
        ' Вы точно останетесь довольны посещением и будете рекомендовать'+
        ' %s из города %s своим друзьям и знакомым.', [
        Format('%s %s', [GetVal(aLink, 'ru_title'), GetVal(aLink, 'alt_title')]),
        GetVal(aLink, 'ru_city'),
        Format('%s %s', [GetVal(aLink, 'ru_title'), GetVal(aLink, 'alt_title')]),
        GetVal(aLink, 'ru_city')
      ]);
    end;

  if aExportField.Title = 'en_content' then
    begin
      aCSVValue := Format(
        '%s is an excellent place in the city of %s for locals and visitors.'+
        ' It''s an amazing and beautiful place that touches anyone''s feelings.'+
        ' The location offers an intriguing and glamorous atmosphere of an'+
        ' unforgettable experience. You''ll certainly be impressed and satisfied,'+
        ' and will definitely recommend %s from %s to your friends and'+
        ' acquaintances.', [
        GetVal(aLink, 'en_title'),
        GetVal(aLink, 'en_city'),
        GetVal(aLink, 'en_title'),
        GetVal(aLink, 'en_city')
      ]);
    end;

  if aExportField.Title = 'ua_content' then
    begin
      aCSVValue := Format(
        '%s – чудове місце в місті %s для мешканців та гостей міста.'+
        ' Чудове місце, котре нікого не залишить байдужим. Атмосфера зачаровує,'+
        ' манить і дарує незабутні враження. Ви точно залишитесь задоволеними'+
        ' відвідуванням і будете рекомендувати %s з міста %s своїм друзям'+
        ' і знайомим.', [
        Format('%s %s', [GetVal(aLink, 'en_title'), GetTrans('ua_title', GetVal(aLink, 'alt_title'))]),
        GetTrans('ua_city', GetVal(aLink, 'ru_city')),
        Format('%s %s', [GetVal(aLink, 'en_title'), GetTrans('ua_title', GetVal(aLink, 'alt_title'))]),
        GetTrans('ua_city', GetVal(aLink, 'ru_city'))
      ]);
    end;
end;

procedure TModelExportRomanH.CustomHandle(aExportField: TExportField; aLink: TLink;
  aRecList: TRecordList; var aCSVValue: string);
var
  RecList: TRecordList;
  Rec: TRecord;
begin
  inherited;

  if aExportField.Title = 'ru_content' then
    begin
      aCSVValue := Format(
        '%s – отличная гостиница в городе %s для приема как жителей'+
        ' так и гостей города. Просторное здание, уютные номера с прекрасным ремонтом и'+
        ' современной техникой позволят замечательно отдохнуть, переночевать или просто'+
        ' отвлечься. Огромный опыт работы и профессиональная команда сотрудников отеля'+
        ' помогут в решении любых вопросов по заселению, размещению, оформлению'+
        ' документов и Вы получите гарантированно положительный результат. '+
        'Вы точно останетесь довольны качеством обслуживания нашего отеля и будете'+
        ' рекомендовать %s из города %s своим друзьям и знакомым.', [
        Format('%s %s', [GetVal(aLink, 'ru_title'), GetVal(aLink, 'alt_title')]),
        GetVal(aLink, 'ru_city'),
        Format('%s %s', [GetVal(aLink, 'ru_title'), GetVal(aLink, 'alt_title')]),
        GetVal(aLink, 'ru_city')
      ]);

      RecList := aLink.CreateRecListByKey('ru_about');
      try
        for Rec in RecList do
          begin
            aCSVValue := aCSVValue + #13#10 + Rec.Value;
          end;
      finally
        RecList.Free;
      end;

      RecList := aLink.CreateRecListByKey('ru_price');
      try
        for Rec in RecList do
          begin
            aCSVValue := aCSVValue + #13#10 + Rec.Value;
          end;
      finally
        RecList.Free;
      end;

      RecList := aLink.CreateRecListByKey('ru_star');
      try
        for Rec in RecList do
          begin
            aCSVValue := aCSVValue + #13#10 + Rec.Value;
          end;
      finally
        RecList.Free;
      end;

      RecList := aLink.CreateRecListByKey('ru_room_types');
      try
        for Rec in RecList do
          begin
            aCSVValue := aCSVValue + #13#10 + Rec.Value;
          end;
      finally
        RecList.Free;
      end;

      RecList := aLink.CreateRecListByKey('ru_numbers');
      try
        for Rec in RecList do
          begin
            aCSVValue := aCSVValue + #13#10 + Rec.Value;
          end;
      finally
        RecList.Free;
      end;
    end;

  if aExportField.Title = 'en_content' then
    begin
      aCSVValue := Format(
        '%s – a perfect hotel in the city %s for accommodation'+
        ' of both residents  and visitors of the city. Spacious edifice, comfortable'+
        ' rooms with beautiful furnishing and modern appliances provide superb leisure,'+
        ' overnight stay and recreation. Huge practical experience and professional'+
        ' team of employees provide assistance in settling the matters of accommodation,'+
        ' allocation and drawing up of documents, securing your guaranteed positive'+
        ' result. You will be definitely satisfied by the quality of service in our'+
        ' hotel and will recommend %s from the city %s to your'+
        ' friends and acquaintances.', [
        GetVal(aLink, 'en_title'),
        GetVal(aLink, 'en_city'),
        GetVal(aLink, 'en_title'),
        GetVal(aLink, 'en_city')
      ]);

      RecList := aLink.CreateRecListByKey('en_about');
      try
        for Rec in RecList do
          begin
            aCSVValue := aCSVValue + #13#10 + Rec.Value;
          end;
      finally
        RecList.Free;
      end;

      RecList := aLink.CreateRecListByKey('en_price');
      try
        for Rec in RecList do
          begin
            aCSVValue := aCSVValue + #13#10 + Rec.Value;
          end;
      finally
        RecList.Free;
      end;

      RecList := aLink.CreateRecListByKey('en_star');
      try
        for Rec in RecList do
          begin
            aCSVValue := aCSVValue + #13#10 + Rec.Value;
          end;
      finally
        RecList.Free;
      end;

      RecList := aLink.CreateRecListByKey('en_room_types');
      try
        for Rec in RecList do
          begin
            aCSVValue := aCSVValue + #13#10 + Rec.Value;
          end;
      finally
        RecList.Free;
      end;

      RecList := aLink.CreateRecListByKey('en_numbers');
      try
        for Rec in RecList do
          begin
            aCSVValue := aCSVValue + #13#10 + Rec.Value;
          end;
      finally
        RecList.Free;
      end;
    end;

  if aExportField.Title = 'ua_content' then
    begin
      aCSVValue := Format(
        '%s – чудовий готель в місті %s для прийому як мешканців'+
        ' так і гостей міста. Простора будівля, комфортні номера з чудовим ремонтом і'+
        ' сучасною технікою, дадуть можливість чудесно відпочити, переночувати чи'+
        ' просто відволіктись від буденності. Багатий стаж роботи і професійна команда'+
        ' персоналу готелю, допоможуть у вирішенні різних питань відносно заселення, '+
        'розміщення, оформлення документів і Ви обов’язково отримаєте позитивний'+
        ' результат. Ви залишитеся задоволеними якістю обслуговування нашого готелю'+
        ' і будете  рекомендувати %s з міста %s своїм друзям і'+
        ' знайомим.', [
        Format('%s %s', [GetVal(aLink, 'en_title'), GetTrans('ua_title', GetVal(aLink, 'alt_title'))]),
        GetTrans('ua_city', GetVal(aLink, 'ru_city')),
        Format('%s %s', [GetVal(aLink, 'en_title'), GetTrans('ua_title', GetVal(aLink, 'alt_title'))]),
        GetTrans('ua_city', GetVal(aLink, 'ru_city'))
      ]);

      RecList := aLink.CreateRecListByKey('ru_about');
      try
        for Rec in RecList do
          begin
            aCSVValue := aCSVValue + #13#10 + GetTrans('ua_about', Rec.Value);
          end;
      finally
        RecList.Free;
      end;

      RecList := aLink.CreateRecListByKey('ru_price');
      try
        for Rec in RecList do
          begin
            aCSVValue := aCSVValue + #13#10 + GetTrans('ua_price', Rec.Value);
          end;
      finally
        RecList.Free;
      end;

      RecList := aLink.CreateRecListByKey('ru_star');
      try
        for Rec in RecList do
          begin
            aCSVValue := aCSVValue + #13#10 + Rec.Value;
          end;
      finally
        RecList.Free;
      end;

      RecList := aLink.CreateRecListByKey('ru_room_types');
      try
        for Rec in RecList do
          begin
            aCSVValue := aCSVValue + #13#10 + GetTrans('ua_room_types', Rec.Value);
          end;
      finally
        RecList.Free;
      end;

      RecList := aLink.CreateRecListByKey('ru_numbers');
      try
        for Rec in RecList do
          begin
            aCSVValue := aCSVValue + #13#10 + GetTrans('ua_numbers', Rec.Value);
          end;
      finally
        RecList.Free;
      end;
    end;
end;

procedure TModelExportRomanR.CustomHandle(aExportField: TExportField; aLink: TLink;
  aRecList: TRecordList; var aCSVValue: string);
var
  RecList: TRecordList;
  Rec: TRecord;
begin
  inherited;

  if aExportField.Title = 'ru_content' then
    begin
      aCSVValue := Format(
        '%s - отличный ресторан в городе %s для приятного проведения'+
        ' времени, быстрого завтрака, делового бизнес ланча или ужина с любимым'+
        ' человеком. Красивый просторный зал и уютная атмосфера позволят создать'+
        ' условия необходимые именно вам, а кулинарные шедевры наших поваров'+
        ' никого не оставят равнодушным. Вы точно останетесь довольны и будете'+
        ' рекомендовать ресторан %s из города %s своим друзьям и знакомым.', [
        GetVal(aLink, 'ru_title'),
        GetVal(aLink, 'ru_city'),
        GetVal(aLink, 'ru_title'),
        GetVal(aLink, 'ru_city')
      ]);

      RecList := aLink.CreateRecListByKey('ru_about');
      try
        for Rec in RecList do
          begin
            aCSVValue := aCSVValue + #13#10 + Rec.Value;
          end;
      finally
        RecList.Free;
      end;
    end;

  if aExportField.Title = 'en_content' then
    begin
      aCSVValue := Format(
        '%s – an excellent restaurant in the city %s for a pleasant pastime,'+
        ' a short breakfast, a business- lunch or a dinner with someone you'+
        ' love. Attractive spacious hall and cozy atmosphere create the proper'+
        ' environment, while a fine cuisine, prepared by our kitchen-masters,'+
        ' will leave nobody indifferent. You will be definitely satisfied and'+
        ' will recommend %s from the city %s to your friends and acquaintances.', [
        GetVal(aLink, 'en_title'),
        GetVal(aLink, 'en_city'),
        GetVal(aLink, 'en_title'),
        GetVal(aLink, 'en_city')
      ]);

      RecList := aLink.CreateRecListByKey('en_about');
      try
        for Rec in RecList do
          begin
            aCSVValue := aCSVValue + #13#10 + Rec.Value;
          end;
      finally
        RecList.Free;
      end;
    end;

  if aExportField.Title = 'ua_content' then
    begin
      aCSVValue := Format(
        '%s чудовий ресторан в місті %s для приємного проведення'+
        ' часу, швидкого сніданку, ділового бізнес ланчу чи вечері з коханою'+
        ' людиною. Красивий просторий зал, затишна атмосфера дадуть можливість'+
        ' створити умови необхідні саме вам, а кулінарні шедеври наших кухарів,'+
        ' нікого не залишать  байдужими. Ви точно залишитеся задоволеними і'+
        ' будете рекомендувати ресторан %s із міста %s своїм друзям'+
        ' та знайомим.', [
        GetVal(aLink, 'ru_title'),
        GetTrans('ua_city', GetVal(aLink, 'ru_city')),
        GetVal(aLink, 'en_title'),
        GetTrans('ua_city', GetVal(aLink, 'ru_city'))
      ]);

      RecList := aLink.CreateRecListByKey('ru_about');
      try
        for Rec in RecList do
          begin
            aCSVValue := aCSVValue + #13#10 + GetTrans('ua_about', Rec.Value);
          end;
      finally
        RecList.Free;
      end;
    end;
end;

function TModelExportRoman.GetTrans(aKey, aSourceValue: string): string;
var
  CacheTrans: TCacheTrans;
begin
  for CacheTrans in FTransCache do
    if (CacheTrans.Key = aKey) and (CacheTrans.SourceVal = aSourceValue) then
      Exit(CacheTrans.TransVal);

  Result := FTranslater.Translate('uk', aSourceValue);

  CacheTrans.Key := aKey;
  CacheTrans.SourceVal := aSourceValue;
  CacheTrans.TransVal := Result;
  FTransCache := FTransCache + [CacheTrans];
end;

destructor TModelExportRoman.Destroy;
begin
  FTranslater.Free;
  inherited;
end;

constructor TModelExportRoman.Create(aData: TDictionary<string, variant>;
  aObjData: TObjectDictionary<string, TObject>);
begin
  inherited;
  FTranslater := TYaTranslater.Create;
  FTransCache := [];
end;

procedure TModelExportRoman.CustomHandle(aExportField: TExportField; aLink: TLink;
  aRecList: TRecordList; var aCSVValue: string);
var
  RecList: TRecordList;
  Rec: TRecord;
begin
  if aExportField.Title = 'en_source' then
    begin
      RecList := aLink.CreateRecListByKey('site');
      try
        for Rec in RecList do
          begin
            if Rec.Value.Contains('https://www.tripadvisor') then
              begin
                aCSVValue := Rec.Value;
                Break;
              end;
          end;
      finally
        RecList.Free;
      end;
    end;

  if aExportField.Title = 'site_url' then
    begin
      RecList := aLink.CreateRecListByKey('site');
      try
        aCSVValue := '';
        for Rec in RecList do
          begin
            if not Rec.Value.Contains('https://www.tripadvisor') then
              begin
                aCSVValue := Rec.Value;
                Break;
              end;
          end;
      finally
        RecList.Free;
      end;
    end;

  if aExportField.Title = 'ua_address' then
    begin
      aCSVValue := FTranslater.Translate('uk', GetVal(aLink, 'ru_address'));
    end;

  if aExportField.Title = 'ctime' then
    begin
      aCSVValue := DateTimeToStr(aLink.HandleTime);
    end;

  if aExportField.Title = 'ru_title' then
    begin
      aCSVValue := Format('%s %s', [aCSVValue, GetVal(aLink, 'alt_title')]);
    end;

  if aExportField.Title = 'ua_title' then
    begin
      aCSVValue := GetTrans('ua_title', GetVal(aLink, 'alt_title'));
      aCSVValue := Format('%s %s', [GetVal(aLink, 'en_title'), aCSVValue]);
    end;

  if aExportField.Title = 'ua_country' then
    begin
      aCSVValue := GetTrans('ua_country', GetVal(aLink, 'ru_country'));
    end;

  if aExportField.Title = 'ua_city' then
    begin
      aCSVValue := GetTrans('ua_city', GetVal(aLink, 'ru_city'));
    end;
end;

end.
