unit mParser;

interface

uses
  System.JSON,
  API_MVC_DB,
  eEntities;

type
  TModelJS = class(TModelDB)
  private
    function EncodeNodesToJSON(aNodeList: TNodeList): TJSONArray;
  published
    procedure PrepareJSScriptForGroup;
    procedure ExecuteRule(aRule: TJobRule);
  end;

implementation

uses
  System.SysUtils,
  API_Files;

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
  ContainerNodeList, ContainerInsideNodes: TNodeList;
  LinkRule: TJobLink;
  RecordRule: TJobRecord;
  JSScript: string;
begin
  Group := FObjData.Items['Group'] as TJobGroup;
  JSScript := FData.Items['JSScript'];

  ContainerNodeList := Group.GetContainerNodes;
  jsnGroup := TJSONObject.Create;
  jsnRules := TJSONArray.Create;
  try
    jsnGroup.AddPair('nodes', EncodeNodesToJSON(ContainerNodeList));

    for LinkRule in Group.Links do
      begin
        jsnRule := TJSONObject.Create;
        jsnRule.AddPair('id', TJSONNumber.Create(LinkRule.ID));
        jsnRule.AddPair('level', TJSONNumber.Create(LinkRule.Level));

        ContainerInsideNodes := LinkRule.Rule.GetContainerInsideNodes;
        try
          jsnRule.AddPair('nodes', EncodeNodesToJSON(ContainerInsideNodes));
        finally
          ContainerInsideNodes.Free;
        end;

        //jsnRule.AddPair('regexps', EncodeRegExpsToJSON(JobLinksRule.RegExps));
        //jsnRule.AddPair('custom_func', CustomJS.JSFunc);
        //jsnRule.AddPair('critical', TJSONNumber.Create(JobLinksRule.CriticalType));
        jsnRules.AddElement(jsnRule);
      end;

    for RecordRule in Group.Records do
      begin
        jsnRule := TJSONObject.Create;
        jsnRule.AddPair('id', TJSONNumber.Create(RecordRule.ID));
        jsnRule.AddPair('key', RecordRule.Key);
        //jsnRule.AddPair('typeid', TJSONNumber.Create(JobRecordsRule.TypeRefID));

        ContainerInsideNodes := RecordRule.Rule.GetContainerInsideNodes;
        try
          jsnRule.AddPair('nodes', EncodeNodesToJSON(ContainerInsideNodes));
        finally
          ContainerInsideNodes.Free;
        end;

        //jsnRule.AddPair('regexps', EncodeRegExpsToJSON(JobRecordsRule.RegExps));
        //jsnRule.AddPair('custom_func', CustomJS.JSFunc);
        //jsnRule.AddPair('critical', TJSONNumber.Create(JobRecordsRule.CriticalType));
        jsnRules.AddElement(jsnRule);
      end;

    jsnGroup.AddPair('rules', jsnRules);

    JSScript := Format(JSScript, [jsnGroup.ToJSON]);
    FData.AddOrSetValue('JSScript', JSScript);
    CreateEvent('AfterJSScriptPrepared');
  finally
    ContainerNodeList.Free;
    jsnGroup.Free;
  end;
end;

procedure TModelJS.ExecuteRule(aRule: TJobRule);
begin

end;

end.
