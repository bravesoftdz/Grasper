unit mParser;

interface

uses
  System.JSON,
  System.UITypes,
  System.Threading,
  Vcl.ExtCtrls,
  cefvcl,
  cefLib,
  API_MVC_DB,
  eJob,
  eLevel,
  eRule,
  eNodes,
  eRegExp,
  eLink,
  eRecord,
  eRequest;

type
  TViewResult = record
    Key: string;
    Value: string;
  end;

  TViewGroup = record
    Group: Integer;
    Results: TArray<TViewResult>;
  end;

  TViewResults = TArray<TViewGroup>;

  TWrapViewResults = class
  public
    ViewResults: TViewResults
  end;

  TGroupBind = record
    DataGroupNum: Integer;
    GroupID: Integer;
  end;

  TScriptFor = (sfEditor, sfLoadEnd, sfRequestEnd, sfTriggerExecute);

  TParseMode = (pmJobRun, pmLevelDesign, pmLevelRunTest);

  TState = (sWaitingReplay, sDone, sWaitingTriger);

  TRequestState = record
    RequestID: Integer;
    TimeOut: Integer;
    State: TState;
  end;

  TModelJS = class(TModelDB)
  private
    FScriptFor: TScriptFor;
    FRootRule: TJobRule;
    FRootRuleNodeList: TNodeList;
    function ColorToHex(color: TColor): String;
    function EncodeNodesToJSON(aNodeList: TNodeList): TJSONArray;
    function EncodeRegExpsToJSON(aRegExpList: TJobRegExpList): TJSONArray;
    function EncodeRequestToJSON(aJobRequest: TJobRequest): TJSONObject;
    function CreateRootRuleNodeList(aBodyRule, aRootRule: TJobRule): TNodeList;
    procedure AddRuleToJSON(aRule: TJobRule; ajsnArray: TJSONArray);
    procedure AddNodesToRootRuleNodeList(aRootRuleNodeList: TNodeList; aRule: TJobRule);
  published
    procedure PrepareProcessingScript;
    procedure PrepareFullTreeScript;
  end;

  TModelParser = class(TModelDB)
  private
    FParseMode: TParseMode;
    FJob: TJob;
    FCurrLink: TLink;
    FLevel: TJobLevel;
    FChromium: TChromium;

    FIsWaitingForRequests: Boolean;
    FRequestStates: TArray<TRequestState>;

    FGroupBinds: TArray<TGroupBind>;

    // Chromium Events
    procedure crmLoadEnd(Sender: TObject; const browser: ICefBrowser;
        const frame: ICefFrame; httpStatusCode: Integer);
    procedure crmBeforePopup(Sender: TObject; const browser: ICefBrowser;
        const frame: ICefFrame; const targetUrl, targetFrameName: ustring;
        targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
        var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
        var client: ICefClient; var settings: TCefBrowserSettings;
        var noJavascriptAccess: Boolean; out Result: Boolean);
    procedure crmProcessMessageReceived(Sender: TObject;
            const browser: ICefBrowser; sourceProcess: TCefProcessId;
            const message: ICefProcessMessage; out Result: Boolean);

    procedure ProcessNextLink(aPrivLinkHandled: Integer = 2);
    procedure ProcessDataReceived(aData: string);
    procedure ProcessObserveEvent(aStrRuleID: string);
    procedure ProcessTrigerAction(aRequestID: integer);

    procedure SetCurrLinkHandle(aValue: Integer);

    function GetRequestStates: TArray<TRequestState>;
    procedure SetRequestState(aReqID: integer; aState: TState);
    procedure StartRequestTimeOut;
    procedure StartLoadTimeOut;

    function GetNextLink: TLink;
    function AddGroup(aParentGroupID: Integer): Integer;
    function AddLink(aLink: string; aParentLinkID, aLevel, aGroupID: Integer): Boolean;
    function AddRecord(aLinkId, aGroupID: integer; aKey, aValue: string): Boolean;
    procedure AddError(aLinkID, aErrTypeID: Integer; aErrText: string);
    function GetGroupID(var aGroupBinds: TArray<TGroupBind>; aDataGroupNum, aDataParentGroupNum: Integer): Integer;
    function GetLinksCount(aJobID: Integer; aHandled: Integer = -1): Integer;
  private
    FViewResults: TViewResults;
    FLevelTestTime: TDateTime;

    FLoadTimeOut: TTimer;
    FLastLoadStartTime: TDateTime;
    FLastLoadTime: Integer;

    FRequestTimeOut: TTimer;
    FLastRequestStartTime: TDateTime;
    FLastRequestTime: Integer;
    {inside Model logic procedures, functions, variables
     functions have to be a verb with "Get", "Try" prefix
     procedures have to be a verb with "Do" prefix
    }
    function TryAddViewResult(aGroupNum: Integer; aKey, aValue: string): Boolean;
    function GetViewGroup(aGroupNum: integer; out aGroupIndex: integer): TViewGroup;
    function GetViewResult(aViewGroup: TViewGroup; aKey, aValue: string): TViewResult;
    procedure DoLoadPage;
    procedure DoProcessJScript(aScriptFor: TScriptFor; aRule: TJobRule = nil);
    procedure DoCreateEventOnViewResultsReceived;
    procedure DoStopLevelTestRun;
    procedure DoRequestTimeOut(Sender: TObject);
    procedure OnLoadTimeOut(Sender: TObject);
    ////////////////////////////////////////////////////////////////////////////
  published
    {public Model interface that can be called via Controller.CallModel
     simple parametrs have to be put into FData object
     objects parametrs have to be put into FobjData object
    }
    procedure Start;
    procedure Stop;
    procedure GetJobProgress;
    procedure LoadLevelTest;
    procedure ExecuteRuleJS;
    ////////////////////////////////////////////////////////////////////////////
  end;

