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
    procedure WriteToTemp;
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
  System.Hash,
  FireDAC.Comp.Client,
  API_Files;

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
    Link.LinkHash := THashMD5.GetHashString(aLink);

    if aMasterLinkID > 0 then
      begin
        if Link.MasterRel = nil then Link.MasterRel := TLinkRel.Create(FDBEngine);
        Link.MasterRel.MasterLinkID := aMasterLinkID;
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
  if Assigned(FCurrLink) then SetCurrLinkHandle(2);
  WriteToTemp;
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
