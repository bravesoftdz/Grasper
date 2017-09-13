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
    procedure ProcessDataReceived(aData: string);
    procedure SetCurrLinkHandle(aValue: Integer);
    procedure WriteToTemp;
    function GetNextlink: TLink;
    function AddLink(aLink: string; aParentLinkID, aLevel: Integer; aNum: Integer = 1): Integer;
    function AddRecord(aLinkId, aRecordNum: integer; aKey, aValue: string): integer;
  published
    procedure StartJob;
  end;

implementation

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Hash,
  FireDAC.Comp.Client,
  API_Files;

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

procedure TModelParser.WriteToTemp;
  function ByKey(aQuery: TFDQuery; aKey: string): string;
  begin
    Result := '';
    aQuery.First;
    while not aQuery.Eof do
      begin
        if aQuery.FieldByName('key').AsString = aKey then
          Exit(aQuery.FieldByName('value').AsString);
        aQuery.Next;
      end;
  end;
  function GetSite(RuDS, EnDS: TFDQuery): string;
  begin
    Result := '';
    if ByKey(RuDS, 'site')<> '' then
      Exit(ByKey(RuDS, 'site'));
    if ByKey(RuDS, 'site2')<> '' then
      Exit(ByKey(RuDS, 'site2'));

    if ByKey(EnDS, 'site')<> '' then
      Exit(ByKey(EnDS, 'site'));
    if ByKey(EnDS, 'site2')<> '' then
      Exit(ByKey(EnDS, 'site2'));
   end;
var
  dsQuery: TFDQuery;
  dsRec: TFDQuery;
  dsRecEN: TFDQuery;
  dsRecUA: TFDQuery;

  ru_title, ru_content, en_title, en_content, site, ru_link, en_link: string;
  ua_title, ua_content, ua_link: string;
  ru_linkid, en_linkid, ua_linkid: Integer;
  IsProcess: Boolean;
