unit cController;

interface

uses
  System.JSON,
  API_MVC,
  API_MVC_DB,
  API_DB_SQLite,
  cefvcl,
  cefLib,
  mParser,

  eJob,
  eLevel,
  eRule,
  eRuleLink,
  eRuleRecords,
  eRuleCut,
  eRuleAction,
  eRegExp,
  eNodes,
  eRequest;

type
  TJSExtension = class
    class procedure selectdataback(const data: string);
    class procedure parsedataback(const data: string);
    class procedure fullnodestreeback(const data: string);
    class procedure observerevent(const data: string);
  end;

  TCustomRenderProcessHandler = class(TCefRenderProcessHandlerOwn)
  protected
    procedure OnWebKitInitialized; override;
  end;

  TController = class(TControllerDB)
  private
    FJSProcessingScript: string;
    FModelParser: TModelParser;
    {inside Controller logic procedures, functions, variables
     functions have to be a verb with "Get" prefix
     procedures have to be a verb with "Do" prefix
    }
    function GetJob: TJob;
    function GetFullTreeScript(aNodeKeyID: integer): string;
    procedure DoCreateModelParser;
    procedure DoProcessSelectedNodes(aNodesData: string);
    procedure DoProcessNodesFullTree(aData: string);
    ////////////////////////////////////////////////////////////////////////////
  private
    FSelectNewLevelLink: Boolean;
    FGettingTestPage: Boolean;
    JobStates: TArray<TJobState>;

    {procedure crmLoadEnd(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
    //procedure ParseDataReceived(aData: string);}

    procedure SyncParentChildRuleNodes(aNodes, aParentNodes: TNodeList);
    procedure UpdateJobState(aJobID: integer);
    function CanAddLevel(aJobRule: TJobLink): Boolean;
    function AddRule: TJobRule;
  protected
    procedure InitDB; override;
    procedure PerfomViewMessage(aMsg: string); override;
    procedure EventListener(aEventMsg: string); override;
  published
    { procedures assign with View message call
      have to be verb phrase, for example
      ORM:
        AddSomeEntity - creation entities
        RemoveSomeEntity - removing entities
        EditSomeEntity - edition entities
      Events:
        OnSomeEntitySelected - when entity assign control selected in the View GUI
        OnSomeModelStopped - when Model event fire

      these procedures are for
      ORM munipulations with entities
      Models calls
      Views calls
      single call View interface

      Controller have to be thin!
    }
    procedure EditExportFields;
    ////////////////////////////////////////////////////////////////////////////

    procedure EditJobRules;

    procedure LevelSelected;
    procedure RunLevelTest;

    procedure RuleSelected;

    procedure TestAction;

    procedure GetJobList;

    procedure CreateJob;
    procedure StoreJob;

    // Manage Job Rules
    procedure StoreJobRules;
    procedure StoreExportFields;

    // Events
    procedure OnNodeSelected;
    procedure OnTestPageLoaded;

    procedure CreateLevel(frame: ICefFrame);
    procedure DeleteLevel;

    // Rule Creating
    procedure AddContainer;
    procedure AddLink;
    procedure AddCut;
    procedure AddRecord;
    procedure AddAction;
    procedure AddRegExp;
    procedure AddRequest;
    procedure AddExportField;
    procedure AddExportFieldCustom;

    // Rule Removing
    procedure RemoveRule;
    procedure RemoveRegExp;
    procedure RemoveRequest;
    procedure RemoveExportField;

    // Nodes
    procedure AssignNodeToRule;

    procedure SelectHTMLNode;

    procedure ClearJobLinks;

    // Testing
    procedure GetNextTestPage;

    // Exports
    procedure ExportJobResultsToCSV;

    procedure TempCopy;

    // Start/Stop Job
    procedure StartJob;
    procedure StopJob;
    procedure OnJobDone;

    procedure UpdateProcessInfo;

    // DB Services
    procedure DBVacuum;
    procedure DBClearSeq;
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
  vExportFields,
  mTester,
  mExport,
  mNodes,

  FireDAC.Comp.Client,
  eTestLink,
  eExportField;

procedure TController.AddExportFieldCustom;
var
  ExportField: TExportField;
begin
  ExportField := TExportField.Create(FDBEngine);
  ExportField.Title := 'Enter Field Title';
  ExportField.OrderNum := GetJob.ExportFields.Count + 1;
  ExportField.IsEnabled := True;

  GetJob.ExportFields.Add(ExportField);
  ViewExportFields.InsertExportField(ExportField);
end;

procedure TController.RemoveExportField;
begin
  GetJob.ExportFields.DeleteByEntity(ViewExportFields.SelectedExportField);

  ViewExportFields.RemoveExportField;
end;

procedure TController.StoreExportFields;
begin
  GetJob.ExportFields.SaveList(GetJob.ID);
end;

procedure TController.AddExportField;
var
  ExportField: TExportField;
begin
  ExportField := TExportField.Create(FDBEngine);
  ExportField.RuleRecID := ViewExportFields.SelectedRuleRec.ID;
  ExportField.Title := ViewExportFields.SelectedRuleRec.Key;
  ExportField.OrderNum := GetJob.ExportFields.Count + 1;
  ExportField.IsEnabled := True;

  GetJob.ExportFields.Add(ExportField);
  ViewExportFields.InsertExportField(ExportField);
end;

procedure TController.EditExportFields;
var
  Job: TJob;
  RecList: TJobRecordList;
begin
  Job := TJob.Create(FDBEngine, ViewMain.SelectedJobID);
  FObjData.AddOrSetValue('Job', Job);

  CallView(TViewExportFields);

  RecList := Job.CreateRuleRecFullList;
  ViewExportFields.RenderRuleRecKeys(RecList);
  ViewExportFields.RenderExportFields(Job.ExportFields);
end;

procedure TController.RunLevelTest;
begin
  FData.AddOrSetValue('ParseMode', pmLevelRunTest);
  FData.AddOrSetValue('JSScript', FJSProcessingScript);
  FObjData.AddOrSetValue('Chromium', ViewMain.chrmBrowser);

  CallAsyncModel(TModelParser, 'Start');
end;

procedure TController.LevelSelected;
begin
  FData.AddOrSetValue('Level', ViewRules.GetSelectedLevel.Level);
  FData.AddOrSetValue('URL', ViewRules.GetSelectedLevel.TestLink);
  FModelParser.LoadLevelTest;
end;

procedure TController.DoCreateModelParser;
begin
  FData.AddOrSetValue('JSScript', FJSProcessingScript);
  FData.AddOrSetValue('ParseMode', pmLevelDesign);

  FObjData.AddOrSetValue('DBEngine', FDBEngine);
  FObjData.AddOrSetValue('Chromium', ViewRules.chrmBrowser);
  FObjData.AddOrSetValue('Job', GetJob);

  FModelParser := TModelParser.Create(FData, FObjData);
  FModelParser.OnEvent := Self.EventListener;
  FModelParser.Start;
end;

procedure TController.AssignNodeToRule;
var
  Wrap: TWrapModelNodes;
  jsnNodes: TJSONArray;
begin
  Wrap := TWrapModelNodes.Create;
  try
    Wrap.NodesChain := ViewRules.GetSelectedNodesChain;
    FObjData.AddOrSetValue('NodesChain', Wrap);
    CallModel(TModelNodes, 'GetJSONNodesChain');

    jsnNodes := FObjData.Items['JSONNodesChain'] as TJSONArray;
    DoProcessSelectedNodes(jsnNodes.ToJSON);
  finally
    Wrap.Free;
    jsnNodes.Free;
  end;
end;

function TController.GetFullTreeScript(aNodeKeyID: integer): string;
begin
  Result := TFilesEngine.GetTextFromFile(GetCurrentDir + '\JS\DOMFullTree.js');
  FData.AddOrSetValue('JSScript', Result);
  FData.AddOrSetValue('NodeKeyID', aNodeKeyID);
  CallModel(TModelJS, 'PrepareFullTreeScript');
  Result := FData.Items['JSScript'];
end;

procedure TController.OnNodeSelected;
var
  InjectJS: string;
begin
  InjectJS := GetFullTreeScript(ViewRules.SelectedNodeKeyID);
  ViewRules.chrmBrowser.Browser.MainFrame.ExecuteJavaScript(InjectJS, 'about:blank', 0);
end;

procedure TController.RemoveRequest;
var
  ParentRule: TJobRule;
begin
  ParentRule := ViewRules.GetParentEntity as TJobRule;
  ParentRule.DeleteOneRelation(ParentRule.Request);

  ViewRules.RemoveTreeNode;
end;

procedure TController.AddRequest;
var
  JobRequest: TJobRequest;
begin
  JobRequest := TJobRequest.Create(FDBEngine);
  JobRequest.TimeOut := 3000;
  ViewRules.GetSelectedRule.Request := JobRequest;

  ViewRules.AddRequestToTree(ViewRules.tvRules.Selected, JobRequest);
end;

procedure TController.DoProcessNodesFullTree(aData: string);
var
  jsnNodes: TJSONObject;
  WrapObj: TWrapModelNodes;
begin
  jsnNodes := TJSONObject.ParseJSONValue(aData) as TJSONObject;
  try
    FObjData.AddOrSetValue('jsnDOMFullTree', jsnNodes);
    FObjData.AddOrSetValue('RuleNodeList', ViewRules.GetSelectedRule.Nodes);

    CallModel(TModelNodes, 'GetVirtualNodeTree');

    WrapObj := FObjData.Items['VirtualDOMTree'] as TWrapModelNodes;
    try
      ViewRules.RenderNodesTree(WrapObj.VirtualDOMTree);
    finally
      WrapObj.Free;
    end;
  finally
    jsnNodes.Free;
  end;
end;

function TController.AddRule: TJobRule;
var
  ParentRule: TJobRule;
  RuleRel: TRuleRuleRel;
begin
  RuleRel := TRuleRuleRel.Create(FDBEngine);
  RuleRel.ChildRule := TJobRule.Create(FDBEngine);
  RuleRel.ChildRule.SourceTypeID := 1;
  RuleRel.ChildRule.IsEnabled := True;

  ParentRule := ViewRules.GetSelectedRule;
  ParentRule.ChildRuleRels.Add(RuleRel);

  Result := RuleRel.ChildRule;
end;

procedure TController.AddAction;
var
  Rule: TJobRule;
begin
  Rule := AddRule;
  Rule.Action := TJobAction.Create(FDBEngine);
  Rule.Action.Delay := 1000;
  Rule.Action.ExecuteAfterLoad := True;

  ViewRules.AddRuleToTree(ViewRules.GetSelectedRule, Rule);
end;

procedure TController.AddContainer;
var
  Rule: TJobRule;
begin
  Rule := AddRule;
  ViewRules.AddRuleToTree(ViewRules.GetSelectedRule, Rule);
end;

procedure TController.OnJobDone;
begin

end;

procedure TController.DBVacuum;
var
  dsQuery: TFDQuery;
begin
  dsQuery := TFDQuery.Create(nil);
  try
    dsQuery.SQL.Text := 'vacuum;';
    FDBEngine.ExecQuery(dsQuery);
  finally
    dsQuery.Free;
  end;
end;

procedure TController.DBClearSeq;
var
  dsQuery: TFDQuery;
  Tables: TArray<string>;
  Table: string;
begin
  Tables := Tables + ['groups'];
  Tables := Tables + ['links'];
  Tables := Tables + ['records'];
  Tables := Tables + ['jobs'];
  Tables := Tables + ['link2link'];
  Tables := Tables + ['job_level2rule'];
  Tables := Tables + ['job_levels'];
  Tables := Tables + ['job_nodes'];
  Tables := Tables + ['job_regexps'];
  Tables := Tables + ['job_rule2rule'];
  Tables := Tables + ['job_rules'];
  Tables := Tables + ['job_rule_cuts'];
  Tables := Tables + ['job_rule_links'];
  Tables := Tables + ['job_rule_records'];
  Tables := Tables + ['job_test_links'];

  dsQuery := TFDQuery.Create(nil);
  try
    dsQuery.SQL.Text := 'delete from SQLITE_SEQUENCE where name = :table;';

    for Table in Tables do
      begin
        dsQuery.ParamByName('table').AsString := Table;
        FDBEngine.ExecQuery(dsQuery);
      end;
  finally
    dsQuery.Free;
  end;
end;

procedure TController.UpdateProcessInfo;
var
  JobState: TJobState;
begin
  for JobState in JobStates do
    begin
      if JobState.StateID = 1 then
        begin
          FData.AddOrSetValue('JobID', JobState.JobID);
          CallModel(TModelParser, 'GetJobProgress');

          ViewMain.SetJobProgressInfo(JobState.JobID, FData.Items['HandledCount'], FData.Items['TotalCount']);
        end;
    end;
end;

procedure TController.UpdateJobState(aJobID: integer);
var
  HasFound: Boolean;
  JobState: TJobState;
  i: Integer;
begin
  HasFound := False;
  for i := 0 to High(JobStates) do
    begin
      JobState := JobStates[i];
      if JobState.JobID = aJobID then
        begin
          JobState.StateID := 1;
          HasFound := True;
          Break;
        end;
    end;

  if not HasFound then
    begin
      JobState.JobID := aJobID;
      JobState.StateID := 1;
      JobStates := JobStates + [JobState];
    end;
end;

procedure TController.StartJob;
var
  JobID: Integer;
begin
  JobID := ViewMain.SelectedJobID;
  UpdateJobState(JobID);

  FData.AddOrSetValue('JSScript', FJSProcessingScript);
  FData.AddOrSetValue('ParseMode', pmJobRun);
  FData.AddOrSetValue('IsJobStopped', False);

  FObjData.AddOrSetValue('Chromium', ViewMain.chrmBrowser);
  FObjData.AddOrSetValue('Job', TJob.Create(FDBEngine, JobID));

  CallAsyncModel(TModelParser, 'Start');
end;

procedure TController.StopJob;
begin
  FData.AddOrSetValue('IsJobStopped', True);
end;

procedure TController.TestAction;
var
  InjectJS: string;
begin
  FData.AddOrSetValue('IsSkipActions', False);
  RuleSelected;
  FData.AddOrSetValue('IsSkipActions', True);
end;

procedure TController.TempCopy;
var
  TargerRule, SourceRule, NewRule: TJobRule;
  NewRuleRel: TRuleRuleRel;
begin
  TargerRule := TJobRule.Create(FDBEngine, 7439);
  SourceRule := TJobRule.Create(FDBEngine, 7469);
  NewRule := TJobRule.Create(FDBEngine, 0);
  NewRuleRel := TRuleRuleRel.Create(FDBEngine);
  try
    NewRule.Assign(SourceRule);
    NewRuleRel.ChildRule := NewRule;

    TargerRule.ChildRuleRels.Add(NewRuleRel);

    TargerRule.SaveAll;
  finally
    TargerRule.Free;
    SourceRule.Free;
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
  FData.AddOrSetValue('JSScript', FJSProcessingScript);
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
    dsQuery.SQL.Text := 'delete from groups where job_id = :jobid';
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
          //and (Node.Index = LastParentNode.Index)
          and (Node.TagID = LastParentNode.TagID)
          and (
               (Node.ClassName.Contains(LastParentNode.ClassName))
            or (Node.ClassName.IsEmpty and LastParentNode.ClassName.IsEmpty)
          )
          and (Node.Name = LastParentNode.Name)

          or (Node.Tag = 'HTML')
          or (Node.Tag = 'BODY')
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

  ViewRules.AddRegExpToTree(ViewRules.tvRules.Selected, RegExp);
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
  ViewRules.RenderLevels(GetJob.Levels);
end;

procedure TController.RuleSelected;
var
  InjectJS: string;
  IsSkipActions: Variant;
begin
  FData.AddOrSetValue('JSScript', FJSProcessingScript);

  if not FData.TryGetValue('IsSkipActions', IsSkipActions) then
    FData.AddOrSetValue('IsSkipActions', True);

  FObjData.AddOrSetValue('Rule', ViewRules.GetSelectedRule);

  FModelParser.ExecuteRuleJS;

  InjectJS := GetFullTreeScript(0);
  ViewRules.ExecuteJavaScript(InjectJS);

  //FData.AddOrSetValue('CanAddLevel', CanAddLevel(ViewRules.GetSelectedRule.Link));
end;

{procedure TController.ParseDataReceived(aData: string);
begin
  if Assigned(FLastParseResult) then FreeAndNil(FLastParseResult);
  FLastParseResult := TJSONObject.ParseJSONValue(aData) as TJSONObject;

  if FGettingTestPage then
    begin
      FData.AddOrSetValue('DataReceived', aData);
      CallModel(TModelTester, 'ProcessDataRecieved');
    end;
end; }

{procedure TController.crmLoadEnd(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
var
  InjectJS: string;
begin
  if not frame.IsMain or (httpStatusCode <> 200) then Exit;

  ViewRules.chrmBrowser.Enabled := True;

  FCatchingRequests := True;

  InjectJS := TFilesEngine.GetTextFromFile(GetCurrentDir + '\JS\jquery-3.1.1.js');
  ViewRules.chrmBrowser.Browser.MainFrame.ExecuteJavaScript(InjectJS, '', 0);

  if FSelectNewLevelLink then
    begin
      CreateLevel(frame);
      FSelectNewLevelLink := False;
    end;

  if FGettingTestPage then OnTestPageLoaded;

  //debug
  //ViewRules.tvRules.Select(ViewRules.tvRules.Items[0]);
end;}

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
  ViewRules.RenderLevels(GetJob.Levels, GetJob.Levels.Count - 1);
end;

procedure TController.DoProcessSelectedNodes(aNodesData: string);
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
      if ParentRule.Nodes.Count = 0 then ParentRule := ViewRules.GetParentParentEntity as TJobRule;

      SyncParentChildRuleNodes(Rule.Nodes, ParentRule.Nodes);
    end;

  if Assigned(jsnNodes) then jsnNodes.Free;
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

      ViewRules.RemoveTreeNode;
    end;
end;

procedure TController.RemoveRegExp;
var
  ParentRule: TJobRule;
begin
  ParentRule := ViewRules.GetParentEntity as TJobRule;
  ParentRule.RegExps.DeleteByEntity(ViewRules.GetSelectedRegExp);

  ViewRules.RemoveTreeNode;
end;

procedure TController.AddCut;
var
  Rule: TJobRule;
begin
  Rule := AddRule;
  Rule.Cut := TJobCut.Create(FDBEngine);

  ViewRules.AddRuleToTree(ViewRules.GetSelectedRule, Rule);
end;

procedure TController.AddLink;
var
  Rule: TJobRule;
begin
  Rule := AddRule;
  Rule.Link := TJobLink.Create(FDBEngine);

  ViewRules.AddRuleToTree(ViewRules.GetSelectedRule, Rule);
end;

procedure TController.AddRecord;
var
  Rule: TJobRule;
begin
  Rule := AddRule;
  Rule.Rec := TJobRecord.Create(FDBEngine);
  Rule.Rec.GrabTypeID := 1;

  ViewRules.AddRuleToTree(ViewRules.GetSelectedRule, Rule);
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
      Level := TJobLevel.Create(FDBEngine);
      Level.Level := 1;
      Level.BaseLink := Job.ZeroLink;
      Levels.Add(Level);
    end;

  CallView(TViewRules);
  DoCreateModelParser;

  ViewRules.RenderLevels(GetJob.Levels);
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
  if aEventMsg = 'OnLevelTestOver' then
    ViewRules.edtTestTime.Text := IntToStr(FData.Items['LevelTestTime']);

  if aEventMsg = 'OnSelectedNodesReceived' then
    DoProcessSelectedNodes(FData.Items['SelectedNodes']);

  if aEventMsg = 'OnNodesFullTreeReceived' then
    DoProcessNodesFullTree(FData.Items['NodesFullTree']);

  if aEventMsg = 'OnViewResultsReceived' then
    ViewRules.RenderViewResults((FObjData.Items['ViewResults'] as TWrapViewResults).ViewResults);

  if aEventMsg = 'OnJobDone' then OnJobDone;

  if aEventMsg = 'OnTestLinkPrepared' then
    begin
      if FData.Items['TestStepRest'] = 0 then
        FGettingTestPage := False;

      ViewRules.chrmBrowser.Load(FData.Items['URL']);
    end;
end;

procedure TController.PerfomViewMessage(aMsg: string);
begin
  if aMsg = 'SelectNewLevelLink' then
      FSelectNewLevelLink := True;

  // on close none modal views clear objects
  if aMsg = 'ViewRulesClosed' then
    begin
      FModelParser.Stop;
      FObjData.Items['Job'].Free;
    end;
  if aMsg = 'ViewExportFieldsClosed' then
    FObjData.Items['Job'].Free;
end;

procedure TController.InitDB;
begin
  FConnectOnCreate := True;
  FConnectParams.DataBase := GetCurrentDir + '\DB\local.db';
  FDBEngineClass := TSQLiteEngine;

  FJSProcessingScript := TFilesEngine.GetTextFromFile(GetCurrentDir + '\JS\DOMProcessing.js');
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

class procedure TJSExtension.fullnodestreeback(const data: string);
var
  msg: ICefProcessMessage;
begin
  msg := TCefProcessMessageRef.New('fullnodestreeback');
  msg.ArgumentList.SetString(0, data);
  TCefv8ContextRef.Current.Browser.SendProcessMessage(PID_BROWSER, msg);
end;

class procedure TJSExtension.observerevent(const data: string);
var
  msg: ICefProcessMessage;
begin
  msg := TCefProcessMessageRef.New('observerevent');
  msg.ArgumentList.SetString(0, data);
  TCefv8ContextRef.Current.Browser.SendProcessMessage(PID_BROWSER, msg);
end;

initialization
  CefRenderProcessHandler := TCustomRenderProcessHandler.Create;

end.
