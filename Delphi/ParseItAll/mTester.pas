unit mTester;

interface

uses
  API_MVC_DB,
  eJob;

type
  TModelTester = class(TModelDB)
  private
    FJob: TJob;
    FLevel: Integer;
  published
    procedure GetTestPageURL;
    procedure AssignDataToTestLink;
  end;

implementation

uses
  System.JSON,
  eLevel,
  eTestLink;

procedure TModelTester.AssignDataToTestLink;
var
  Data: string;
  jsnData: TJSONObject;
  jsnResult: TJSONArray;
  jsnRule: TJSONValue;
  jsnRuleResList: TJSONArray;
  jsnRuleResAsValue: TJSONValue;
  jsnRuleResAsObj: TJSONObject;
  LinkLevel, TestLevel: Integer;
  TestStepRest: Integer;
begin
  Data := FData.Items['DataReceived'];
  TestLevel := FData.Items['TestLevel'];
  TestStepRest := FData.Items['TestStepRest'];
  jsnData:=TJSONObject.ParseJSONValue(Data) as TJSONObject;
  try
    jsnResult:=jsnData.GetValue('result') as TJSONArray;

    for jsnRule in jsnResult do
      begin
        jsnRuleResList := jsnRule as TJSONArray;

        for jsnRuleResAsValue in jsnRuleResList do
          begin
            jsnRuleResAsObj := jsnRuleResAsValue as TJSONObject;

            if jsnRuleResAsObj.GetValue('type').Value = 'link' then
              begin
                LinkLevel := (jsnRuleResAsObj.GetValue('level') as TJSONNumber).AsInt;
                if LinkLevel = TestLevel then Dec(TestStepRest);

              end;
          end;
      end;
  finally
    jsnData.Free;
  end;
end;

procedure TModelTester.GetTestPageURL;
var
  JobLevel: TJobLevel;
  MinLevel: Integer;
  TestLink: TTestLink;
begin
  FJob := FObjData.Items['Job'] as TJob;
  FLevel := FData.Items['Level'];

  JobLevel := FJob.GetLevel(FLevel);
  MinLevel := FJob.GetMinLevel;

  TestLink := JobLevel.GetTestLink(MinLevel);
  if TestLink = nil then
    begin
      TestLink := TTestLink.Create(FDBEngine);
      TestLink.Level := MinLevel;
      TestLink.Link :=FJob.GetLevel(MinLevel).BaseLink;

      JobLevel.TestLinks.Add(TestLink);
    end;

  FData.AddOrSetValue('URL', TestLink.Link);
  FObjData.AddOrSetValue('TestLevel', FJob.GetLevel(MinLevel));
  FObjData.AddOrSetValue('TestStep', FJob.GetLevel(MinLevel));
  CreateEvent('OnTestLinkPrepared');
end;

end.
