unit mParser;

interface

uses
  System.JSON,
  System.UITypes,
  cefvcl,
  cefLib,
  API_MVC_DB,
  eEntities;

type
  TModelJS = class(TModelDB)
  private
    function ColorToHex(color: TColor): String;
    function EncodeNodesToJSON(aNodeList: TNodeList): TJSONArray;
  published
    procedure PrepareJSScriptForGroup;
    procedure PrepareJSScriptForRule;
  end;

  TModelParser = class(TModelDB)
  private
    FJob: TJob;
    FCurrLink: TLink;
    FChromium: TChromium;
    procedure ProcessNextLink;
    procedure crmLoadEnd(Sender: TObject; const browser: ICefBrowser;
        const frame: ICefFrame; httpStatusCode: Integer);
    procedure ProcessJSOnFrame(aFrame: ICefFrame);
    procedure crmProcessMessageReceived(Sender: TObject;
            const browser: ICefBrowser; sourceProcess: TCefProcessId;
            const message: ICefProcessMessage; out Result: Boolean);
    procedure ProcessDataReceived(aData: string);
    procedure SetCurrLinkHandle(aValue: Integer);
    function GetNextlink: TLink;
    function AddLink(aLink: string; aMasterLinkID, aLevel: Integer; aNum: Integer = 1): Integer;
    function AddRecord(aLinkId, aRecordNum: integer; aKey, aValue: string): integer;
  published
    procedure StartJob;
  end;

implementation

uses
  System.SysUtils,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  API_Files;

function TModelParser.AddRecord(aLinkId, aRecordNum: integer; aKey, aValue: string): integer;
var
  Rec: TRecord;
begin
  Rec := TRecord.Create(FDBEngine);
  try
    Rec.LinkID := aLinkId;
    Rec.Num := aRecordNum;
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

function TModelParser.AddLink(aLink: string; aMasterLinkID, aLevel: Integer; aNum: Integer = 1): Integer;
var
  Link: TLink;
begin
  Link := TLink.Create(FDBEngine);
  try
    Link.JobID := FJob.ID;
    Link.Level := aLevel;
    Link.Num := aNum;
    Link.Link := aLink;

    if aMasterLinkID > 0 then
      begin
        if Link.MasterRel = nil then Link.MasterRel := TLinkRel.Create(FDBEngine);
        Link.MasterRel.MasterLinkID := aMasterLinkID;
      end;

    Link.SaveAll;

    Result := Link.ID;
  finally
    Link.Free;
  end;
end;

procedure TModelParser.ProcessDataReceived(aData: string);
var
  jsnData: TJSONObject;
  jsnResult: TJSONArray;
  jsnGroup: TJSONValue;
  jsnGroupList: TJSONArray;
  jsnRule: TJSONValue;
  jsnRuleObj: TJSONObject;
  Link: string;
  Level: Integer;
  Key, Value: string;
  i: Integer;
  IsLast: Boolean;
begin
  jsnData:=TJSONObject.ParseJSONValue(aData) as TJSONObject;
  jsnResult:=jsnData.GetValue('result') as TJSONArray;

  i := 0;
  for jsnGroup in jsnResult do
    begin
      inc(i);
      jsnGroupList := jsnGroup as TJSONArray;

      for jsnRule in jsnGroupList do
        begin
          jsnRuleObj := jsnRule as TJSONObject;

          if jsnRuleObj.GetValue('href') <> nil then
            begin
              Link := jsnRuleObj.GetValue('href').Value;
              Level := (jsnRuleObj.GetValue('level') as TJSONNumber).AsInt;

              AddLink(Link, FCurrLink.ID, Level, i);
            end;

          if jsnRuleObj.GetValue('key') <> nil then
            begin
              Key := jsnRuleObj.GetValue('key').Value;
              Value := jsnRuleObj.GetValue('value').Value;

              AddRecord(FCurrLink.ID, i, Key, Value);
            end;
        end;
    end;

  if jsnData.GetValue('islast') <> nil then
    isLast:=True
  else
    isLast:=False;

  if isLast then ProcessNextLink;
end;

procedure TModelParser.crmProcessMessageReceived(Sender: TObject;
        const browser: ICefBrowser; sourceProcess: TCefProcessId;
        const message: ICefProcessMessage; out Result: Boolean);
begin
  if message.Name = 'parsedataback' then ProcessDataReceived(message.ArgumentList.GetString(0));
end;

procedure TModelParser.ProcessJSOnFrame(aFrame: ICefFrame);
var
  Level: TJobLevel;
  Group: TJobGroup;
  ModelJS: TModelJS;
  ObjData: TObjectDictionary<string, TObject>;
  Data: TDictionary<string, variant>;
  JSScript: string;
  i: Integer;
begin
  ObjData := TObjectDictionary<string, TObject>.Create;
  Data := TDictionary<string, variant>.Create;
  try
    ObjData.AddOrSetValue('DBEngine', FDBEngine);
    Level := FJob.GetLevel(FCurrLink.Level);

    i := 0;
    for Group in Level.Groups do
      begin
        Inc(i);
        if i = Level.Groups.Count then
          Data.AddOrSetValue('IsLastGroup', True);
        Data.AddOrSetValue('JSScript', FData.Items['JSScript']);
        ObjData.AddOrSetValue('Group', Group);

        ModelJS := TModelJS.Create(Data, ObjData);
        try
          ModelJS.PrepareJSScriptForGroup;
          JSScript := Data.Items['JSScript'];
          aFrame.ExecuteJavaScript(JSScript, 'about:blank', 0);
        finally
          ModelJS.Free;
        end;
      end;
  finally
    ObjData.Free;
    Data.Free;
  end;