implementation

uses
  Vcl.Dialogs,
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.Hash,
  System.DateUtils,
  Math,
  FireDAC.Comp.Client,
  API_Files,
  eError,
  eGroup,
  eRuleAction;

procedure TModelParser.StartLoadTimeOut;
begin
  FLoadTimeOut.Interval := 20000;
  FLastLoadStartTime := Now;
  FLoadTimeOut.Enabled := True;
end;

procedure TModelParser.OnLoadTimeOut(Sender: TObject);
begin
  FLastLoadTime := MilliSecondsBetween(FLastLoadStartTime, Now);

  case FParseMode of
    pmJobRun:
      begin
        AddError(FCurrLink.ID, 5, 'Page Load Time Out');

        ProcessNextLink(3);
      end;
    pmLevelRunTest: DoStopLevelTestRun;
  end;
end;

procedure TModelParser.DoStopLevelTestRun;
begin
  FData.AddOrSetValue('LevelTestTime', MilliSecondsBetween(Now, FLevelTestTime));
  CreateEvent('OnLevelTestOver');
  DoCreateEventOnViewResultsReceived;
  Stop;
end;

procedure TModelParser.DoCreateEventOnViewResultsReceived;
var
  WrapViewResults: TWrapViewResults;
begin
  WrapViewResults := TWrapViewResults.Create;
  try
    WrapViewResults.ViewResults := FViewResults;
    FObjData.AddOrSetValue('ViewResults', WrapViewResults);
    CreateEvent('OnViewResultsReceived');
  finally
    WrapViewResults.Free;
  end;
end;

function TModelParser.GetViewResult(aViewGroup: TViewGroup; aKey, aValue: string): TViewResult;
var
  ViewResult: TViewResult;
begin
  for ViewResult in aViewGroup.Results do
    if    (ViewResult.Key = aKey)
      and (ViewResult.Value = aValue)
    then
      Exit(ViewResult);

  Result.Key := '';
  Result.Value := '';
end;

function TModelParser.GetViewGroup(aGroupNum: integer; out aGroupIndex: integer): TViewGroup;
var
  ViewGroup: TViewGroup;
begin
  aGroupIndex := -1;
  for ViewGroup in FViewResults do
    begin
      Inc(aGroupIndex);
      if ViewGroup.Group = aGroupNum then
        begin
          Exit(ViewGroup);
        end;
    end;

  Result.Group := aGroupNum;
  FViewResults := FViewResults + [Result];
  aGroupIndex := High(FViewResults);
end;

function TModelParser.TryAddViewResult(aGroupNum: Integer; aKey, aValue: string): Boolean;
var
  VGroup: TViewGroup;
  GroupIndex: Integer;
  ViewResult: TViewResult;
begin
  // find view group
  VGroup := GetViewGroup(aGroupNum, GroupIndex);

  // find view result
  ViewResult := GetViewResult(VGroup, aKey, aValue);

  if not ViewResult.Key.IsEmpty then
    Result := False
  else
    begin
      ViewResult.Key := aKey;
      ViewResult.Value := aValue;

      VGroup.Results := VGroup.Results + [ViewResult];
      FViewResults[GroupIndex] := VGroup;
      Result := True;
    end;
end;

procedure TModelParser.ExecuteRuleJS;
var
  Rule: TJobRule;
  IsSkipAction: Boolean;
begin
  Rule := FObjData.Items['Rule'] as TJobRule;
  FViewResults := [];
  DoProcessJScript(sfEditor, Rule);
end;

