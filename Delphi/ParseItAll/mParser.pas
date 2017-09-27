unit mParser;

interface

uses
  System.JSON,
  System.UITypes,
  cefvcl,
  cefLib,
  API_MVC_DB,
  eJob,
  eLevel,
  eRule,
  eNodes,
  eRegExp,
  eLink,
  eRecord;

type
  TGroupBind = record
    DataGroupNum: Integer;
    GroupID: Integer;
  end;

  TRequestCheck = record
    Method: string;
    URL: string;
    IsHappen: Boolean;
  end;

  TModelJS = class(TModelDB)
  private
    function ColorToHex(color: TColor): String;
    function EncodeNodesToJSON(aNodeList: TNodeList): TJSONArray;
    function EncodeRegExpsToJSON(aRegExpList: TJobRegExpList): TJSONArray;
    procedure AddRuleToJSON(aRule: TJobRule; ajsnArray: TJSONArray);
  published
    procedure PrepareParseScript;
  end;

  TModelParser = class(TModelDB)
  private
    FJob: TJob;
    FCurrLink: TLink;
    FChromium: TChromium;
    FRequestCheckList: TArray<TRequestCheck>;
    FIsDocumentReady: Boolean;

    procedure crmLoadEnd(Sender: TObject; const browser: ICefBrowser;
        const frame: ICefFrame; httpStatusCode: Integer);
    procedure crmProcessMessageReceived(Sender: TObject;
            const browser: ICefBrowser; sourceProcess: TCefProcessId;
            const message: ICefProcessMessage; out Result: Boolean);
    procedure crmResourceResponse(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
            const request: ICefRequest; const response: ICefResponse; out Result: Boolean);

    procedure ProcessNextLink(aPrivLinkHandled: Integer = 2);
    procedure ProcessJSOnFrame(aFrame: ICefFrame);
    procedure ProcessDataReceived(aData: string);
    procedure ProcessRequest(aRequest: ICefRequest);

    procedure SetCurrLinkHandle(aValue: Integer);
    procedure SetRequestCheckList(aLevel: integer);
    function IsWaitingForRequest: Boolean;
    procedure StopJob;
    function GetNextlink: TLink;
    function AddGroup: Integer;
    procedure AddLink(aLink: string; aParentLinkID, aLevel, aGroupID: Integer);
    procedure AddRecord(aLinkId, aGroupID: integer; aKey, aValue: string);
    procedure AddError(aLinkID, aErrTypeID: Integer; aErrText: string);
    function GetGroupID(var aGroupBinds: TArray<TGroupBind>; aDataGroupNum: Integer): Integer;
    function GetLinksCount(aJobID: Integer; aHandled: Integer = -1): Integer;
  published
    procedure StartJob;
    procedure GetJobProgress;
  end;

implementation

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Hash,
  FireDAC.Comp.Client,
  API_Files,
  eError,
  eGroup,
  eRequest;

procedure TModelParser.ProcessRequest(aRequest: ICefRequest);
var
  RequestCheck: TRequestCheck;
  i: Integer;
begin
  for i := 0 to Length(FRequestCheckList) - 1 do
    begin
      RequestCheck := FRequestCheckList[i];

      if     (RequestCheck.URL = aRequest.Url)
         and (RequestCheck.Method = aRequest.Method)
      then
        begin
          RequestCheck.IsHappen := True;
          //ProcessJSOnFrame(nil);
        end;
    end;
end;

function TModelParser.IsWaitingForRequest: Boolean;
var
  RequestCheck: TRequestCheck;
begin
  Result := False;

  for RequestCheck in FRequestCheckList do
    if not RequestCheck.IsHappen then Exit(True);
end;

procedure TModelParser.SetRequestCheckList(aLevel: integer);
var
  Level: TJobLevel;
  Request: TJobRequest;
  RequestList: TJobRequestList;
  RequestCheck: TRequestCheck;
begin
  Level := FJob.GetLevel(aLevel);
  RequestList := Level.GetLevelRequestList;
  try
    FRequestCheckList := [];

    for Request in RequestList do
      begin
        case Request.Method of
          1: RequestCheck.Method := 'GET';
          2: RequestCheck.Method := 'POST';
        end;

        RequestCheck.URL := Request.Link;
        RequestCheck.IsHappen := False;

        FRequestCheckList := FRequestCheckList + [RequestCheck];
      end;
  finally
    RequestList.Free;
  end;
end;

procedure TModelParser.crmResourceResponse(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
            const request: ICefRequest; const response: ICefResponse; out Result: Boolean);
begin
  if FIsDocumentReady then
    begin
      ProcessRequest(request);
    end;
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

  jsnRule.AddPair('nodes', EncodeNodesToJSON(aRule.Nodes));

  ajsnArray.AddElement(jsnRule);
end;

procedure TModelParser.AddRecord(aLinkId, aGroupID: integer; aKey, aValue: string);
var
  Rec: TRecord;
begin
  Rec := TRecord.Create(FDBEngine);
  try
    Rec.LinkID := aLinkId;
    Rec.GroupID := aGroupID;
    Rec.Key := aKey;
    Rec.Value := aValue;

    Rec.SaveEntity;
  finally
    Rec.Free;
  end;