begin
  if FCurrLink = nil then Exit;
  if FCurrLink.Level = 1 then Exit;

  dsQuery := TFDQuery.Create(nil);
  dsRec := TFDQuery.Create(nil);
  dsRecEN := TFDQuery.Create(nil);
  dsRecUA := TFDQuery.Create(nil);
  try
    if FCurrLink.Level = 2 then
      begin
        dsQuery.SQL.Text := 'select * from link2link where master_link_id = :linkid';
        dsQuery.ParamByName('linkid').AsInteger := FCurrLink.ID;
        FDBEngine.OpenQuery(dsQuery);

        if dsQuery.IsEmpty then
          begin
            ru_linkid := FCurrLink.ID;
            en_linkid := 0;
            ua_linkid := 0;
            IsProcess := True;

            ru_link := FCurrLink.Link;
            en_link := '';
            ua_link := '';
          end;
      end;

    if FCurrLink.Level = 3 then
      begin
        dsQuery.SQL.Text :=
          'select '+
          'lun.id as un_id, ifnull(lun.handled, -1) as un_handled, lun.link as un_link, '+
          'lru.id as ru_id, ifnull(lru.handled, -1) as ru_handled, lru.link as ru_link, '+
          'len.id as en_id, ifnull(len.handled, -1) as en_handled, len.link as en_link '+
          'from link2link l2l '+
          'left join link2link l2l4 on l2l4.master_link_id = l2l.master_link_id '+
          'left join links lun on lun.Id = l2l4.slave_link_id and lun.level = 4 '+
          'left join links lru on lru.Id = l2l.master_link_id and lru.level = 2 '+
          'left join links len on len.Id = l2l.slave_link_id and len.level = 3 '+
          'where l2l.slave_link_id = :linkid';

        dsQuery.ParamByName('linkid').AsInteger := FCurrLink.ID;
        FDBEngine.OpenQuery(dsQuery);
        dsQuery.Last;

        if dsQuery.FieldByName('un_handled').AsInteger <> 0 then
          begin
            ru_linkid := dsQuery.FieldByName('ru_id').AsInteger;
            en_linkid := dsQuery.FieldByName('en_id').AsInteger;
            ua_linkid := dsQuery.FieldByName('un_id').AsInteger;
            IsProcess := True;

            ru_link := dsQuery.FieldByName('ru_link').AsString;
            en_link := dsQuery.FieldByName('en_link').AsString;
            ua_link := dsQuery.FieldByName('un_link').AsString;
          end;
      end;

    if FCurrLink.Level = 4 then
      begin
        dsQuery.SQL.Text :=
          'select '+
          'lun.id as un_id, ifnull(lun.handled, -1) as un_handled, lun.link as un_link, '+
          'lru.id as ru_id, ifnull(lru.handled, -1) as ru_handled, lru.link as ru_link, '+
          'len.id as en_id, ifnull(len.handled, -1) as en_handled, len.link as en_link '+
          'from link2link l2l '+
          'left join link2link l2l3 on l2l3.master_link_id = l2l.master_link_id '+
          'left join links lun on lun.Id = l2l.slave_link_id and lun.level = 4 '+
          'left join links lru on lru.Id = l2l.master_link_id and lru.level = 2 '+
          'left join links len on len.Id = l2l3.slave_link_id and len.level = 3 '+
          'where l2l.slave_link_id = :linkid ';

        dsQuery.ParamByName('linkid').AsInteger := FCurrLink.ID;
        FDBEngine.OpenQuery(dsQuery);

        if dsQuery.FieldByName('en_handled').AsInteger <> 0 then
          begin
            ru_linkid := dsQuery.FieldByName('ru_id').AsInteger;
            en_linkid := dsQuery.FieldByName('en_id').AsInteger;
            ua_linkid := dsQuery.FieldByName('un_id').AsInteger;
            IsProcess := True;

            ru_link := dsQuery.FieldByName('ru_link').AsString;
            en_link := dsQuery.FieldByName('en_link').AsString;
            ua_link := dsQuery.FieldByName('un_link').AsString;
          end;
      end;

    if IsProcess then
      begin
        dsRecEN.SQL.Text := 'select * from records where link_id = :linkid';
        dsRecEN.ParamByName('linkid').AsInteger := en_linkid;
        FDBEngine.OpenQuery(dsRecEn);

        dsRec.SQL.Text := 'select * from records where link_id = :linkid';
        dsRec.ParamByName('linkid').AsInteger := ru_linkid;
        FDBEngine.OpenQuery(dsRec);

        dsRecUA.SQL.Text := 'select * from records where link_id = :linkid';
        dsRecUA.ParamByName('linkid').AsInteger := ua_linkid;
        FDBEngine.OpenQuery(dsRecUA);

        dsQuery.SQL.Text := 'insert into temp (ru_title, ru_content, en_title, en_content, ua_title, ua_content, site, ru_link, en_link, ua_link) values (:rutitle, :rucontent, '+
        ':entitle, :encontent, :uatitle, :uacontent, :site, :rulink, :enlink, :ualink)';
        dsQuery.ParamByName('rutitle').AsString := ByKey(dsRec, 'title');
        dsQuery.ParamByName('rucontent').AsString := ByKey(dsRec, 'content');
        dsQuery.ParamByName('entitle').AsString := ByKey(dsRecEN, 'title_en');
        dsQuery.ParamByName('encontent').AsString := ByKey(dsRecEN, 'content_en');
        dsQuery.ParamByName('uatitle').AsString := ByKey(dsRecUA, 'title_ua');
        dsQuery.ParamByName('uacontent').AsString := ByKey(dsRecUA, 'content_ua');

        dsQuery.ParamByName('site').AsString := GetSite(dsRec, dsRecEN);

        dsQuery.ParamByName('rulink').AsString := ru_link;
        dsQuery.ParamByName('enlink').AsString := en_link;
        dsQuery.ParamByName('ualink').AsString := ua_link;

        FDBEngine.ExecQuery(dsQuery);
      end;
  finally
    dsQuery.Free;
    dsRec.Free;
    dsRecEN.Free;
    dsRecUA.Free;
  end;
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
                  AddRecord(FCurrLink.ID, i, Key, Trim(Value));
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
    //if dsQuery.FieldByName('links_count').AsInteger = 0 then
    if dsQuery.EOF then
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
  if Assigned(FCurrLink) then
    begin
      FCurrLink.HandleTime := Now;
      SetCurrLinkHandle(2);
      FreeAndNil(FCurrLink);
    end;

  //WriteToTemp;
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
