unit mParser;

interface

uses
  System.JSON,
  System.UITypes,
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

implementation

uses
  System.SysUtils,
  API_Files;

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
