unit mParser;

interface

uses
  System.JSON,
  System.UITypes,
  System.Threading,
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
  TGroupBind = record
    DataGroupNum: Integer;
    GroupID: Integer;
  end;

  TScriptFor = (sfEditor, sfLoadEnd, sfRequestEnd, sfTriggerExecute);

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
    FJob: TJob;
    FCurrLink: TLink;
    FLevel: TJobLevel;
    FChromium: TChromium;

    FIsWaitingForRequests: Boolean;
    FJSTimeOutTask: ITask;
    FRequestStates: TArray<TRequestState>;

    procedure crmLoadEnd(Sender: TObject; const browser: ICefBrowser;
        const frame: ICefFrame; httpStatusCode: Integer);
    procedure crmProcessMessageReceived(Sender: TObject;
            const browser: ICefBrowser; sourceProcess: TCefProcessId;
            const message: ICefProcessMessage; out Result: Boolean);

    procedure ProcessNextLink(aPrivLinkHandled: Integer = 2);
    procedure ProcessJScript(aScriptFor: TScriptFor; aRule: TJobRule = nil);
    procedure ProcessDataReceived(aData: string);
    procedure ProcessObserveEvent(aStrRuleID: string);
    procedure ProcessTrigerAction(aRequestID: integer);

    procedure SetCurrLinkHandle(aValue: Integer);

    function GetRequestStates: TArray<TRequestState>;
    procedure SetRequestState(aReqID: integer; aState: TState);
    procedure StartTimeOutProc;
    procedure OnRequestTimeOut;

    procedure StopJob;
    function GetNextLink: TLink;
    function AddGroup: Integer;
    function AddLink(aLink: string; aParentLinkID, aLevel, aGroupID: Integer): Boolean;
    function AddRecord(aLinkId, aGroupID: integer; aKey, aValue: string): Boolean;
    procedure AddError(aLinkID, aErrTypeID: Integer; aErrText: string);
    function GetGroupID(var aGroupBinds: TArray<TGroupBind>; aDataGroupNum: Integer): Integer;
    function GetLinksCount(aJobID: Integer; aHandled: Integer = -1): Integer;
  published
    procedure StartJob;
    procedure GetJobProgress;
  end;

implementation

uses
  Vcl.Dialogs,
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.Hash,
  Math,
  FireDAC.Comp.Client,
  API_Files,
  eError,
  eGroup,
  eRuleAction;

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
    if NodeKeyID > 0 then
      begin
        jsnConfig.AddPair('needDataBack', TJSONBool.Create(False));
        jsnConfig.AddPair('nodeKeyID', TJSONNumber.Create(NodeKeyID));
      end
    else
      jsnConfig.AddPair('needDataBack', TJSONBool.Create(True));

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

procedure TModelParser.OnRequestTimeOut;
var
  i: Integer;
  isAnyWaitingReplay, isAnyWaitingTriger: Boolean;
begin
  isAnyWaitingReplay := False;
  isAnyWaitingTriger := False;

  for i := 0 to Length(FRequestStates) - 1 do
    begin
      if FRequestStates[i].State = sWaitingReplay then
        isAnyWaitingReplay := True;

      if FRequestStates[i].State = sWaitingTriger then
        isAnyWaitingTriger := True;
    end;

  if isAnyWaitingReplay and not isAnyWaitingTriger then ProcessNextLink;
end;

function TModelParser.GetRequestStates: TArray<TRequestState>;
var
  JobRequest: TJobRequest;
  RequestState: TRequestState;
begin
  Result := [];

  for JobRequest in FLevel.GetLevelRequestList do
    begin
      RequestState.RequestID := JobRequest.ID;
      RequestState.TimeOut := JobRequest.TimeOut;
      RequestState.State:= sWaitingReplay;
      Result := Result + [RequestState];
    end;
end;

procedure TModelParser.StartTimeOutProc;
var
  TimeOut: Integer;
  RequestState: TRequestState;
  LocalTask: ITask;
begin
  TimeOut := 1;
  for RequestState in FRequestStates do
    begin
      TimeOut := Max(RequestState.TimeOut, TimeOut);
    end;

  if FJSTimeOutTask <> nil then FJSTimeOutTask.Cancel;

  LocalTask := TTask.Create(
    procedure
      begin
        Sleep(TimeOut);

        TThread.Synchronize(nil,
          procedure
            begin
              try
                LocalTask.CheckCanceled;
                OnRequestTimeOut;
              except
              end;
            end
        );
      end
  );

  LocalTask.Start;
  FJSTimeOutTask := LocalTask;
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
        ProcessJScript(sfTriggerExecute, ActionRule);
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
  RuleID := aStrRuleID.ToInteger;

  Rule := FJob.GetLevel(FCurrLink.Level).BodyRule.GetTreeChildRuleByID(RuleID);

  // not allowed body rule requests
  if Rule = nil then Exit;

  ProcessJScript(sfRequestEnd, Rule);
end;