procedure TModelParser.LoadLevelTest;
begin
  FLevelTestTime := Now;

  if Assigned(FCurrLink) then FreeAndNil(FCurrLink);
  FCurrLink := TLink.Create(FDBEngine);
  FCurrLink.Level := FData.Items['Level'];
  FCurrLink.Link := FData.Items['URL'];

  DoLoadPage;
end;

procedure TModelParser.DoLoadPage;
begin
  FLevel := FJob.GetLevel(FCurrLink.Level);
  FRequestStates := GetRequestStates;
  FGroupBinds := [];

  if    (FParseMode in [pmJobRun, pmLevelRunTest])
    and (FLoadTimeOut.Enabled = False)
  then
    StartLoadTimeOut;

  FChromium.Load(FCurrLink.Link);
end;

procedure TModelParser.crmBeforePopup(Sender: TObject; const browser: ICefBrowser;
    const frame: ICefFrame; const targetUrl, targetFrameName: ustring;
    targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
    var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
    var client: ICefClient; var settings: TCefBrowserSettings;
    var noJavascriptAccess: Boolean; out Result: Boolean);
begin
  Result := True;
  FIsWaitingForRequests := True;
  StartLoadTimeOut;
  TChromium(Sender).Load(targetUrl);
end;

procedure TModelJS.PrepareFullTreeScript;
var
  JSScript: string;
  NodeKeyID: Integer;
  jsnConfig: TJSONObject;
begin
  JSScript := FData.Items['JSScript'];
  NodeKeyID := FData.Items['NodeKeyID'];

  jsnConfig := TJSONObject.Create;
  try

    jsnConfig.AddPair('node_key_id', TJSONNumber.Create(NodeKeyID));

    if NodeKeyID > 0 then
      jsnConfig.AddPair('need_data_back', TJSONBool.Create(False))
    else
      jsnConfig.AddPair('need_data_back', TJSONBool.Create(True));

    JSScript := Format(JSScript, [jsnConfig.ToJSON]);
    FData.AddOrSetValue('JSScript', JSScript);
  finally
    jsnConfig.Free;
  end;
end;

procedure TModelParser.SetRequestState(aReqID: integer; aState: TState);
var
  i: Integer;
begin
  for i := 0 to Length(FRequestStates) - 1 do
    if FRequestStates[i].RequestID = aReqID then
      begin
        FRequestStates[i].State := aState;
        Exit;
      end;
end;

procedure TModelParser.DoRequestTimeOut(Sender: TObject);
var
  i: Integer;
  isAnyWaitingReplay, isAnyWaitingTriger: Boolean;
begin
  FRequestTimeOut.Enabled := False;
  isAnyWaitingReplay := False;
  isAnyWaitingTriger := False;

  for i := 0 to Length(FRequestStates) - 1 do
    begin
      if FRequestStates[i].State = sWaitingReplay then
        isAnyWaitingReplay := True;

      if FRequestStates[i].State = sWaitingTriger then
        isAnyWaitingTriger := True;
    end;

  if isAnyWaitingReplay and not isAnyWaitingTriger then
    case FParseMode of
      pmJobRun: ProcessNextLink;
      pmLevelRunTest: DoStopLevelTestRun;
    end;
end;

function TModelParser.GetRequestStates: TArray<TRequestState>;
var
  LevelRequestList: TJobRequestList;
  JobRequest: TJobRequest;
  RequestState: TRequestState;
begin
  Result := [];

  LevelRequestList := FLevel.GetLevelRequestList;
  try
    for JobRequest in LevelRequestList do
      begin
        RequestState.RequestID := JobRequest.ID;
        RequestState.TimeOut := JobRequest.TimeOut;
        RequestState.State:= sWaitingReplay;
        Result := Result + [RequestState];
      end;
  finally
    LevelRequestList.Free;
  end;
end;

procedure TModelParser.StartRequestTimeOut;
var
  TimeOut: Integer;
  RequestState: TRequestState;
begin
  TimeOut := 1;
  for RequestState in FRequestStates do
    begin
      TimeOut := Max(RequestState.TimeOut, TimeOut);
    end;

  FRequestTimeOut.Interval := TimeOut;
  FRequestTimeOut.Enabled := True;
end;

procedure TModelParser.ProcessTrigerAction(aRequestID: integer);
var
  JobRequest: TJobRequest;
  TrigerActionList: TJobActionList;
  TrigerAction: TJobAction;
  ActionRule: TJobRule;
begin
  JobRequest := TJobRequest.Create(FDBEngine, aRequestID);
  TrigerActionList := JobRequest.GetTrigerActionList;
  try
    for TrigerAction in TrigerActionList do
      begin
        ActionRule := FLevel.BodyRule.GetTreeChildRuleByID(TrigerAction.JobRuleID);
        DoProcessJScript(sfTriggerExecute, ActionRule);
        SetRequestState(aRequestID, sWaitingReplay);
      end;

    if TrigerActionList.Count > 0 then
      FIsWaitingForRequests := True
    else
      FIsWaitingForRequests := False;
  finally
    JobRequest.Free;
    TrigerActionList.Free;
  end;
