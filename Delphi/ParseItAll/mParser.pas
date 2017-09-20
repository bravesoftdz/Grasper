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
  TModelJS = class(TModelDB)
  private
    function ColorToHex(color: TColor): String;
    function EncodeNodesToJSON(aNodeList: TNodeList): TJSONArray;
    function EncodeRegExpsToJSON(aRegExpList: TJobRegExpList): TJSONArray;
    procedure AddRuleToJSON(aRule: TJobRule; ajsnArray: TJSONArray);
  published
    procedure PrepareJSScriptForLevel;
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
    procedure crmResourceRedirect(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
            const request: ICefRequest; var newUrl: ustring);
    procedure ProcessDataReceived(aData: string);
    procedure SetCurrLinkHandle(aValue: Integer);
    procedure StopJob;
    function GetNextlink: TLink;
    function AddLink(aLink: string; aParentLinkID, aLevel: Integer; aNum: Integer = 1): Integer;
    function AddRecord(aLinkId, aRecordNum: integer; aKey, aValue: string): integer;
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
  API_Files;

procedure TModelParser.crmResourceRedirect(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
            const request: ICefRequest; var newUrl: ustring);
begin
  FCurrLink.Link := newUrl;
end;

function TModelParser.GetLinksCount(aJobID: Integer; aHandled: Integer = -1): Integer;
var
  dsQuery: TFDQuery;
  sql: String;
begin
  dsQuery := TFDQuery.Create(nil);
  try
    sql := 'select count(*) link_count from links l where l.job_id = :JobID %s';
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

function TModelParser.AddLink(aLink: string; aParentLinkID, aLevel: Integer; aNum: Integer = 1): Integer;
var
  Link: TLink;
begin
  Link := TLink.Create(FDBEngine);
  try
    Link.JobID := FJob.ID;
    Link.Level := aLevel;
    Link.Num := aNum;
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

    Result := Link.ID;
  finally
    Link.Free;
  end;
end;

procedure TModelParser.ProcessDataReceived(aData: string);
var
  jsnData: TJSONObject;
  jsnResult: TJSONArray;
  jsnRule: TJSONValue;
  jsnRulePair: TJSONValue;
  jsnRulePairObj: TJSONObject;
  jsnRulePairList: TJSONArray;
  Link: string;
  Level: Integer;
  Key, Value: string;
  i: Integer;
  IsLast: Boolean;
begin
  jsnData:=TJSONObject.ParseJSONValue(aData) as TJSONObject;
  try
    jsnResult:=jsnData.GetValue('result') as TJSONArray;

    for jsnRule in jsnResult do
      begin
        i := 0;
        jsnRulePairList := jsnRule as TJSONArray;

        for jsnRulePair in jsnRulePairList do
          begin
            inc(i);
            jsnRulePairObj := jsnRulePair as TJSONObject;

            if jsnRulePairObj.GetValue('type').Value = 'link' then
              begin
                Link := jsnRulePairObj.GetValue('href').Value;
                Level := (jsnRulePairObj.GetValue('level') as TJSONNumber).AsInt;

                AddLink(Link, FCurrLink.ID, Level, i);
              end;

            if jsnRulePairObj.GetValue('type').Value = 'record' then
              begin
                Key := jsnRulePairObj.GetValue('key').Value;

                if jsnRulePairObj.TryGetValue('value', Value) then
                  AddRecord(FCurrLink.ID, i, Key, Value);
              end;
          end;
      end;

    ProcessNextLink;
  finally
    jsnData.Free;
  end;
end;

procedure TModelParser.crmProcessMessageReceived(Sender: TObject;
        const browser: ICefBrowser; sourceProcess: TCefProcessId;
        const message: ICefProcessMessage; out Result: Boolean);
begin
  if message.Name = 'parsedataback' then ProcessDataReceived(message.ArgumentList.GetString(0));
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
    if Level.RuleRels.Count = 0 then Exit;

    Data.AddOrSetValue('JSScript', FData.Items['JSScript']);
    ObjData.AddOrSetValue('Level', Level);

    ModelJS := TModelJS.Create(Data, ObjData);
    try
      ModelJS.PrepareJSScriptForLevel;
      JSScript := Data.Items['JSScript'];
      aFrame.ExecuteJavaScript(JSScript, 'about:blank', 0);
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
  if (frame.Url = FCurrLink.Link) and frame.IsMain then
    begin
      InjectJS := TFilesEngine.GetTextFromFile(GetCurrentDir + '\JS\jquery-3.1.1.js');
      frame.ExecuteJavaScript(InjectJS, 'about:blank', 0);

      ProcessJSOnFrame(frame);
    end;
end;

function TModelParser.GetNextlink: TLink;
var
  SQL: string;
  dsQuery: TFDQuery;
begin
  SQL := 'select '#13#10 +
         'links.* '#13#10 +
         'from links '#13#10 +
         'where job_id = :JobID '#13#10 +
         'and handled in (0, 1) '#13#10 +
         'order by level desc, id '#13#10 +
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
            AddLink(FJob.ZeroLink, 0, 1);
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

procedure TModelParser.ProcessNextLink;
begin
  if FData.Items['IsJobStopped'] then
    StopJob
  else
    begin
      if Assigned(FCurrLink) then
        begin
          FCurrLink.HandleTime := Now;
          SetCurrLinkHandle(2);
          FreeAndNil(FCurrLink);
        end;

      FCurrLink := GetNextlink;
      if FCurrLink <> nil then
        begin
          SetCurrLinkHandle(1);
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
  FChromium.OnResourceRedirect := crmResourceRedirect;

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

procedure TModelJS.PrepareJSScriptForLevel;
var
  Level: TJobLevel;
  RuleRel: TLevelRuleRel;
  jsnLevel: TJSONObject;
  jsnRules: TJSONArray;
  JSScript: string;
begin
  Level := FObjData.Items['Level'] as TJobLevel;

  jsnLevel := TJSONObject.Create;
  jsnRules := TJSONArray.Create;
  try
    for RuleRel in Level.RuleRels do
      begin
        AddRuleToJSON(RuleRel.Rule, jsnRules);
      end;

    jsnLevel.AddPair('rules', jsnRules);

    JSScript := FData.Items['JSScript'];
    JSScript := Format(JSScript, [jsnLevel.ToJSON]);
    FData.AddOrSetValue('JSScript', JSScript);
    CreateEvent('OnJSScriptPrepared');
  finally
    jsnLevel.Free;
  end;
end;

end.
