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
  jsnRulePairList: TJSONArray;
  jsnRulePair: TJSONValue;
  jsnRulePairObj: TJSONObject;
begin
  Data := FData.Items['DataReceived'];
  jsnData:=TJSONObject.ParseJSONValue(Data) as TJSONObject;

  jsnResult:=jsnData.GetValue('result') as TJSONArray;

  for jsnRule in jsnResult do
    begin
      jsnRulePairList := jsnRule as TJSONArray;

      for jsnRulePair in jsnRulePairList do
        begin

          jsnRulePairObj := jsnRulePair as TJSONObject;

        end;
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