end;

procedure TModelJS.AddNodesToRootRuleNodeList(aRootRuleNodeList: TNodeList; aRule: TJobRule);
var
  JobNode: TJobNode;
begin
  for JobNode in aRule.Nodes do
    aRootRuleNodeList.Add(JobNode);
end;

function TModelJS.CreateRootRuleNodeList(aBodyRule, aRootRule: TJobRule): TNodeList;
var
  RuleRel: TRuleRuleRel;
  Rule: TJobRule;
  Indexes: TArray<Integer>;
  Index: Integer;
begin
  Result := TNodeList.Create(False);
  Rule := aBodyRule;
  AddNodesToRootRuleNodeList(Result, Rule);

  Indexes := aBodyRule.GetChildIndexes(aRootRule);
  for Index in Indexes do
    begin
      Rule := Rule.ChildRuleRels[Index].ChildRule;
      AddNodesToRootRuleNodeList(Result, Rule);
    end;
end;

procedure TModelParser.ProcessObserveEvent(aStrRuleID: string);
var
  RuleID: Integer;
  Rule: TJobRule;
begin
  if FParseMode = pmLevelDesign then Exit;

  RuleID := aStrRuleID.ToInteger;

  Rule := FJob.GetLevel(FCurrLink.Level).BodyRule.GetTreeChildRuleByID(RuleID);

  // not allowed body rule requests
  if Rule = nil then Exit;

  DoProcessJScript(sfRequestEnd, Rule);
end;

function TModelJS.EncodeRequestToJSON(aJobRequest: TJobRequest): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(aJobRequest.JobRuleID));
end;

function TModelParser.GetGroupID(var aGroupBinds: TArray<TGroupBind>; aDataGroupNum, aDataParentGroupNum: Integer): Integer;
var
  GroupBind: TGroupBind;
  ParentGroupID: Integer;
begin
  // searching in binds
  for GroupBind in aGroupBinds do
    if GroupBind.DataGroupNum = aDataGroupNum then
      Exit(GroupBind.GroupID);

  // if result is failed, create new bind
  // first search parent bind
  ParentGroupID := 0;
  for GroupBind in aGroupBinds do
    if GroupBind.DataGroupNum = aDataParentGroupNum then
      ParentGroupID := GroupBind.GroupID;

  // if result of parent bind failed, create new
  if ParentGroupID = 0 then
    begin
      GroupBind.GroupID := AddGroup(0);
      GroupBind.DataGroupNum := aDataParentGroupNum;
      aGroupBinds := aGroupBinds + [GroupBind];
      ParentGroupID := GroupBind.GroupID;
    end;

  // create bind
  GroupBind.GroupID := AddGroup(ParentGroupID);
  GroupBind.DataGroupNum := aDataGroupNum;
  aGroupBinds := aGroupBinds + [GroupBind];
  Exit(GroupBind.GroupID);
end;

function TModelParser.AddGroup(aParentGroupID: Integer): Integer;
var
  Group: TGroup;
begin
  Group := TGroup.Create(FDBEngine);
  try
    Group.JobID := FJob.ID;
    Group.ParentGroupID := aParentGroupID;
    Group.SaveEntity;

    Result := Group.ID;
  finally
    Group.Free;
  end;
end;

procedure TModelParser.AddError(aLinkID, aErrTypeID: Integer; aErrText: string);
var
  Error: TError;
begin
  Error := TError.Create(FDBEngine);
  try
    Error.ErrorTime := Now;
    Error.LinkID := aLinkID;
    Error.ErrorTypeID := aErrTypeID;
    Error.Text := aErrText;

    Error.SaveEntity;
  finally
    Error.Free;
  end;
end;

function TModelParser.GetLinksCount(aJobID: Integer; aHandled: Integer = -1): Integer;
var
  dsQuery: TFDQuery;
  sql: String;
begin
  dsQuery := TFDQuery.Create(nil);
  try
    sql := 'select count(*) link_count ' +
           'from links l ' +
           'join groups g on g.Id = l.group_id ' +
           'where g.job_id = :JobID %s ';

    if aHandled > -1 then sql := Format(sql, ['and l.handled = :handled'])
    else sql := Format(sql, ['']);

    dsQuery.SQL.Text := sql;
    dsQuery.ParamByName('JobID').AsInteger := aJobID;
    if aHandled > -1 then dsQuery.ParamByName('handled').AsInteger := aHandled;

    FDBEngine.OpenQuery(dsQuery);

    Result := dsQuery.FieldByName('link_count').AsInteger;
  finally
    dsQuery.Free;
  end;
