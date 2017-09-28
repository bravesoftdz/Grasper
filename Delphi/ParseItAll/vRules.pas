unit vRules;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, cefvcl, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.ImgList,
  System.JSON,
  API_MVC,
  API_ORM,
  API_ORM_Cntrls,
  eJob,
  eLevel,
  eRule,
  eRegExp,
  eRequest,
  System.ImageList, System.Actions, Vcl.ActnList, Vcl.Menus, Vcl.ToolWin;

type
  TEntityPanel = class(TEntityPanelAbstract)
  protected
    procedure InitPanel; override;
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
    btn1: TButton;
    tvNodesFull: TTreeView;
    tsRequests: TTabSheet;
    lvRequests: TListView;
    btnAddAjax: TToolButton;
    acAddRequest: TAction;
    tlbRequestButtons: TToolBar;
    alRequestActions: TActionList;
    acAssignRequest: TAction;
    btnAssignRequest: TToolButton;
    btn2: TButton;
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
    procedure tvRulesDblClick(Sender: TObject);
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
    procedure btn1Click(Sender: TObject);
    procedure acAddRequestExecute(Sender: TObject);
    procedure acAssignRequestExecute(Sender: TObject);
    procedure btn2Click(Sender: TObject);
  private
    { Private declarations }
    FDevToolsEnabled: Boolean;
    procedure RecourseTreeBranch(aRule: TJobRule);
    procedure AfterLevelSelected;
    procedure DefineRuleActionAllow(aEntity: TEntityAbstract);
    procedure AddNodeToTree(aTreeNode: TTreeNode; ajsnNode: TJSONObject);
  protected
    procedure InitView; override;
  public
    { Public declarations }
    pnlEntityFields: TEntityPanel;

    function GetLevelIndex: integer;
    function GetSelectedLevel: TJobLevel;
    function GetParentEntity: TEntityAbstract;

    function GetSelectedRule: TJobRule;
    function GetSelectedRegExp: TJobRegExp;
    function GetSelectedRequest: TJobRequest;
    function TreeIndex: Integer;

    procedure RenderLevels(aLevelList: TLevelList; aIndex: Integer = 0);
    procedure RenderRulesTree(aBodyRule: TJobRule);
    procedure RenderNodesTree(ajsnNodes: TJSONObject);
    procedure RenderBackgroundRequest(aMethod, aUrl: string);

    procedure AddRuleToTree(aParentRule: TJobRule; aRule: TJobRule);
    procedure AddRegExpToTree(aParentNode: TTreeNode; aRegExp: TJobRegExp);
    procedure AddRequestToTree(aParentNode: TTreeNode; aJobRequest: TJobRequest);

    procedure RemoveTreeNode;
    procedure ClearRuleTree;
  end;

var
  ViewRules: TViewRules;

implementation

{$R *.dfm}

uses
  System.UITypes,
  System.Threading;

procedure TViewRules.RenderBackgroundRequest(aMethod, aUrl: string);
var
  Task: ITask;
  item: TListItem;
begin
  Task := TTask.Create(procedure
    begin
      item := lvRequests.Items.Add;

      item.Caption := aMethod;
      item.SubItems.Add(aUrl);
    end
  );
  Task.Start;
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

procedure TViewRules.AddNodeToTree(aTreeNode: TTreeNode; ajsnNode: TJSONObject);
var
  Node: TTreeNode;
  jsnNode: TJSONValue;
  NodeVal: string;
  TagID, ClassName, Value: string;
  RuleNodeID: integer;
begin
  if ajsnNode.TryGetValue('tagID', Value) then
    if not Value.IsEmpty then TagID := 'id: ' + Value;

  if ajsnNode.TryGetValue('className', Value) then
    if not Value.IsEmpty then ClassName := 'class: ' + Value;  

  NodeVal := Format('%s[%d] %s %s', [
    ajsnNode.GetValue('tagName').Value,
    TJSONNumber(ajsnNode.GetValue('index')).asInt,
    TagID,
    ClassName
  ]);     

  Node := tvNodesFull.Items.AddChild(aTreeNode, NodeVal);
  Node.ImageIndex := 4;
  Node.SelectedIndex := 4;

  if ajsnNode.TryGetValue<integer>('ruleNodeID', RuleNodeID) then
    begin
      Node.Text := RuleNodeID.ToString + ' ' + Node.Text; 
      if Node.Parent <> nil then Node.Parent.Expand(False);      
    end;

  for jsnNode in ajsnNode.GetValue('children') as TJSONArray do
    begin
      AddNodeToTree(Node, TJSONObject(jsnNode));
    end;
end;

procedure TViewRules.RenderNodesTree(ajsnNodes: TJSONObject);
begin
  AddNodeToTree(nil, ajsnNodes);
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

procedure TViewRules.acAssignRequestExecute(Sender: TObject);
begin
  {if lvRequests.Selected.Caption = 'GET' then
    GetSelectedRequest.Method := 1;

  if lvRequests.Selected.Caption = 'POST' then
    GetSelectedRequest.Method := 2;

  GetSelectedRequest.Link := lvRequests.Selected.SubItems[0]; }
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
      chrmBrowser.Load(GetSelectedLevel.TestLink);
      RenderRulesTree(GetSelectedLevel.BodyRule);
    end
  else
    ClearRuleTree;

  lvRequests.Clear;
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

      SendMessage('OnRuleSelected');
    end;
end;

procedure TViewRules.tvRulesDblClick(Sender: TObject);
begin
  SendMessage('ShowRuleResult');
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

procedure TViewRules.btn1Click(Sender: TObject);
begin
  SendMessage('Test');
end;

procedure TViewRules.btn2Click(Sender: TObject);
begin
  SendMessage('Test');
end;

procedure TViewRules.btnAddLevelClick(Sender: TObject);
begin
  SendMessage('SelectNewLevelLink');
end;

procedure TViewRules.btnApplyClick(Sender: TObject);
begin
  SendMessage('StoreJobRules');
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

procedure TViewRules.cbbLevelChange(Sender: TObject);
begin
  AfterLevelSelected;
end;

procedure TViewRules.FormCreate(Sender: TObject);
begin
  pnlEntityFields := TEntityPanel.Create(tsFields);
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