function TModelJS.EncodeRequestToJSON(aJobRequest: TJobRequest): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(aJobRequest.JobRuleID));
end;

function TModelParser.GetGroupID(var aGroupBinds: TArray<TGroupBind>; aDataGroupNum: Integer): Integer;
var
  GroupBind: TGroupBind;
begin
  for GroupBind in aGroupBinds do
    if GroupBind.DataGroupNum = aDataGroupNum then
      Exit(GroupBind.GroupID);

  GroupBind.GroupID := AddGroup;
  GroupBind.DataGroupNum := aDataGroupNum;
  aGroupBinds := aGroupBinds + [GroupBind];
  Exit(GroupBind.GroupID);
end;

function TModelParser.AddGroup: Integer;
var
  Group: TGroup;
begin
  Group := TGroup.Create(FDBEngine);
  try
    Group.JobID := FJob.ID;
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

procedure TModelParser.StopJob;
begin
  FJob.Free;

  FCurrLink.Free;
  Self.Free;
end;

procedure TModelJS.AddRuleToJSON(aRule: TJobRule; ajsnArray: TJSONArray);
var
  jsnRule: TJSONObject;
  jsnRules: TJSONArray;
  RuleRel: TRuleRuleRel;
  Value: string;
begin
  if FScriptFor = sfLoadEnd then
    begin
      if    (aRule.Action <> nil)
        and (aRule.Action.ExecuteAfterLoad = False)
      then Exit;
    end;

  jsnRule := TJSONObject.Create;
  jsnRule.AddPair('id', TJSONNumber.Create(aRule.ID));
  jsnRule.AddPair('container_offset', TJSONNumber.Create(aRule.ContainerOffset));
  jsnRule.AddPair('color', ColorToHex(aRule.VisualColor));

  if aRule.Link <> nil then
    begin
      jsnRule.AddPair('type', 'link');
      jsnRule.AddPair('level', TJSONNumber.Create(aRule.Link.Level));
    end;

  if aRule.Rec <> nil then
    begin
      jsnRule.AddPair('type', 'record');
      jsnRule.AddPair('key', aRule.Rec.Key);
      jsnRule.AddPair('grab_type', TJSONNumber.Create(aRule.Rec.GrabType));
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

  if     (FScriptFor in [sfLoadEnd, sfEditor])
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
  GroupBinds: TArray<TGroupBind>;
  GroupID, DataGroupNum: Integer;
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
        GroupID := GetGroupID(GroupBinds, DataGroupNum);

        if jsnRuleObj.GetValue('type').Value = 'link' then
          begin
            Link := jsnRuleObj.GetValue('href').Value;
            Level := (jsnRuleObj.GetValue('level') as TJSONNumber).AsInt;

            if AddLink(Link, FCurrLink.ID, Level, GroupID) then
              StoredAnyData := True;
          end;

        if jsnRuleObj.GetValue('type').Value = 'record' then
          begin
            Key := jsnRuleObj.GetValue('key').Value;

            if jsnRuleObj.TryGetValue('value', Value) then
              if AddRecord(FCurrLink.ID, GroupID, Key, Value) then
                StoredAnyData := True;
          end;
      end;

    if    jsnData.TryGetValue<Integer>('request_id', RequestID)
      and StoredAnyData
    then
      begin
        SetRequestState(RequestID, sDone);
        //FJSTimeOutTask.Cancel;
        ProcessTrigerAction(RequestID);
      end;

    if not FIsWaitingForRequests then ProcessNextLink;
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
  finally
    TFilesEngine.CreateFile('ProcessMessageReceived.log');
    TFilesEngine.SaveTextToFile('ProcessMessageReceived.log', message.ArgumentList.GetString(0));
  end;
end;

procedure TModelParser.ProcessJScript(aScriptFor: TScriptFor; aRule: TJobRule = nil);
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
          StartTimeOutProc;
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
        InjectJS := TFilesEngine.GetTextFromFile(GetCurrentDir + '\JS\jquery-3.1.1.js');
        frame.ExecuteJavaScript(InjectJS, '', 0);

        ProcessJScript(sfLoadEnd);
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
            GroupID := AddGroup;

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
  if FData.Items['IsJobStopped'] then
    StopJob
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
          FLevel := FJob.GetLevel(FCurrLink.Level);
          FRequestStates := GetRequestStates;
          FChromium.Load(FCurrLink.Link);
        end
      else
        begin
          CreateEvent('OnJobDone');
          FJob.Free;
          Self.Free;
        end;
    end;
end;

procedure TModelParser.StartJob;
begin
  FChromium := FObjData.Items['Chromium'] as TChromium;
  FChromium.OnLoadEnd := crmLoadEnd;
  FChromium.OnProcessMessageReceived := crmProcessMessageReceived;

  FJob := FObjData.Items['Job'] as TJob;

  ProcessNextLink;
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
        jsnLevel.AddPair('skip_actions', TJSONBool.Create(True));
        jsnLevel.AddPair('mark_nodes', TJSONBool.Create(True));
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