end;

procedure TModelParser.GetJobProgress;
var
  JobID: Integer;
begin
  JobID := FData.Items['JobID'];

  FData.AddOrSetValue('TotalCount', GetLinksCount(JobID));
  FData.AddOrSetValue('HandledCount', GetLinksCount(JobID, 2));
end;

procedure TModelParser.Stop;
begin
  if FParseMode = pmJobRun then
    FJob.Free;

  FChromium.OnLoadEnd := nil;
  FChromium.OnBeforePopup := nil;
  FChromium.OnProcessMessageReceived := nil;

  if Assigned(FCurrLink) then FreeAndNil(FCurrLink);

  FLoadTimeOut.Free;
  FRequestTimeOut.Free;

  Self.Free;
end;

procedure TModelJS.AddRuleToJSON(aRule: TJobRule; ajsnArray: TJSONArray);
var
  jsnRule: TJSONObject;
  jsnRules: TJSONArray;
  RuleRel: TRuleRuleRel;
  Value: string;
begin
  if not aRule.IsEnabled then Exit;

  if FScriptFor = sfLoadEnd then
    begin
      if    (aRule.Action <> nil)
        and (aRule.Action.ExecuteAfterLoad = False)
      then Exit;
    end;

  jsnRule := TJSONObject.Create;
  jsnRule.AddPair('id', TJSONNumber.Create(aRule.ID));
  jsnRule.AddPair('container_offset', TJSONNumber.Create(aRule.ContainerOffset));
  jsnRule.AddPair('is_strict', TJSONBool.Create(aRule.IsStrict));
  jsnRule.AddPair('color', ColorToHex(aRule.VisualColor));
  jsnRule.AddPair('source_type', TJSONNumber.Create(aRule.SourceTypeID));

  if aRule.Link <> nil then
    begin
      jsnRule.AddPair('type', 'link');
      jsnRule.AddPair('level', TJSONNumber.Create(aRule.Link.Level));
    end;

  if (aRule.Rec <> nil) and not aRule.Rec.Key.IsEmpty then
    begin
      jsnRule.AddPair('type', 'record');
      jsnRule.AddPair('key', aRule.Rec.Key);
      jsnRule.AddPair('grab_type', TJSONNumber.Create(aRule.Rec.GrabTypeID));
    end;

  if aRule.Cut <> nil then
    jsnRule.AddPair('type', 'cut');

  if aRule.Action <> nil then
    begin
      jsnRule.AddPair('type', 'action');
      jsnRule.AddPair('act_type', TJSONNumber.Create(aRule.Action.ActionTypeID));
      jsnRule.AddPair('delay', TJSONNumber.Create(aRule.Action.Delay));

      if aRule.Action.ActionTypeID = 2 then
        jsnRule.AddPair('fill', aRule.Action.FillValue);
    end;

  if not jsnRule.TryGetValue('type', Value) then
    jsnRule.AddPair('type', 'container');

  jsnRules := TJSONArray.Create;
  for RuleRel in aRule.ChildRuleRels do
    begin
      AddRuleToJSON(RuleRel.ChildRule, jsnRules);
    end;

  if jsnRules.Count > 0 then
    jsnRule.AddPair('rules', jsnRules)
  else
    jsnRules.Free;

  jsnRule.AddPair('regexps', EncodeRegExpsToJSON(aRule.RegExps));

  if     (FScriptFor in [sfLoadEnd])
     and (aRule.Request <> nil)
  then
    jsnRule.AddPair('request', EncodeRequestToJSON(aRule.Request));

  if aRule = FRootRule then
    jsnRule.AddPair('nodes', EncodeNodesToJSON(FRootRuleNodeList))
  else
    jsnRule.AddPair('nodes', EncodeNodesToJSON(aRule.Nodes));

  ajsnArray.AddElement(jsnRule);
end;

function TModelParser.AddRecord(aLinkId, aGroupID: integer; aKey, aValue: string): Boolean;
var
  Rec: TRecord;
begin
  if aValue.Trim = '' then Exit;

  Rec := TRecord.Create(FDBEngine);
  try
    Rec.LinkID := aLinkId;
    Rec.GroupID := aGroupID;
    Rec.Key := aKey;
    Rec.Value := aValue.Trim;
    Rec.ValueHash := THashMD5.GetHashString(aValue);

    try
      Rec.SaveEntity;
      Result := True;
    except
      Result := False;
    end;
  finally
    Rec.Free;
  end;
end;

procedure TModelParser.SetCurrLinkHandle(aValue: Integer);
begin
  FCurrLink.Handled := aValue;
  FCurrLink.SaveEntity;
