unit mTester;

interface

uses
  API_MVC_DB,
  eJob;

type
  TModelTester = class(TModelDB)
  private
    procedure SetNextTestLink(aTestLevel, aCurrentTestLevel, aLinkNum: integer; aURL: string);
    procedure PrepareTestLevel(aTestLevel, aCurrentTestLevel: integer);
    procedure ProcessNextTestLink(aTestStepRest: integer; aURL: string);
  published
    procedure GetNextTestPage;
    procedure ProcessDataRecieved;
  end;

implementation

uses
  System.JSON,
  eLevel,
  eTestLink;

procedure TModelTester.ProcessNextTestLink(aTestStepRest: integer; aURL: string);
begin
  FData.AddOrSetValue('URL', aURL);
  FData.AddOrSetValue('TestStepRest', aTestStepRest);
  CreateEvent('OnTestLinkPrepared');
end;

procedure TModelTester.PrepareTestLevel(aTestLevel, aCurrentTestLevel: integer);
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
      TestLink.Num := 0;
      TestLink.Link := LevelForScript.BaseLink;
      TestLink.IsActual := True;

      TestLevel.TestLinks.Add(TestLink);
    end;

  FData.AddOrSetValue('URL', TestLink.Link);
  FObjData.AddOrSetValue('LevelForScript', LevelForScript);
  FData.AddOrSetValue('CurrentTestLevel', aCurrentTestLevel);
  CreateEvent('OnTestLinkPrepared');
end;

procedure TModelTester.SetNextTestLink(aTestLevel, aCurrentTestLevel, aLinkNum: integer; aURL: string);
var
  TestLevel: TJobLevel;
  TestLink: TTestLink;
  Job: TJob;
begin
  Job := FObjData.Items['Job'] as TJob;
  TestLevel := Job.GetLevel(aTestLevel);

  TestLink := TestLevel.GetActualTestLink(aCurrentTestLevel);
  TestLink.IsActual := False;

  TestLink := TTestLink.Create(FDBEngine);
  TestLink.Level := aCurrentTestLevel;
  TestLink.Num := aLinkNum;
  TestLink.Link := aURL;
  TestLink.IsActual := True;

  TestLevel.TestLinks.Add(TestLink);

  if TestLevel.ID > 0 then
    TestLevel.TestLinks.SaveList(TestLevel.ID);
end;

procedure TModelTester.ProcessDataRecieved;
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
  i: Integer;
  TestLink: TTestLink;
begin
  Data := FData.Items['DataReceived'];
  CurrentTestLevel := FData.Items['CurrentTestLevel'];
  TestLevel := FData.Items['TestLevel'];
  TestStepRest := FData.Items['TestStepRest'];
  TestLink := (FObjData.Items['Job'] as TJob).GetLevel(TestLevel).GetActualTestLink(TestLevel);

  jsnData:=TJSONObject.ParseJSONValue(Data) as TJSONObject;
  try
    jsnResult:=jsnData.GetValue('result') as TJSONArray;
    i := 0;

    for jsnRule in jsnResult do
      begin
        jsnRuleResList := jsnRule as TJSONArray;

        for jsnRuleResAsValue in jsnRuleResList do
          begin
            jsnRuleResAsObj := jsnRuleResAsValue as TJSONObject;

            if jsnRuleResAsObj.GetValue('type').Value = 'link' then
              begin
                LinkLevel := (jsnRuleResAsObj.GetValue('level') as TJSONNumber).AsInt;

                if LinkLevel = CurrentTestLevel then


                if LinkLevel = TestLevel then
                  begin
                    inc(i);

                    URL := jsnRuleResAsObj.GetValue('href').Value;
                    if TestLink.Num < i then
                      Dec(TestStepRest);
                  end;

                if TestStepRest = 0 then
                  begin
                    SetNextTestLink(TestLevel, CurrentTestLevel, i, URL);
                    ProcessNextTestLink(TestStepRest, URL);
                    Exit;
                  end;
              end;
          end;
      end;

    if URL = '' then
      PrepareTestLevel(TestLevel, CurrentTestLevel - 1)
    else
      begin
        TestLink.Num := 0;
        SetNextTestLink(TestLevel, CurrentTestLevel, 0, URL);
        ProcessNextTestLink(TestStepRest, URL);
      end;
  finally
    jsnData.Free;
  end;
end;

procedure TModelTester.GetNextTestPage;
var
  TestLevel: Integer;
begin
  TestLevel := FData.Items['TestLevel'];

  PrepareTestLevel(TestLevel, TestLevel);
end;

end.
