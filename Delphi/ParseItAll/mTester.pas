unit mTester;

interface

uses
  API_MVC_DB,
  eJob;

type
  TModelTester = class(TModelDB)
  private
    procedure SetNextTestLink(aTestLevel, aPageLevel, aLinkNum: integer; aURL: string);
    procedure PrepareNewLevel(aTestLevel, aPageLevel, aLookingLevel: integer);
    procedure ProcessNextTestLink(aTestStepRest: integer; aURL: string);
    procedure PerformData(aIsLookingNextPageMode: Boolean; aLookingLevel: Integer);
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

procedure TModelTester.PrepareNewLevel(aTestLevel, aPageLevel, aLookingLevel: integer);
var
  TestLevel, LevelForScript: TJobLevel;
  TestLink: TTestLink;
  Job: TJob;
begin
  Job := FObjData.Items['Job'] as TJob;
  TestLevel := Job.GetLevel(aTestLevel);
  LevelForScript := Job.GetLevel(aPageLevel);

  TestLink := TestLevel.GetActualTestLink(aPageLevel);
  if TestLink = nil then
    begin
      TestLink := TTestLink.Create(FDBEngine);
      TestLink.Level := aPageLevel;
      TestLink.Num := 0;
      TestLink.Link := LevelForScript.BaseLink;
      TestLink.IsActual := True;

      TestLevel.TestLinks.Add(TestLink);
    end;

  FData.AddOrSetValue('URL', TestLink.Link);
  FObjData.AddOrSetValue('LevelForScript', LevelForScript);

  FData.AddOrSetValue('PageLevel', aPageLevel);
  FData.AddOrSetValue('LookingLevel', aLookingLevel);

  CreateEvent('OnTestLinkPrepared');
end;

procedure TModelTester.SetNextTestLink(aTestLevel, aPageLevel, aLinkNum: integer; aURL: string);
var
  TestLevel: TJobLevel;
  TestLink: TTestLink;
  Job: TJob;
begin
  Job := FObjData.Items['Job'] as TJob;
  TestLevel := Job.GetLevel(aTestLevel);

  TestLink := TestLevel.GetActualTestLink(aPageLevel);
  TestLink.IsActual := False;

  TestLink := TTestLink.Create(FDBEngine);
  TestLink.Level := aPageLevel;
  TestLink.Num := aLinkNum;
  TestLink.Link := aURL;
  TestLink.IsActual := True;

  TestLevel.TestLinks.Add(TestLink);

  if TestLevel.ID > 0 then
    TestLevel.TestLinks.SaveList(TestLevel.ID);
end;

procedure TModelTester.ProcessDataRecieved;
begin
  PerformData(False, FData.Items['LookingLevel']);
end;

procedure TModelTester.PerformData(aIsLookingNextPageMode: Boolean; aLookingLevel: Integer);
var
  Data: string;
  jsnData: TJSONObject;
  jsnResult: TJSONArray;
  jsnRule: TJSONValue;
  jsnRuleResList: TJSONArray;
  jsnRuleResAsValue: TJSONValue;
  jsnRuleResAsObj: TJSONObject;
  LinkLevel, TestLevel, PageLevel: Integer;
  TestStepRest: Integer;
  URL: string;
  i: Integer;
  TestLink: TTestLink;
begin
  Data := FData.Items['DataReceived'];

  PageLevel := FData.Items['PageLevel'];
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

                // process in looking for level mode
                if not aIsLookingNextPageMode then
                  begin
                    if LinkLevel = aLookingLevel then
                      begin
                        inc(i);

                        URL := jsnRuleResAsObj.GetValue('href').Value;

                        if (TestLink.Level = LinkLevel) and (TestLink.Num < i) then
                          Dec(TestStepRest);
                      end;

                    if TestStepRest = 0 then
                      begin
                        SetNextTestLink(TestLevel, TestLevel, i, URL);
                        ProcessNextTestLink(TestStepRest, URL);
                        Exit;
                      end;
                  end
                else  // process in looking for next page mode
                  begin
                    if LinkLevel = aLookingLevel then
                      URL := jsnRuleResAsObj.GetValue('href').Value;

                    if URL <> '' then
                      begin
                        SetNextTestLink(TestLevel, PageLevel, 0, URL);
                        ProcessNextTestLink(TestStepRest, URL);
                        Exit;
                      end;
                  end;
              end;
          end;
      end;

    // decrease level
    if URL = '' then
      PrepareNewLevel(TestLevel, PageLevel - 1, aLookingLevel)
    else
      // switch to looking for next page mode
      begin
        TestLink.Num := 0;
        FData.Items['TestStepRest'] := TestStepRest;
        PerformData(True, PageLevel);
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

  PrepareNewLevel(TestLevel, TestLevel, TestLevel);
end;

end.