end;

function TModelParser.AddLink(aLink: string; aParentLinkID, aLevel, aGroupID: Integer): Boolean;
var
  Link: TLink;
begin
  Link := TLink.Create(FDBEngine);
  try
    Link.GroupID := aGroupID;
    Link.Level := aLevel;
    Link.Link := aLink;
    Link.LinkHash := THashMD5.GetHashString(aLink);

    if aParentLinkID > 0 then
      begin
        if Link.ParentRel = nil then Link.ParentRel := TLinkRel.Create(FDBEngine);
        Link.ParentRel.ParentLinkID := aParentLinkID;
      end;

    try
      Link.SaveAll;
      Result := True;
    except
      Result := False;
    end;
  finally
    Link.Free;
  end;
end;

procedure TModelParser.ProcessDataReceived(aData: string);
var
  jsnData: TJSONObject;
  jsnResult: TJSONArray;
  jsnRuleVal: TJSONValue;
  jsnRuleObj: TJSONObject;
  Link: string;
  Level: Integer;
  Key, Value: string;
  GroupID, DataGroupNum, DataParentGroupNum: Integer;
  StoredAnyData: Boolean;
  RequestID, LinkID: Integer;
begin
  StoredAnyData := False;
  jsnData:=TJSONObject.ParseJSONValue(aData) as TJSONObject;

  try
    if jsnData.TryGetValue<Integer>('link_id', LinkID) then
      if LinkID <> FCurrLink.ID then Exit;

    jsnResult:=jsnData.GetValue('result') as TJSONArray;

    for jsnRuleVal in jsnResult do
      begin
        jsnRuleObj := jsnRuleVal as TJSONObject;

        DataGroupNum := (jsnRuleObj.GetValue('group') as TJSONNumber).AsInt;
        DataParentGroupNum := (jsnRuleObj.GetValue('parent_group') as TJSONNumber).AsInt;

        if FParseMode = pmJobRun then
          GroupID := GetGroupID(FGroupBinds, DataGroupNum, DataParentGroupNum);

        if jsnRuleObj.GetValue('type').Value = 'link' then
          begin
            Link := jsnRuleObj.GetValue('href').Value;
            Level := (jsnRuleObj.GetValue('level') as TJSONNumber).AsInt;

            case FParseMode of
              pmJobRun:
                begin
                  if AddLink(Link, FCurrLink.ID, Level, GroupID) then
                    StoredAnyData := True;
                end;
              pmLevelDesign, pmLevelRunTest:
                begin
                  if TryAddViewResult(DataGroupNum, 'Link', Link) then
                    StoredAnyData := True;
                end;
            end;
          end;

        if jsnRuleObj.GetValue('type').Value = 'record' then
          begin
            Key := jsnRuleObj.GetValue('key').Value;

            if jsnRuleObj.TryGetValue('value', Value) then
              case FParseMode of
                pmJobRun:
                  begin
                    if AddRecord(FCurrLink.ID, GroupID, Key, Value) then
                      StoredAnyData := True;
                  end;
                pmLevelDesign, pmLevelRunTest:
                  begin
                    if TryAddViewResult(DataGroupNum, Key, Value) then
                      StoredAnyData := True;
                  end;
              end;
          end;
      end;

    if    jsnData.TryGetValue<Integer>('request_id', RequestID)
      and StoredAnyData
    then
      begin
        FRequestTimeOut.Enabled := False;
        SetRequestState(RequestID, sDone);
        ProcessTrigerAction(RequestID);
      end;

    if not FIsWaitingForRequests then
      case FParseMode of
        pmJobRun:
          ProcessNextLink;

        pmLevelDesign:
          DoCreateEventOnViewResultsReceived;

        pmLevelRunTest:
          DoStopLevelTestRun;
      end;
  finally
    jsnData.Free;
  end;
end;

procedure TModelParser.crmProcessMessageReceived(Sender: TObject;
        const browser: ICefBrowser; sourceProcess: TCefProcessId;
        const message: ICefProcessMessage; out Result: Boolean);
begin
  try
    if message.Name = 'parsedataback' then
      ProcessDataReceived(message.ArgumentList.GetString(0));

    if message.Name = 'observerevent' then
      ProcessObserveEvent(message.ArgumentList.GetString(0));

    if message.Name = 'fullnodestreeback' then
      begin
        FData.AddOrSetValue('NodesFullTree', message.ArgumentList.GetString(0));
        CreateEvent('OnNodesFullTreeReceived');
      end;

    if message.Name = 'selectdataback' then
      begin
        FData.AddOrSetValue('SelectedNodes', message.ArgumentList.GetString(0));
        CreateEvent('OnSelectedNodesReceived');
      end;
  finally
    //TFilesEngine.CreateFile('ProcessMessageReceived.log');
    //TFilesEngine.SaveTextToFile('ProcessMessageReceived.log', message.ArgumentList.GetString(0));
  end;
