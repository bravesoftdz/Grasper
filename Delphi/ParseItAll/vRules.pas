unit vRules;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, cefvcl, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.ImgList,
  API_MVC,
  API_ORM,
  API_ORM_Cntrls,
  eJob,
  eLevel,
  eRule,
  eRegExp,
  eRequest,
  eNodes,
  mParser,
  System.ImageList, System.Actions, Vcl.ActnList, Vcl.Menus, Vcl.ToolWin,
  VirtualTrees, Vcl.Imaging.GIFImg;

type
  TEntityPanel = class(TEntityPanelAbstract)
  protected
    procedure InitPanel; override;
  end;

  PVirtualNodeData = ^TVirtualNodeData;
  TVirtualNodeData = record
    Text: ShortString;
    KeyID: Integer;
    RuleID: Integer;
    Index: Integer;
    ClassName: string[255];
    Name: ShortString;
    TagID: string[255];
  end;

  PVirtualResult = ^TVirtualResult;
  TVirtualResult = record
    Key: ShortString;
    Value: ShortString;
  end;

  TViewRules = class(TViewORM)
    pnlBrowser: TPanel;
    pnlControls: TPanel;
    chrmBrowser: TChromium;
    pnlLevel: TPanel;
    cbbLevel: TComboBox;
    lbllevel: TLabel;
    btnAddLevel: TBitBtn;
    pnlRules: TPanel;
    tvRules: TTreeView;
    chdtDevTools: TChromiumDevTools;
    splBrw2Dev: TSplitter;
    ActionList: TActionList;
    acDevToolsActivate: TAction;
    pnlButtons: TPanel;
    btnCancel: TButton;
    btnApply: TButton;
    btnDLv: TBitBtn;
    ilRuleIcons: TImageList;
    splBrw2Cntrls: TSplitter;
    pnlTest: TPanel;
    btnGetTestPage: TBitBtn;
    pgcRuleSections: TPageControl;
    splTree2Sects: TSplitter;
    tsFields: TTabSheet;
    tsDOM: TTabSheet;
    pnlXPath: TPanel;
    btnSelectHTML: TBitBtn;
    udContainerStep: TUpDown;
    udChildStep: TUpDown;
    tsResults: TTabSheet;
    tlbRuleButtons: TToolBar;
    alRuleActions: TActionList;
    acAddContainer: TAction;
    btnContainers: TToolButton;
    acAddCut: TAction;
    acAddLink: TAction;
    btnAddCut: TToolButton;
    btnSep1: TToolButton;
    btnAddLink: TToolButton;
    btnAddRecord: TToolButton;
    acAddRecord: TAction;
    btnSep2: TToolButton;
    btnAddAction: TToolButton;
    acAddAction: TAction;
    btnSep3: TToolButton;
    btnAddRegExp: TToolButton;
    acAddRegExp: TAction;
    btnSep4: TToolButton;
    btnRemove: TToolButton;
    acRemoveRule: TAction;
    btnAddAjax: TToolButton;
    acAddRequest: TAction;
    btnTestAction: TButton;
    vstNodesFullTree: TVirtualStringTree;
    btnAssignNode: TBitBtn;
    vstResults: TVirtualStringTree;
    tsRuntimeTest: TTabSheet;
    btnRunTest: TButton;
    edtTestTime: TEdit;
    procedure btnCancelClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tvRulesChange(Sender: TObject; Node: TTreeNode);
    procedure btnSelectHTMLClick(Sender: TObject);
    procedure DevToolsActivate(Sender: Tobject);
    procedure AfterEntityPanelChange(aControl: TControl);
    //procedure udContainerStepClick(Sender: TObject; Button: TUDBtnType);
    procedure btnAddLevelClick(Sender: TObject);
    procedure cbbLevelChange(Sender: TObject);
    procedure btnDLvClick(Sender: TObject);
    procedure udContainerStepClick(Sender: TObject; Button: TUDBtnType);
    procedure btnGetTestPageClick(Sender: TObject);
    procedure acAddContainerExecute(Sender: TObject);
    procedure acAddCutExecute(Sender: TObject);
    procedure acAddLinkExecute(Sender: TObject);
    procedure acAddRecordExecute(Sender: TObject);
    procedure acAddActionExecute(Sender: TObject);
    procedure acAddRegExpExecute(Sender: TObject);
    procedure acRemoveRuleExecute(Sender: TObject);
    procedure acAddRequestExecute(Sender: TObject);
    procedure btnTestActionClick(Sender: TObject);
    procedure vstNodesFullTreeGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure vstNodesFullTreeAddToSelection(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure btnAssignNodeClick(Sender: TObject);
    procedure vstNodesFullTreePaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure vstResultsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure btnRunTestClick(Sender: TObject);
  private
    { Private declarations }
    FDevToolsEnabled: Boolean;
    FSelectedNodeKeyID: Integer;
    procedure RecourseTreeBranch(aRule: TJobRule);
    procedure AfterLevelSelected;
    procedure DefineRuleActionAllow(aEntity: TEntityAbstract);
    procedure AddNodeToTree(aParentNode: PVirtualNode; aDOMNode: TDOMNode);
  protected
    procedure InitView; override;
  public
    { Public declarations }
    pnlEntityFields: TEntityPanel;

    function GetLevelIndex: integer;
    function GetSelectedLevel: TJobLevel;
    function GetParentEntity: TEntityAbstract;
    function GetParentParentEntity: TEntityAbstract;

    function GetSelectedRule: TJobRule;
    function GetSelectedRegExp: TJobRegExp;
    function GetSelectedRequest: TJobRequest;
    function GetSelectedNodesChain: TArray<TDOMNode>;
    function TreeIndex: Integer;

    procedure RenderLevels(aLevelList: TLevelList; aIndex: Integer = 0);
    procedure RenderRulesTree(aBodyRule: TJobRule);
    procedure RenderNodesTree(aDOMTree: TDOMNode);
    procedure RenderViewResults(aViewResults: TViewResults);

    procedure AddRuleToTree(aParentRule: TJobRule; aRule: TJobRule);
    procedure AddRegExpToTree(aParentNode: TTreeNode; aRegExp: TJobRegExp);
    procedure AddRequestToTree(aParentNode: TTreeNode; aJobRequest: TJobRequest);

    procedure RemoveTreeNode;
    procedure ClearRuleTree;

    property SelectedNodeKeyID: Integer read FSelectedNodeKeyID;
  public
    {View interface procedures, can be called by Controller
    }
    procedure ExecuteJavaScript(aJavaScript: string; aFrameName: string = '');
    ////////////////////////////////////////////////////////////////////////////
  end;

var
  ViewRules: TViewRules;

implementation

{$R *.dfm}

uses
  System.UITypes,
  System.Threading;

procedure TViewRules.RenderViewResults(aViewResults: TViewResults);
var
  ViewGroup: TViewGroup;
  ViewResult: TViewResult;
  gVirtualNode, rVirtualNode: PVirtualNode;
  VirtualResult: PVirtualResult;
begin
  vstResults.Clear;

  for ViewGroup in aViewResults do
    begin
      gVirtualNode := vstResults.AddChild(nil);
      VirtualResult := vstResults.GetNodeData(gVirtualNode);
      VirtualResult^.Key := 'group';

      for ViewResult in ViewGroup.Results do
        begin
          rVirtualNode := vstResults.AddChild(gVirtualNode);
          VirtualResult := vstResults.GetNodeData(rVirtualNode);
          VirtualResult^.Key := ViewResult.Key;
          VirtualResult^.Value := ViewResult.Value;
        end;

      vstResults.Expanded[gVirtualNode] := True;
    end;
end;

procedure TViewRules.ExecuteJavaScript(aJavaScript: string; aFrameName: string = '');
begin
  chrmBrowser.Browser.MainFrame.ExecuteJavaScript(aJavaScript, aFrameName, 0);
end;

function TViewRules.GetSelectedNodesChain: TArray<TDOMNode>;
var
  VirtualNode: PVirtualNode;
  VirtualNodeData: PVirtualNodeData;
  DOMNode: TDOMNode;
begin
  VirtualNode := vstNodesFullTree.FocusedNode;

  repeat
    VirtualNodeData := vstNodesFullTree.GetNodeData(VirtualNode);
    if VirtualNodeData = nil then Break;

    DOMNode.Tag := VirtualNodeData^.Text;
    DOMNode.Index := VirtualNodeData^.Index;
    DOMNode.ClassName := VirtualNodeData^.ClassName;
    DOMNode.TagID := VirtualNodeData^.TagID;
    DOMNode.Name := VirtualNodeData^.Name;

    Result := Result + [DOMNode];

    VirtualNode := VirtualNode.Parent;

  until VirtualNodeData = nil;
end;

function TViewRules.GetSelectedRequest: TJobRequest;
var
  Entity: TEntityAbstract;
begin
  Entity := FBind.GetEntityByControl(tvRules.Selected);

  if Entity is TJobRequest then
    Result := Entity as TJobRequest
  else
    Result := nil;
end;

procedure TViewRules.AddRequestToTree(aParentNode: TTreeNode; aJobRequest: TJobRequest);
var
  RequestNode: TTreeNode;
begin
  RequestNode := tvRules.Items.AddChild(aParentNode, 'Request');

  RequestNode.ImageIndex := 7;
  RequestNode.SelectedIndex := 7;

  aParentNode.Expand(True);
  FBind.AddBind(RequestNode, aJobRequest);
end;

procedure TViewRules.AddNodeToTree(aParentNode: PVirtualNode; aDOMNode: TDOMNode);
var
  VirtualNode: PVirtualNode;
  VirtualNodeData: PVirtualNodeData;
  ChildDOMNode: TDOMNode;
begin
  VirtualNode := vstNodesFullTree.AddChild(aParentNode);
  VirtualNodeData := vstNodesFullTree.GetNodeData(VirtualNode);
  VirtualNodeData^.Text := aDOMNode.Tag;
  VirtualNodeData^.KeyID := aDOMNode.KeyID;
  VirtualNodeData^.RuleID := aDOMNode.RuleID;
  VirtualNodeData^.Index := aDOMNode.Index;
  VirtualNodeData^.ClassName := aDOMNode.ClassName;
  VirtualNodeData^.TagID := aDOMNode.TagID;
  VirtualNodeData^.Name := aDOMNode.Name;

  if aDOMNode.RuleID > 0 then
    vstNodesFullTree.Expanded[VirtualNode.Parent] := True;

  for ChildDOMNode in aDOMNode.ChildNodes do
    AddNodeToTree(VirtualNode, ChildDOMNode);
end;

procedure TViewRules.RenderNodesTree(aDOMTree: TDOMNode);
begin
  vstNodesFullTree.Clear;
  AddNodeToTree(nil, aDOMTree);
end;

procedure TViewRules.DefineRuleActionAllow(aEntity: TEntityAbstract);
var
  Action: TContainedAction;
  Rule: TJobRule;
begin
  for Action in alRuleActions do
    begin
      Action.Enabled := True;
    end;

  if aEntity is TJobRule then
    begin
      Rule := aEntity as TJobRule;

      if Rule.IsBodyRule then
        acRemoveRule.Enabled := False;
    end;
end;

procedure TViewRules.ClearRuleTree;
var
  Node: TTreeNode;
begin
  for Node in tvRules.Items do
    FBind.RemoveBind(Node);

  tvRules.Items.Clear;
end;

function TViewRules.TreeIndex: Integer;
begin
  Result := tvRules.Selected.Index;
end;

function TViewRules.GetParentEntity: TEntityAbstract;
var
  Node: TTreeNode;
begin
  Node := tvRules.Selected.Parent;
  Result := FBind.GetEntityByControl(Node);
end;

function TViewRules.GetParentParentEntity: TEntityAbstract;
var
  Node: TTreeNode;
begin
  Node := tvRules.Selected.Parent.Parent;
  Result := FBind.GetEntityByControl(Node);
end;

procedure TViewRules.RemoveTreeNode;
begin
  tvRules.Selected.Delete;
end;

procedure TViewRules.acAddRecordExecute(Sender: TObject);
begin
  SendMessage('AddRecord');
end;

procedure TViewRules.acAddRegExpExecute(Sender: TObject);
begin
  SendMessage('AddRegExp');
end;

procedure TViewRules.acRemoveRuleExecute(Sender: TObject);
var
  Entity: TEntityAbstract;
begin
  Entity := FBind.GetEntityByControl(tvRules.Selected);

  if Entity is TJobRule then
    SendMessage('RemoveRule')
  else if Entity is TJobRegExp then
    SendMessage('RemoveRegExp')
  else if Entity is TJobRequest then
    SendMessage('RemoveRequest');
end;

procedure TViewRules.acAddActionExecute(Sender: TObject);
begin
  SendMessage('AddAction');
end;

procedure TViewRules.acAddRequestExecute(Sender: TObject);
begin
  SendMessage('AddRequest');
end;

procedure TViewRules.acAddContainerExecute(Sender: TObject);
begin
  SendMessage('AddContainer');
end;

procedure TViewRules.acAddCutExecute(Sender: TObject);
begin
  SendMessage('AddCut');
end;

procedure TViewRules.acAddLinkExecute(Sender: TObject);
begin
  SendMessage('AddLink');
end;

procedure TViewRules.AddRegExpToTree(aParentNode: TTreeNode; aRegExp: TJobRegExp);
var
  RegExpNode: TTreeNode;
begin
  RegExpNode := tvRules.Items.AddChild(aParentNode, aRegExp.Notes);

  RegExpNode.ImageIndex := 3;
  RegExpNode.SelectedIndex := 3;

  aParentNode.Expand(True);
  FBind.AddBind(RegExpNode, aRegExp);
end;

procedure TViewRules.AddRuleToTree(aParentRule: TJobRule; aRule: TJobRule);
var
  RuleNode, ParentNode: TTreeNode;
  JobRegExp: TJobRegExp;
begin
  if aParentRule <> nil then
    ParentNode := TTreeNode(FBind.GetControlByEntity(aParentRule))
  else
    ParentNode := nil;

  RuleNode := tvRules.Items.AddChild(ParentNode, aRule.Notes);

  if aRule.Link <> nil then
    begin
      RuleNode.ImageIndex := 0;
      RuleNode.SelectedIndex := 0;
    end
  else if aRule.Rec <> nil then
    begin
      RuleNode.ImageIndex := 1;
      RuleNode.SelectedIndex := 1;
    end
  else if aRule.Cut <> nil then
    begin
      RuleNode.ImageIndex := 2;
      RuleNode.SelectedIndex := 2;
    end
  else if aRule.Action <> nil then
    begin
      RuleNode.ImageIndex := 5;
      RuleNode.SelectedIndex := 5;
    end
  else
    begin
      RuleNode.ImageIndex := 4;
      RuleNode.SelectedIndex := 4;
    end;

  for JobRegExp in aRule.RegExps do
    AddRegExpToTree(RuleNode, JobRegExp);

  if aRule.Request <> nil then
    AddRequestToTree(RuleNode, aRule.Request);

  if ParentNode <> nil then ParentNode.Expand(True);
  FBind.AddBind(RuleNode, aRule);
end;

procedure TViewRules.AfterLevelSelected;
begin
  pnlEntityFields.ClearControls;
  pnlXPath.Visible := False;

  if GetSelectedLevel <> nil then
    begin
      //chrmBrowser.Enabled := False;
      //chrmBrowser.Load(GetSelectedLevel.TestLink);
      SendMessage('LevelSelected');
      RenderRulesTree(GetSelectedLevel.BodyRule);
    end
  else
    ClearRuleTree;
end;

function TViewRules.GetSelectedRule: TJobRule;
var
  Entity: TEntityAbstract;
begin
  Entity := FBind.GetEntityByControl(tvRules.Selected);

  if Entity is TJobRule then
    Result := Entity as TJobRule
  else
    Result := nil;
end;

function TViewRules.GetSelectedRegExp: TJobRegExp;
var
  Entity: TEntityAbstract;
begin
  Entity := FBind.GetEntityByControl(tvRules.Selected);

  if Entity is TJobRegExp then
    Result := Entity as TJobRegExp
  else
    Result := nil;
end;

function TViewRules.GetSelectedLevel: TJobLevel;
begin
  Result := FBind.GetEntityByControl(cbbLevel, GetLevelIndex) as TJobLevel;
end;

function TViewRules.GetLevelIndex: integer;
begin
  Result := cbbLevel.ItemIndex;
end;

procedure TViewRules.AfterEntityPanelChange(aControl: TControl);
begin
  if aControl.Name = 'cntrlVISUAL_COLOR' then
    SendMessage('TreeNodeSelected');

  if aControl.Name = 'cntrlNOTES' then
    tvRules.Selected.Text := (aControl as TEdit).Text;
end;

procedure TEntityPanel.InitPanel;
begin
  OnAfterEditChange := ViewRules.AfterEntityPanelChange;
end;

procedure TViewRules.RecourseTreeBranch(aRule: TJobRule);
var
  ChildRuleRel: TRuleRuleRel;
begin
  for ChildRuleRel in aRule.ChildRuleRels do
    begin
      AddRuleToTree(aRule, ChildRuleRel.ChildRule);

      RecourseTreeBranch(ChildRuleRel.ChildRule);
    end;
end;

procedure TViewRules.RenderRulesTree(aBodyRule: TJobRule);
begin
  ClearRuleTree;
  AddRuleToTree(nil, aBodyRule);
  RecourseTreeBranch(aBodyRule);
end;

procedure TViewRules.RenderLevels(aLevelList: TLevelList; aIndex: Integer = 0);
var
  Level: TJobLevel;
  i: Integer;
begin
  cbbLevel.Items.Clear;

  for Level in aLevelList  do
    begin
      i := cbbLevel.Items.Add(Level.Level.ToString);
      FBind.AddBind(cbbLevel, Level, i);
    end;

  cbbLevel.ItemIndex := aIndex;
  AfterLevelSelected;
end;

procedure TViewRules.tvRulesChange(Sender: TObject; Node: TTreeNode);
var
  Entity, ParentEntity: TEntityAbstract;
begin
  pnlXPath.Visible := False;
  btnAddLevel.Enabled := False;
  btnSelectHTML.Enabled := False;

  Entity := FBind.GetEntityByControl(Node);
  pnlEntityFields.ClearControls;
  pnlEntityFields.BuildControls(Entity);

  DefineRuleActionAllow(Entity);

  if Entity is TJobRule then
    begin
      pnlXPath.Visible := True;

      //btnAddLevel.Enabled := FController.Data.Items['CanAddLevel'];

      ParentEntity := GetParentEntity;
      if  (ParentEntity = nil) then
        btnSelectHTML.Enabled := True
      else
        if (ParentEntity as TJobRule).Nodes.Count > 0 then
          btnSelectHTML.Enabled := True;

      SendMessage('RuleSelected');
    end;
end;

procedure TViewRules.udContainerStepClick(Sender: TObject; Button: TUDBtnType);
begin
  if Button = btNext then
    GetSelectedRule.ContainerOffset := GetSelectedRule.ContainerOffset + 1
  else
    if GetSelectedRule.ContainerOffset > 0 then
      GetSelectedRule.ContainerOffset := GetSelectedRule.ContainerOffset - 1;

  pnlEntityFields.ClearControls;
  pnlEntityFields.BuildControls(GetSelectedRule);

  SendMessage('OnRuleSelected');
end;

procedure TViewRules.vstNodesFullTreeAddToSelection(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  VirtualNodeData: PVirtualNodeData;
begin
  VirtualNodeData := Sender.GetNodeData(Node);
  FSelectedNodeKeyID := VirtualNodeData^.KeyID;

  SendMessage('OnNodeSelected');
end;

procedure TViewRules.vstNodesFullTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  VirtualNodeData: PVirtualNodeData;
begin
  VirtualNodeData := Sender.GetNodeData(Node);

  //CellText := VirtualNodeData^.Text;
  CellText := Format('%s[%d] id(%s) class(%s)', [
    VirtualNodeData^.Text,
    VirtualNodeData^.Index,
    VirtualNodeData^.TagID,
    VirtualNodeData^.ClassName
  ]);
end;

procedure TViewRules.vstNodesFullTreePaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
var
  VirtualNodeData: PVirtualNodeData;
begin
  VirtualNodeData := Sender.GetNodeData(Node);
  TargetCanvas.Font.Style := [fsBold];

  if VirtualNodeData^.RuleID > 0 then
    TargetCanvas.Font.Color := clRed;
end;

procedure TViewRules.vstResultsGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  VirtualResult: PVirtualResult;
begin
  VirtualResult := Sender.GetNodeData(Node);

  if VirtualResult^.Key = 'group' then
    CellText := VirtualResult^.Key
  else
    CellText := Format('%s: %s', [VirtualResult^.Key, VirtualResult^.Value]);
end;

procedure TViewRules.btnTestActionClick(Sender: TObject);
begin
  SendMessage('TestAction');
end;

procedure TViewRules.btnAddLevelClick(Sender: TObject);
begin
  SendMessage('SelectNewLevelLink');
end;

procedure TViewRules.btnApplyClick(Sender: TObject);
begin
  SendMessage('StoreJobRules');
end;

procedure TViewRules.btnAssignNodeClick(Sender: TObject);
begin
  SendMessage('AssignNodeToRule');
end;

procedure TViewRules.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TViewRules.btnDLvClick(Sender: TObject);
begin
  SendMessage('DeleteLevel');
end;

procedure TViewRules.btnGetTestPageClick(Sender: TObject);
begin
  SendMessage('GetNextTestPage');
end;

procedure TViewRules.btnSelectHTMLClick(Sender: TObject);
begin
  SendMessage('SelectHTMLNode');
end;

procedure TViewRules.btnRunTestClick(Sender: TObject);
begin
  SendMessage('RunLevelTest');
end;

procedure TViewRules.cbbLevelChange(Sender: TObject);
begin
  AfterLevelSelected;
end;

procedure TViewRules.FormCreate(Sender: TObject);
begin
  pnlEntityFields := TEntityPanel.Create(tsFields);
  vstNodesFullTree.NodeDataSize := SizeOf(TVirtualNodeData);
  vstResults.NodeDataSize := SizeOf(TVirtualResult);
end;

procedure TViewRules.DevToolsActivate(Sender: Tobject);
begin
  if FDevToolsEnabled then
    begin
      chdtDevTools.CloseDevTools(chrmBrowser.Browser);
      splBrw2Dev.Visible := False;
      chdtDevTools.Visible := False;

      FDevToolsEnabled := False;
    end
  else
    begin
      chdtDevTools.Visible := True;
      splBrw2Dev.Visible := True;
      chdtDevTools.ShowDevTools(chrmBrowser.Browser);

      FDevToolsEnabled := True;
    end;
end;

procedure TViewRules.InitView;
begin
  ViewRules := Self;
end;

end.