end;

procedure TModelParser.crmLoadEnd(Sender: TObject; const browser: ICefBrowser;
    const frame: ICefFrame; httpStatusCode: Integer);
begin
  if frame.Url = FCurrLink.Link then ProcessJSOnFrame(frame);
end;

function TModelParser.GetNextlink: TLink;
var
  SQL: string;
  dsQuery: TFDQuery;
begin
  SQL := 'select  '#13#10 +
         '  links.*, '#13#10 +
         '  (select count(*) from links t where t.job_id = links.job_id) links_count '#13#10 +
         'from links '#13#10 +
         'where job_id = :JobID '#13#10 +
         'and handled = 0 '#13#10 +
         'order by level desc, id '#13#10 +
         'limit 1';

  dsQuery := TFDQuery.Create(nil);
  try
    dsQuery.SQL.Text := SQL;
    dsQuery.ParamByName('JobID').AsInteger := FJob.ID;
    FDBEngine.OpenQuery(dsQuery);

    // first start - no links else
    if dsQuery.FieldByName('links_count').AsInteger = 0 then
      begin
        AddLink(FJob.ZeroLink, 0, 1);
        Exit(GetNextlink);
      end;

    Result := TLink.Create(FDBEngine, dsQuery.FieldByName('Id').AsInteger);
  finally
    dsQuery.Free;
  end;
end;

procedure TModelParser.ProcessNextLink;
begin
  if Assigned(FCurrLink) then SetCurrLinkHandle(2);
  FCurrLink := GetNextlink;
  SetCurrLinkHandle(1);
  FChromium.Load(FCurrLink.Link);
end;

procedure TModelParser.StartJob;
begin
  FChromium := FObjData.Items['Chromium'] as TChromium;
  FChromium.OnLoadEnd := crmLoadEnd;
  FChromium.OnProcessMessageReceived := crmProcessMessageReceived;

  FJob := TJob.Create(FDBEngine, FData.Items['JobID']);
  ProcessNextLink;
end;

function TModelJS.ColorToHex(color: TColor): String;
begin
  Result := Format('#%.2x%.2x%.2x', [byte(color), byte(color shr 8), byte(color shr 16)]);
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
      jsnNode.AddPair('ID', TJSONNumber.Create(Node.ID));
      jsnNode.AddPair('tag', Node.Tag);
      jsnNode.AddPair('index', TJSONNumber.Create(Node.Index));
      jsnNode.AddPair('tagID', Node.TagID);
      jsnNode.AddPair('className', Node.ClassName);
      jsnNode.AddPair('name', Node.Name);
      Result.AddElement(jsnNode);
    end;
end;

procedure TModelJS.PrepareJSScriptForGroup;
var
  jsnGroup: TJSONObject;
  jsnRule: TJSONObject;
  jsnRules: TJSONArray;
  Group: TJobGroup;
  Rule: TJobRule;
  ContainerNodeList, ContainerInsideNodes: TNodeList;
  JSScript: string;
  i: Integer;
  IsLast: Variant;
begin
  Group := FObjData.Items['Group'] as TJobGroup;
  JSScript := FData.Items['JSScript'];

  ContainerNodeList := Group.GetContainerNodes;
  jsnGroup := TJSONObject.Create;
  jsnRules := TJSONArray.Create;
  try
    jsnGroup.AddPair('nodes', EncodeNodesToJSON(ContainerNodeList));

    for Rule in Group.Rules do
      begin
        jsnRule := TJSONObject.Create;
        jsnRule.AddPair('id', TJSONNumber.Create(Rule.ID));

        if Rule.Link <> nil then
          jsnRule.AddPair('level', TJSONNumber.Create(Rule.Link.Level));

        if Rule.Rec <> nil then
          jsnRule.AddPair('key', Rule.Rec.Key);

        if Rule.Cut <> nil then
          jsnRule.AddPair('cut', TJSONTrue.Create);

        jsnRule.AddPair('color', ColorToHex(Rule.VisualColor));

        try
          if Rule.ContainerOffset = 0 then
            begin
              ContainerInsideNodes := TNodeList.Create(False);
              for i := ContainerNodeList.Count to Rule.Nodes.Count - 1 do
                ContainerInsideNodes.Add(Rule.Nodes[i]);

              jsnRule.AddPair('strict', TJSONTrue.Create);
            end
          else
            ContainerInsideNodes := Rule.GetContainerInsideNodes;

          jsnRule.AddPair('nodes', EncodeNodesToJSON(ContainerInsideNodes));
        finally
          ContainerInsideNodes.Free;
        end;

        jsnRules.AddElement(jsnRule);
      end;

    jsnGroup.AddPair('rules', jsnRules);

    if FData.TryGetValue('IsLastGroup', IsLast) then
      jsnGroup.AddPair('islast', TJSONNumber.Create(1));

    JSScript := Format(JSScript, [jsnGroup.ToJSON]);
    FData.AddOrSetValue('JSScript', JSScript);
    CreateEvent('AfterJSScriptPrepared');
  finally
    ContainerNodeList.Free;
    jsnGroup.Free;
  end;
end;

procedure TModelJS.PrepareJSScriptForRule;
var
  Group: TJobGroup;
  Rule: TJobRule;
begin
  Group := TJobGroup.Create(FDBEngine, 0);
  try
    Rule := FObjData.Items['Rule'] as TJobRule;
    Group.Rules.Add(Rule);

    FObjData.AddOrSetValue('Group', Group);
    PrepareJSScriptForGroup;
  finally
    Group.Rules.Extract(Rule);
    Group.Free;
  end;
end;

end.