end;

procedure TModelParser.DoProcessJScript(aScriptFor: TScriptFor; aRule: TJobRule = nil);
var
  ModelJS: TModelJS;
  ObjData: TObjectDictionary<string, TObject>;
  Data: TDictionary<string, variant>;
  JSScript: string;
begin
  ObjData := TObjectDictionary<string, TObject>.Create;
  Data := TDictionary<string, variant>.Create;
  try
    ObjData.AddOrSetValue('DBEngine', FDBEngine);

    if aRule = nil then
      if FLevel.BodyRuleID = 0 then Exit
      else aRule := FLevel.BodyRule;

    ObjData.AddOrSetValue('Level', FLevel);
    ObjData.AddOrSetValue('Rule', aRule);

    Data.AddOrSetValue('ScriptFor', aScriptFor);
    Data.AddOrSetValue('JSScript', FData.Items['JSScript']);
    Data.AddOrSetValue('LinkID', FCurrLink.ID);
    if FParseMode = pmLevelDesign then
      Data.AddOrSetValue('IsSkipActions', FData.items['IsSkipActions']);

    ModelJS := TModelJS.Create(Data, ObjData);
    try
      ModelJS.PrepareProcessingScript;
      JSScript := Data.Items['JSScript'];
      FChromium.Browser.MainFrame.ExecuteJavaScript(JSScript, 'about:blank', 0);

      if   ((aScriptFor = sfLoadEnd) and (Length(FRequestStates) > 0))
        or ((aScriptFor = sfRequestEnd) and (aRule.Request <> nil))
      then
        begin
          FIsWaitingForRequests := True;
          if not FRequestTimeOut.Enabled then
            StartRequestTimeOut;
        end
      else
        FIsWaitingForRequests := False;

    finally
      ModelJS.Free;
    end;
  finally
    ObjData.Free;
    Data.Free;
  end;
end;

procedure TModelParser.crmLoadEnd(Sender: TObject; const browser: ICefBrowser;
    const frame: ICefFrame; httpStatusCode: Integer);
var
  InjectJS: string;
begin
  try
    if    (httpStatusCode = 200)
      and frame.IsMain
    then
      begin
        FLastLoadTime := MilliSecondsBetween(FLastLoadStartTime, Now);
        FLoadTimeOut.Enabled := False;

        InjectJS := TFilesEngine.GetTextFromFile(GetCurrentDir + '\JS\jquery-3.1.1.js');
        frame.ExecuteJavaScript(InjectJS, '', 0);

        if FParseMode in [pmJobRun, pmLevelRunTest] then DoProcessJScript(sfLoadEnd);
      end;

    if httpStatusCode = 404 then
      begin
        AddError(FCurrLink.ID, 4, 'Page Not Found 404');
        ProcessNextLink(3);
        Exit;
      end;

  finally
    TFilesEngine.CreateFile('LoadEnd.log');
    TFilesEngine.SaveTextToFile('LoadEnd.log', httpStatusCode.ToString);
  end;
end;

function TModelParser.GetNextLink: TLink;
var
  SQL: string;
  dsQuery: TFDQuery;
  GroupID: integer;
begin
  SQL := 'select '#13#10 +
         'l.* '#13#10 +
         'from links l '#13#10 +
         'join groups g on g.Id = l.group_id '#13#10 +
         'where g.job_id = :JobID '#13#10 +
         'and l.handled in (0, 1) '#13#10 +
         'order by l.level desc, l.id '#13#10 +
         'limit 1';

  dsQuery := TFDQuery.Create(nil);
  try
    dsQuery.SQL.Text := SQL;
    dsQuery.ParamByName('JobID').AsInteger := FJob.ID;
    FDBEngine.OpenQuery(dsQuery);

    if dsQuery.EOF then
      begin
        if GetLinksCount(FJob.ID) = 0 then // first start - no links else
          begin
            GroupID := AddGroup(0);

            AddLink(FJob.ZeroLink, 0, 1, GroupID);
            Exit(GetNextLink);
          end
        else
          Exit(nil); // all links are handled
      end;

    Result := TLink.Create(FDBEngine, dsQuery.FieldByName('Id').AsInteger);
  finally
    dsQuery.Free;
  end;
end;

