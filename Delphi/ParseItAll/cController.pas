unit cController;

interface

uses
  System.JSON,
  API_MVC,
  API_MVC_DB,
  API_DB_SQLite,
  cefvcl,
  cefLib,
  eJob,
  eLevel,
  eRule,
  eRuleLink,
  eRuleRecords,
  eRuleCut,
  eRegExp,
  eNodes;

type
  TJSExtension = class
    class procedure selectdataback(const data: string);
    class procedure parsedataback(const data: string);
  end;

  TCustomRenderProcessHandler = class(TCefRenderProcessHandlerOwn)
  protected
    procedure OnWebKitInitialized; override;
  end;

  TController = class(TControllerDB)
  private
    FJSScript: string;
    FLastParseResult: TJSONObject;
    FSelectNewLevelLink: Boolean;
    FGettingTestPage: Boolean;
    procedure crmLoadEnd(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
    procedure crmProcessMessageReceived(Sender: TObject;
            const browser: ICefBrowser; sourceProcess: TCefProcessId;
            const message: ICefProcessMessage; out Result: Boolean);
    procedure SyncParentChildRuleNodes(aNodes, aParentNodes: TNodeList);
    function CanAddLevel(aJobRule: TJobLink): Boolean;
    function GetJob: TJob;
  protected
    procedure InitDB; override;
    procedure PerfomViewMessage(aMsg: string); override;
    procedure EventListener(aEventMsg: string); override;
  published
    procedure GetJobList;

    procedure CreateJob;
    procedure StoreJob;

    procedure EditJobRules;
    procedure StoreJobRules;

    procedure OnRuleSelected;
    procedure OnTestPageLoaded;

    procedure CreateLevel(frame: ICefFrame);
    procedure DeleteLevel;

    procedure AddLink;
    procedure AddChildLink;

    procedure AddRecord;
    procedure AddChildRecord;

    procedure AddChildCut;

    procedure AddRegExp;

    procedure RemoveRule;

    procedure SelectHTMLNode;

    procedure AddNodes(aNodesData: string);

    procedure ShowRuleResult;

    procedure ParseDataReceived(aData: string);

    procedure ClearJobLinks;

    // Testing
    procedure GetNextTestPage;

    // Exports
    procedure ExportJobResultsToCSV;

    procedure TempCopy;
  end;

implementation

uses
  Vcl.Dialogs,
  Vcl.Controls,
  System.SysUtils,
  API_Files,
  API_ORM,
  vMain,
  vLogin,
  vJob,
  vRules,
  vRuleResult,
  mParser,
  mTester,
  mExport,

  FireDAC.Comp.Client;

procedure TController.TempCopy;
var
  SourceLevel, EngLevel: TJobLevel;
  RuleRel, NewRuleRel: TLevelRuleRel;
begin
  // copy Levels
  SourceLevel := TJobLevel.Create(FDBEngine, 3);
  EngLevel := TJobLevel.Create(FDBEngine, 5);
  try
    for RuleRel in SourceLevel.RuleRels do
      begin
        NewRuleRel := TLevelRuleRel.Create(FDBEngine);
        NewRuleRel.Rule := TJobRule.Create(FDBEngine);
        NewRuleRel.Rule.Assign(RuleRel.Rule);

        EngLevel.RuleRels.Add(NewRuleRel);
      end;

    EngLevel.SaveAll;
  finally
    SourceLevel.Free;
    EngLevel.Free;
  end;
end;

procedure TController.ExportJobResultsToCSV;
var
  Job: TJob;
begin
  Job := TJob.Create(FDBEngine, ViewMain.SelectedJobID);
  FObjData.AddOrSetValue('Job', Job);
  CallModel(TModelExport, 'ExportToCSV');
end;

procedure TController.OnTestPageLoaded;
begin
  FObjData.AddOrSetValue('Level', FObjData.Items['LevelForScript']);
  FData.AddOrSetValue('JSScript', FJSScript);
  CallModel(TModelJS, 'PrepareJSScriptForLevel');
end;

procedure TController.GetNextTestPage;
begin
  FGettingTestPage := True;

  FData.AddOrSetValue('TestStepRest', 5);
  FData.AddOrSetValue('TestLevel', ViewRules.GetSelectedLevel.Level);

  CallModel(TModelTester, 'GetNextTestPage');
end;

procedure TController.ClearJobLinks;
var
  dsQuery: TFDQuery;
begin
  dsQuery := TFDQuery.Create(nil);
  try
    dsQuery.SQL.Text := 'delete from links where job_id = :jobid';
    dsQuery.ParamByName('jobid').AsInteger := ViewMain.SelectedJobID;
    FDBEngine.ExecQuery(dsQuery);
  finally
    dsQuery.Free;
  end;
end;

procedure TController.SyncParentChildRuleNodes(aNodes, aParentNodes: TNodeList);
var
  i: Integer;
  Node: TJobNode;
  LastParentNode: TJobNode;
  isClearMode: Boolean;
begin
  LastParentNode := aParentNodes.Last;
  isClearMode := False;

  for i := aNodes.Count - 1 downto 0 do
    begin
      Node := aNodes[i];

      if not isClearMode then
        if    (Node.Tag = LastParentNode.Tag)
          and (Node.Index = LastParentNode.Index)
          and (Node.TagID = LastParentNode.TagID)
          and (Node.ClassName.Contains(LastParentNode.ClassName))
          and (Node.Name = LastParentNode.Name)
        then
          isClearMode := True;

      if isClearMode then
        aNodes.DeleteByEntity(Node);
    end;
end;

procedure TController.AddRegExp;
var
  RegExp: TJobRegExp;  
begin  
  RegExp := TJobRegExp.Create(FDBEngine); 
  ViewRules.GetSelectedRule.RegExps.Add(RegExp);

  ViewRules.AddRegExpToTree(ViewRules.GetSelectedRule, RegExp);
end;

procedure TController.StoreJob;
var
  Job: TJob;
begin
  Job := FObjData.Items['Job'] as TJob;
  Job.SaveAll;
  ViewJob.Close;
  GetJobList;
end;

procedure TController.CreateJob;
var
  Job: TJob;
begin
  Job := TJob.Create(FDBEngine, 0);
  FObjData.AddOrSetValue('Job', Job);
  CallView(TViewJob);
  ViewJob.EntityPanel.BuildControls(Job);
  ViewJob.SetBrowserLinks;
end;

procedure TController.DeleteLevel;
begin
  GetJob.Levels.DeleteByIndex(ViewRules.GetLevelIndex);
  ViewRules.SetLevels(GetJob.Levels);
end;

procedure TController.OnRuleSelected;
begin
  FObjData.AddOrSetValue('Level', ViewRules.GetSelectedLevel);
  FObjData.AddOrSetValue('Rule', ViewRules.GetSelectedRule);
  FData.AddOrSetValue('JSScript', FJSScript);
  CallModel(TModelJS, 'PrepareJSScriptForLevel');

  //FObjData.AddOrSetValue('Rule', ViewRules.GetSelectedRule);
  //FData.AddOrSetValue('JSScript', FJSScript);
  //FData.AddOrSetValue('CanAddLevel', CanAddLevel(ViewRules.GetSelectedRule.Link));
  //CallModel(TModelJS, 'PrepareJSScriptForRule');
end;

procedure TController.ShowRuleResult;
var
  jsnResultArray: TJSONArray;
  jsnGroupArray: TJSONArray;
  jsnRuleObj: TJSONObject;
  jsnGroupValue, jsnRuleValue: TJSONValue;
  value: string;
begin
  CallView(TViewRuleResult);

  jsnResultArray := FLastParseResult.GetValue('result') as TJSONArray;

  for jsnGroupValue in jsnResultArray do
    begin
      jsnGroupArray := jsnGroupValue as TJSONArray;
      for jsnRuleValue in jsnGroupArray do
        begin
          jsnRuleObj := jsnRuleValue as TJSONObject;

          if jsnRuleObj.TryGetValue('href', value) then
            value := jsnRuleObj.GetValue('href').Value;

          if jsnRuleObj.TryGetValue('value', value) then
            value := jsnRuleObj.GetValue('value').Value;

          ViewRuleResult.redtResults.Lines.Add(value);
        end;
    end;
end;

procedure TController.ParseDataReceived(aData: string);
begin
  FLastParseResult := TJSONObject.ParseJSONValue(aData) as TJSONObject;

  if FGettingTestPage then
    begin
      FData.AddOrSetValue('DataReceived', aData);
      CallModel(TModelTester, 'ProcessDataRecieved');
    end;
end;

procedure TController.crmLoadEnd(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
var
  InjectJS: string;
begin
  InjectJS := TFilesEngine.GetTextFromFile(GetCurrentDir + '\JS\jquery-3.1.1.js');
  ViewRules.chrmBrowser.Browser.MainFrame.ExecuteJavaScript(InjectJS, 'about:blank', 0);

  if FSelectNewLevelLink then
    begin
      CreateLevel(frame);
      FSelectNewLevelLink := False;
    end;

  if FGettingTestPage then OnTestPageLoaded;
end;

function TController.GetJob: TJob;
begin
  Result := FObjData.Items['Job'] as TJob;
end;

function TController.CanAddLevel(aJobRule: TJobLink): Boolean;
var
  MaxLevel: Integer;
  Level: TJobLevel;
begin
  if aJobRule = nil then Exit(False);

  MaxLevel := 0;
  for Level in GetJob.Levels do
    if Level.Level > MaxLevel then MaxLevel := Level.Level;

  if aJobRule.Level > MaxLevel then
    Result := True
  else
    Result := False;
end;

procedure TController.CreateLevel(frame: ICefFrame);
var
  Level: TJobLevel;
begin
  Level := TJobLevel.Create(FDBEngine, 0);
  //Level.Level := ViewRules.GetSelectedRule.Link.Level;
  Level.BaseLink := frame.Url;

  GetJob.Levels.Add(Level);
  ViewRules.SetLevels(GetJob.Levels, GetJob.Levels.Count - 1);
end;

procedure TController.AddNodes(aNodesData: string);
var
  jsnNodes: TJSONArray;
  jsnValue: TJSONValue;
  jsnNode: TJSONObject;
  Node: TJobNode;
  ParentEntity: TEntityAbstract;
  Rule, ParentRule: TJobRule;
  sValue: string;
begin
  jsnNodes:=TJSONObject.ParseJSONValue(aNodesData) as TJSONArray;
  Rule := ViewRules.GetSelectedRule;
  Rule.Nodes.DeleteAll;

  for jsnValue in jsnNodes do
    begin
      jsnNode:=jsnValue as TJSONObject;

      Node := TJobNode.Create(FDBEngine);
      Node.Tag := jsnNode.Values['tag'].Value;
      Node.Index := (jsnNode.Values['index'] as TJSONNumber).AsInt;

      if jsnNode.GetValue('tagID') <> nil then
        Node.TagID := jsnNode.GetValue('tagID').Value;

      if jsnNode.GetValue('className') <> nil then
        Node.ClassName := jsnNode.GetValue('className').Value;

      if jsnNode.GetValue('name') <> nil then
        Node.Name := jsnNode.GetValue('name').Value;

      Rule.Nodes.Add(Node);
    end;

  ParentEntity := ViewRules.GetParentEntity;
  if ParentEntity is TJobRule then
    begin
      ParentRule := ParentEntity as TJobRule;
      SyncParentChildRuleNodes(Rule.Nodes, ParentRule.Nodes);
    end;

  OnRuleSelected;
end;

procedure TController.crmProcessMessageReceived(Sender: TObject;
        const browser: ICefBrowser; sourceProcess: TCefProcessId;
        const message: ICefProcessMessage; out Result: Boolean);
begin
  if message.Name = 'selectdataback' then
    begin
      AddNodes(message.ArgumentList.GetString(0));
      OnRuleSelected;
    end;

  if message.Name = 'parsedataback' then ParseDataReceived(message.ArgumentList.GetString(0));
end;

procedure TController.SelectHTMLNode;
var
  InjectJS: string;
begin
  InjectJS := TFilesEngine.GetTextFromFile(GetCurrentDir + '\JS\DOMSelector.js');
  ViewRules.chrmBrowser.Browser.MainFrame.ExecuteJavaScript(InjectJS, 'about:blank', 0);
end;

procedure TController.RemoveRule;
var
  ParentRule: TJobRule;
  Index: Integer;
begin
  if ViewRules.GetParentEntity is TJobRule then
    begin
      ParentRule := ViewRules.GetParentEntity as TJobRule;
      Index := ParentRule.IndexOfChildRule(ViewRules.GetSelectedRule);          
      ParentRule.ChildRuleRels.DeleteByIndex(Index);
    end
  else
    ViewRules.GetSelectedLevel.RuleRels.DeleteByIndex(ViewRules.TreeIndex);
  
  ViewRules.RemoveTreeNode;    
end;

procedure TController.AddChildCut;
var
  RuleRel: TRuleRuleRel;
  ParentRule: TJobRule;
begin
  RuleRel := TRuleRuleRel.Create(FDBEngine);
  RuleRel.ChildRule := TJobRule.Create(FDBEngine);
  RuleRel.ChildRule.Cut := TJobCut.Create(FDBEngine);

  ParentRule := ViewRules.GetSelectedRule;
  ParentRule.ChildRuleRels.Add(RuleRel);

  ViewRules.AddRuleToTree(ParentRule, RuleRel.ChildRule);
end;

procedure TController.AddChildLink;
var
  RuleRel: TRuleRuleRel;
  ParentRule: TJobRule;
begin
  RuleRel := TRuleRuleRel.Create(FDBEngine);
  RuleRel.ChildRule := TJobRule.Create(FDBEngine);
  RuleRel.ChildRule.Link := TJobLink.Create(FDBEngine);

  ParentRule := ViewRules.GetSelectedRule;
  ParentRule.ChildRuleRels.Add(RuleRel);

  ViewRules.AddRuleToTree(ParentRule, RuleRel.ChildRule);
end;

procedure TController.AddLink;
var
  Level: TJobLevel;
  RuleRel: TLevelRuleRel;
begin
  RuleRel := TLevelRuleRel.Create(FDBEngine);
  RuleRel.Rule := TJobRule.Create(FDBEngine);
  RuleRel.Rule.Link := TJobLink.Create(FDBEngine);

  Level := ViewRules.GetSelectedLevel;
  Level.RuleRels.Add(RuleRel);

  ViewRules.AddRuleToTree(nil, RuleRel.Rule);
end;

procedure TController.AddChildRecord;
var
  RuleRel: TRuleRuleRel;
  ParentRule: TJobRule;
begin
  RuleRel := TRuleRuleRel.Create(FDBEngine);
  RuleRel.ChildRule := TJobRule.Create(FDBEngine);
  RuleRel.ChildRule.Rec := TJobRecord.Create(FDBEngine);

  ParentRule := ViewRules.GetSelectedRule; 
  ParentRule.ChildRuleRels.Add(RuleRel);

  ViewRules.AddRuleToTree(ParentRule, RuleRel.ChildRule);
end;

procedure TController.AddRecord;
var
  RuleRel: TLevelRuleRel;
begin
  RuleRel := TLevelRuleRel.Create(FDBEngine);
  RuleRel.Rule := TJobRule.Create(FDBEngine);
  RuleRel.Rule.Rec := TJobRecord.Create(FDBEngine);

  ViewRules.GetSelectedLevel.RuleRels.Add(RuleRel);
  ViewRules.AddRuleToTree(nil, RuleRel.Rule);
end;

procedure TController.GetJobList;
var
  JobList: TJobList;
begin
  JobList := TJobList.Create(FDBEngine, [], []);
  try
    ViewMain.SetJobsGrid(JobList);
  finally
    FreeAndNil(JobList);
  end;
end;

procedure TController.EditJobRules;
var
  Job: TJob;
  Levels: TEntityList<TJobLevel>;
  Level: TJobLevel;
begin
  Job := TJob.Create(FDBEngine, ViewMain.SelectedJobID);
  FObjData.AddOrSetValue('Job', Job);

  Levels := Job.Levels;
  if Levels.Count = 0 then
    begin
      Level := TJobLevel.Create(FDBEngine, 0);
      Level.Level := 1;
      Level.BaseLink := Job.ZeroLink;
      Levels.Add(Level);
    end;

  CallView(TViewRules);
  ViewRules.chrmBrowser.OnProcessMessageReceived := crmProcessMessageReceived;
  ViewRules.chrmBrowser.OnLoadEnd := crmLoadEnd;
  ViewRules.SetLevels(GetJob.Levels);
end;

procedure TController.StoreJobRules;
var
  Job: TJob;
begin
  Job := FObjData.Items['Job'] as TJob;
  Job.SaveAll;
  ViewRules.Close;
end;

procedure TController.EventListener(aEventMsg: string);
begin
  if aEventMsg = 'OnTestLinkPrepared' then
    begin
      if FData.Items['TestStepRest'] = 0 then
        FGettingTestPage := False;

      ViewRules.chrmBrowser.Load(FData.Items['URL']);
    end;

  if aEventMsg = 'OnJSScriptPrepared' then
    ViewRules.chrmBrowser.Browser.MainFrame.ExecuteJavaScript(FData.Items['JSScript'], 'about:blank', 0);
end;

procedure TController.PerfomViewMessage(aMsg: string);
begin
  if aMsg = 'SelectNewLevelLink' then
      FSelectNewLevelLink := True;

  if aMsg = 'ViewRulesClosed' then
    begin
      FObjData.Items['Job'].Free;
    end;

  if aMsg = 'StartJob' then
    begin
      FData.AddOrSetValue('JobID', ViewMain.SelectedJobID);
      FData.AddOrSetValue('JSScript', FJSScript);
      FObjData.AddOrSetValue('Chromium', ViewMain.chrmBrowser);
      CallModel(TModelParser, 'StartJob');
    end;
end;

procedure TController.InitDB;
begin
  FConnectOnCreate := True;
  FConnectParams.DataBase := GetCurrentDir + '\DB\local.db';
  FDBEngineClass := TSQLiteEngine;

  FJSScript := TFilesEngine.GetTextFromFile(GetCurrentDir + '\JS\DOMParser.js');
  FData.AddOrSetValue('JSScript', FJSScript);
end;

{ TCustomRenderProcessHandler }
procedure TCustomRenderProcessHandler.OnWebKitInitialized;
begin
  TCefRTTIExtension.Register('app', TJSExtension);
end;

{ TTestExtension }
class procedure TJSExtension.selectdataback(const data: string);
var
  msg: ICefProcessMessage;
begin
  msg := TCefProcessMessageRef.New('selectdataback');
  msg.ArgumentList.SetString(0, data);
  TCefv8ContextRef.Current.Browser.SendProcessMessage(PID_BROWSER, msg);
end;

class procedure TJSExtension.parsedataback(const data: string);
var
  msg: ICefProcessMessage;
begin
  msg := TCefProcessMessageRef.New('parsedataback');
  msg.ArgumentList.SetString(0, data);
  TCefv8ContextRef.Current.Browser.SendProcessMessage(PID_BROWSER, msg);
end;

initialization
  CefRenderProcessHandler := TCustomRenderProcessHandler.Create;

end.
