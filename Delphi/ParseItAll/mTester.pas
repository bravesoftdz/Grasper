unit mTester;

interface

uses
  API_MVC_DB,
  eJob;

type
  TModelTester = class(TModelDB)
  private
    procedure GetNextTestLink(aTestLevel, aCurrentTestLevel, aTestStepRest: integer; aLastURL: string);
    procedure PrepareLevel(aTestLevel, aCurrentTestLevel: integer);
  published
    procedure GetNextTestPage;
    procedure AssignDataToTestLink;
  end;

implementation

uses
  System.JSON,
  eLevel,
  eTestLink;

procedure TModelTester.PrepareLevel(aTestLevel, aCurrentTestLevel: integer);
var
  TestLevel, LevelForScript: TJobLevel;
  TestLink: TTestLink;
  Job: TJob;
begin
  Job := FObjData.Items['Job'] as TJob;
  TestLevel := Job.GetLevel(aTestLevel);
  LevelForScript := Job.GetLevel(aCurrentTestLevel);

  TestLink := TestLevel.GetActualTestLink(aCurrentTestLevel);
  if TestLink = nil then
    begin
      TestLink := TTestLink.Create(FDBEngine);
      TestLink.Level := aCurrentTestLevel;
      TestLink.Link := LevelForScript.BaseLink;
      TestLink.IsActual := True;

      TestLevel.TestLinks.Add(TestLink);
    end;

  FData.AddOrSetValue('URL', TestLink.Link);
  FObjData.AddOrSetValue('LevelForScript', LevelForScript);
  FData.AddOrSetValue('CurrentTestLevel', aCurrentTestLevel);
  CreateEvent('OnTestLinkPrepared');
end;

procedure TModelTester.GetNextTestLink(aTestLevel, aCurrentTestLevel, aTestStepRest: integer; aLastURL: string);
var
  JobLevel: TJobLevel;
  TestLink: TTestLink;
  Job: TJob;
begin
  Job := FObjData.Items['Job'] as TJob;
  JobLevel := Job.GetLevel(aTestLevel);

  if aTestStepRest = 0 then
    begin
      TestLink := JobLevel.GetActualTestLink(aTestLevel);
      TestLink.IsActual := False;

      TestLink := TTestLink.Create(FDBEngine);
      TestLink.Level := JobLevel.Level;
      TestLink.Link := aLastURL;
      TestLink.IsActual := True;

      JobLevel.TestLinks.Add(TestLink);

      if JobLevel.ID > 0 then
        JobLevel.TestLinks.SaveList(JobLevel.ID);
    end;

  if aLastURL = '' then PrepareLevel(aTestLevel, aCurrentTestLevel - 1)
  else
    begin
      FData.AddOrSetValue('URL', aLastURL);
      FData.AddOrSetValue('TestStepRest', aTestStepRest);
      CreateEvent('OnTestLinkPrepared');
    end;
end;

procedure TModelTester.AssignDataToTestLink;
var
  Data: string;
  jsnData: TJSONObject;
  jsnResult: TJSONArray;
  jsnRule: TJSONValue;
  jsnRuleResList: TJSONArray;
  jsnRuleResAsValue: TJSONValue;
  jsnRuleResAsObj: TJSONObject;
  LinkLevel, TestLevel, CurrentTestLevel: Integer;
  TestStepRest: Integer;
  URL: string;
begin
  Data := FData.Items['DataReceived'];
  CurrentTestLevel := FData.Items['CurrentTestLevel'];
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
                if LinkLevel = TestLevel then
                  begin
                    URL := jsnRuleResAsObj.GetValue('href').Value;
                    Dec(TestStepRest);
                  end;

                if TestStepRest = 0 then
                  begin
                    GetNextTestLink(TestLevel, CurrentTestLevel, TestStepRest, URL);
                    Exit;
                  end;
              end;
          end;
      end;

    if URL = '' then
      PrepareLevel(TestLevel, CurrentTestLevel - 1)
    else
      GetNextTestLink(TestLevel, CurrentTestLevel, TestStepRest, URL);
  finally
    jsnData.Free;
  end;
end;

procedure TModelTester.GetNextTestPage;
var
  TestLevel: Integer;
begin
  TestLevel := FData.Items['TestLevel'];

  PrepareLevel(TestLevel, TestLevel);
end;

end.