procedure TModelParser.ProcessNextLink(aPrivLinkHandled: Integer = 2);
begin
  FLoadTimeOut.Enabled := False;
  FRequestTimeOut.Enabled := False;

  if FData.Items['IsJobStopped'] then
    Stop
  else
    begin
      if Assigned(FCurrLink) then
        begin
          FCurrLink.HandleTime := Now;
          SetCurrLinkHandle(aPrivLinkHandled);
          FreeAndNil(FCurrLink);
        end;

      FCurrLink := GetNextLink;
      if FCurrLink <> nil then
        begin
          SetCurrLinkHandle(1);
          DoLoadPage;
        end
      else
        begin
          CreateEvent('OnJobDone');
          Stop;
        end;
    end;
end;

procedure TModelParser.Start;
begin
  FParseMode := FData.Items['ParseMode'];
  FJob := FObjData.Items['Job'] as TJob;

  FChromium := FObjData.Items['Chromium'] as TChromium;
  FChromium.OnLoadEnd := crmLoadEnd;
  FChromium.OnBeforePopup := crmBeforePopup;
  FChromium.OnProcessMessageReceived := crmProcessMessageReceived;

  FLoadTimeOut := TTimer.Create(nil);
  FLoadTimeOut.Enabled := False;
  FLoadTimeOut.OnTimer := OnLoadTimeOut;

  FRequestTimeOut := TTimer.Create(nil);
  FRequestTimeOut.Enabled := False;
  FRequestTimeOut.OnTimer := DoRequestTimeOut;

  case FParseMode of
    pmJobRun: ProcessNextLink;
    pmLevelRunTest: LoadLevelTest;
  end;
end;

function TModelJS.ColorToHex(color: TColor): String;
begin
  Result := Format('#%.2x%.2x%.2x', [byte(color), byte(color shr 8), byte(color shr 16)]);
end;

function TModelJS.EncodeRegExpsToJSON(aRegExpList: TJobRegExpList): TJSONArray;
var
  jsnRegExp: TJSONObject;
  RegExp: TJobRegExp;
begin
  Result := TJSONArray.Create;

  for RegExp in aRegExpList do
    begin
      jsnRegExp := TJSONObject.Create;
      jsnRegExp.AddPair('id', TJSONNumber.Create(RegExp.ID));
      jsnRegExp.AddPair('type', TJSONNumber.Create(RegExp.RegExpTypeID));
      jsnRegExp.AddPair('regexp', RegExp.RegExp);
      jsnRegExp.AddPair('replace', RegExp.ReplaceValue);
      Result.AddElement(jsnRegExp);
    end;
end;

function TModelJS.EncodeNodesToJSON(aNodeList: TNodeList): TJSONArray;
var
  jsnNode: TJSONObject;
  Node: TJobNode;
begin
  Result := TJSONArray.Create;

  for Node in aNodeList do
    begin
      jsnNode := TJSONObject.Create;
      jsnNode.AddPair('id', TJSONNumber.Create(Node.ID));
      jsnNode.AddPair('tag', Node.Tag);
      jsnNode.AddPair('index', TJSONNumber.Create(Node.Index));
      jsnNode.AddPair('tagID', Node.TagID);
      jsnNode.AddPair('className', Node.ClassName);
      jsnNode.AddPair('name', Node.Name);
      Result.AddElement(jsnNode);
    end;
end;

procedure TModelJS.PrepareProcessingScript;
var
  Level: TJobLevel;
  Rule: TJobRule;
  jsnLevel: TJSONObject;
  jsnRules: TJSONArray;
  JSScript: string;
  LinkID: Integer;
  IsSkipActions: Boolean;
begin
  FScriptFor := FData.Items['ScriptFor'];
  FRootRule := FObjData.Items['Rule'] as TJobRule;
  Level := FObjData.Items['Level'] as TJobLevel;

  jsnLevel := TJSONObject.Create;
  jsnRules := TJSONArray.Create;

  try
    FRootRuleNodeList := CreateRootRuleNodeList(Level.BodyRule, FRootRule);

    AddRuleToJSON(FRootRule, jsnRules);

    jsnLevel.AddPair('rules', jsnRules);

    if FScriptFor = sfEditor then
      begin
        IsSkipActions := FData.Items['IsSkipActions'];

        if IsSkipActions then
          jsnLevel.AddPair('skip_actions', TJSONBool.Create(True));

        jsnLevel.AddPair('design_mode', TJSONBool.Create(True));
      end;

    if FScriptFor = sfRequestEnd then
      begin
        jsnLevel.AddPair('request_id', TJSONNumber.Create(FRootRule.Request.ID));

        LinkID := FData.Items['LinkID'];
        jsnLevel.AddPair('link_id', TJSONNumber.Create(LinkID));
      end;

    JSScript := FData.Items['JSScript'];
    JSScript := Format(JSScript, [jsnLevel.ToJSON]);
    FData.AddOrSetValue('JSScript', JSScript);
  finally
    FRootRuleNodeList.Free;
    jsnLevel.Free;
  end;
end;

end.