end;

procedure TModelParser.SetCurrLinkHandle(aValue: Integer);
begin
  FCurrLink.Handled := aValue;
  FCurrLink.SaveEntity;
end;

procedure TModelParser.AddLink(aLink: string; aParentLinkID, aLevel, aGroupID: Integer);
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
    except

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
begin
  jsnData:=TJSONObject.ParseJSONValue(aData) as TJSONObject;

  try
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

            AddLink(Link, FCurrLink.ID, Level, GroupID);
          end;

        if jsnRuleObj.GetValue('type').Value = 'record' then
          begin
            Key := jsnRuleObj.GetValue('key').Value;

            if jsnRuleObj.TryGetValue('value', Value) then
              AddRecord(FCurrLink.ID, GroupID, Key, Value);
          end;

        if jsnRuleObj.GetValue('type').Value = 'action' then
          begin

          end;
      end;

    if not IsWaitingForRequest then
      ProcessNextLink;
  finally
    jsnData.Free;
  end;
end;

procedure TModelParser.crmProcessMessageReceived(Sender: TObject;
        const browser: ICefBrowser; sourceProcess: TCefProcessId;
        const message: ICefProcessMessage; out Result: Boolean);
begin
  try
  if message.Name = 'parsedataback' then ProcessDataReceived(message.ArgumentList.GetString(0));
  finally
    TFilesEngine.CreateFile('ProcessMessageReceived.log');
    TFilesEngine.SaveTextToFile('ProcessMessageReceived.log', message.ArgumentList.GetString(0));
  end;
end;

procedure TModelParser.ProcessJSOnFrame(aFrame: ICefFrame);
var
  ModelJS: TModelJS;
  ObjData: TObjectDictionary<string, TObject>;
  Data: TDictionary<string, variant>;
  JSScript: string;
  Level: TJobLevel;
begin
  ObjData := TObjectDictionary<string, TObject>.Create;
  Data := TDictionary<string, variant>.Create;
  try
    ObjData.AddOrSetValue('DBEngine', FDBEngine);

    Level := FJob.GetLevel(FCurrLink.Level);
    if Level.BodyRuleID = 0 then Exit;

    Data.AddOrSetValue('JSScript', FData.Items['JSScript']);
    ObjData.AddOrSetValue('Level', Level);

    ModelJS := TModelJS.Create(Data, ObjData);
    try
      ModelJS.PrepareParseScript;
      JSScript := Data.Items['JSScript'];
      if Assigned(aFrame) then
        aFrame.ExecuteJavaScript(JSScript, 'about:blank', 0)
      else
        FChromium.Browser.MainFrame.ExecuteJavaScript(JSScript, 'about:blank', 0);
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
      and not FIsDocumentReady
      and frame.IsMain
    then
      begin
        FIsDocumentReady := True;
        InjectJS := TFilesEngine.GetTextFromFile(GetCurrentDir + '\JS\jquery-3.1.1.js');
        frame.ExecuteJavaScript(InjectJS, '', 0);

        ProcessJSOnFrame(frame);
      end;

    if httpStatusCode = 404 then
      begin
        AddError(FCurrLink.ID, 4, 'Page Not Found 404');
        ProcessNextLink(3);
        Exit;
      end;

    if FIsDocumentReady then
      begin
        InjectJS := '';
        FChromium.
      end;


  finally
    TFilesEngine.CreateFile('LoadEnd.log');
    TFilesEngine.SaveTextToFile('LoadEnd.log', httpStatusCode.ToString);
  end;
end;

function TModelParser.GetNextlink: TLink;
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
            Exit(GetNextlink);
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

      FCurrLink := GetNextlink;
      if FCurrLink <> nil then
        begin
          SetCurrLinkHandle(1);
          SetRequestCheckList(FCurrLink.Level);
          FIsDocumentReady := False;
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
  FChromium.OnResourceResponse := crmResourceResponse;

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

procedure TModelJS.PrepareParseScript;
var
  Level: TJobLevel;
  jsnLevel: TJSONObject;
  jsnRules: TJSONArray;
  JSScript: string;
  SkipActions: Boolean;
  MarkNodes: Boolean;
  Value: Variant;
begin
  Level := FObjData.Items['Level'] as TJobLevel;

  jsnLevel := TJSONObject.Create;
  jsnRules := TJSONArray.Create;
  try
    AddRuleToJSON(Level.BodyRule, jsnRules);

    jsnLevel.AddPair('rules', jsnRules);

    if FData.TryGetValue('SkipActions', Value) then
      begin
        SkipActions := Value;
        jsnLevel.AddPair('skip_actions', TJSONBool.Create(SkipActions));
      end;

    if FData.TryGetValue('MarkNodes', Value) then
      begin
        MarkNodes := Value;
        jsnLevel.AddPair('mark_nodes', TJSONBool.Create(MarkNodes));
      end;

    JSScript := FData.Items['JSScript'];
    JSScript := Format(JSScript, [jsnLevel.ToJSON]);
    FData.AddOrSetValue('JSScript', JSScript);
  finally
    jsnLevel.Free;
  end;
end;

end.
