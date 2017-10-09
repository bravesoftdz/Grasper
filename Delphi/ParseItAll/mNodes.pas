unit mNodes;

interface

uses
  System.JSON,
  API_MVC_DB,
  eNodes;

type
  TModelNodes = class(TModelDB)
  private
    procedure ProcessDOMNode(aDOMNode: TJSONObject; aRuleNodeList: TNodeList; var aParentDOMNode: TDOMNode);
  published
    procedure GetVirtualNodeTree;
    procedure GetJSONNodesChain;
  end;

  TWrapModelNodes = class
  public
    VirtualDOMTree: TDOMNode;
    NodesChain: TArray<TDOMNode>;
  end;

implementation

procedure TModelNodes.GetJSONNodesChain;
var
  NodesChain: TArray<TDOMNode>;
  DOMNode: TDOMNode;
  jsnNodesChain: TJSONArray;
  jsnNode: TJSONObject;
  i: integer;
begin
  NodesChain := (FObjData.Items['NodesChain'] as TWrapModelNodes).NodesChain;
  jsnNodesChain := TJSONArray.Create;

  for i := Length(NodesChain) - 1 downto 0 do
    begin
      DOMNode := NodesChain[i];

      jsnNode := TJSONObject.Create;
      jsnNode.AddPair('tag', DOMNode.Tag);
      jsnNode.AddPair('index', TJSONNumber.Create(DOMNode.Index));
      jsnNode.AddPair('tagID', DOMNode.TagID);
      jsnNode.AddPair('className', DOMNode.ClassName);
      jsnNode.AddPair('name', DOMNode.Name);

      jsnNodesChain.AddElement(jsnNode);
    end;

  FObjData.AddOrSetValue('JSONNodesChain', jsnNodesChain);
end;

procedure TModelNodes.ProcessDOMNode(aDOMNode: TJSONObject; aRuleNodeList: TNodeList; var aParentDOMNode: TDOMNode);
var
  jsnChildren: TJSONArray;
  jsnChildNode: TJSONValue;
  DOMNode: TDOMNode;
begin
  DOMNode.KeyID := TJSONNumber(aDOMNode.GetValue('key_id')).AsInt;
  DOMNode.RuleID := TJSONNumber(aDOMNode.GetValue('rule_node_id')).AsInt;
  DOMNode.Tag := aDOMNode.GetValue('tag').Value;
  DOMNode.Index := TJSONNumber(aDOMNode.GetValue('index')).AsInt;
  DOMNode.ClassName := aDOMNode.GetValue('class_name').Value;
  DOMNode.TagID := aDOMNode.GetValue('tag_id').Value;
  DOMNode.Name := aDOMNode.GetValue('name').Value;

  jsnChildren := aDOMNode.GetValue('children') as TJSONArray;
  for jsnChildNode in jsnChildren do
    ProcessDOMNode(TJSONObject(jsnChildNode), aRuleNodeList, DOMNode);

  if aParentDOMNode.Tag <> '' then
    aParentDOMNode.ChildNodes := aParentDOMNode.ChildNodes + [DOMNode]
  else
    aParentDOMNode := DOMNode;
end;

procedure TModelNodes.GetVirtualNodeTree;
var
  jsnDOMFullTree: TJSONObject;
  RuleNodeList: TNodeList;
  DOMNode: TDOMNode;
  WrapObj: TWrapModelNodes;
begin
  jsnDOMFullTree := FObjData.Items['jsnDOMFullTree'] as TJSONObject;
  RuleNodeList := FObjData.Items['RuleNodeList'] as TNodeList;

  ProcessDOMNode(jsnDOMFullTree, RuleNodeList, DOMNode);

  WrapObj := TWrapModelNodes.Create;
  WrapObj.VirtualDOMTree := DOMNode;
  FObjData.AddOrSetValue('VirtualDOMTree', WrapObj);
end;

end.
