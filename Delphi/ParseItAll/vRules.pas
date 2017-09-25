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
  System.ImageList, System.Actions, Vcl.ActnList, Vcl.Menus;

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
    pnlTree: TPanel;
    pnlFields: TPanel;
    tvTree: TTreeView;
    ilButtons: TImageList;
    pnlXPath: TPanel;
    btnSelectHTML: TBitBtn;
    chdtDevTools: TChromiumDevTools;
    Splitter: TSplitter;
    ActionList: TActionList;
    acDevToolsActivate: TAction;
    pnlButtons: TPanel;
    btnCancel: TButton;
    btnApply: TButton;
    udContainerStep: TUpDown;
    pmTreeItemPopup: TPopupMenu;
    mniAddCut: TMenuItem;
    btnDLv: TBitBtn;
    udChildStep: TUpDown;
    btnAddURL: TSpeedButton;
    acAddLink: TAction;
    imgIcons: TImage;
    ilIcons: TImageList;
    btnAddRecord: TSpeedButton;
    acAddRecord: TAction;
    btnRemove: TSpeedButton;
    acRemove: TAction;
    acAddChildLink: TAction;
    mniAddLinkSameGroup: TMenuItem;
    acAddChildRecord: TAction;
    mniAddRecSameGroup: TMenuItem;
    acAddChildCut: TAction;
    btnAddCut: TSpeedButton;
    acAddCut: TAction;
    acAddRegExp: TAction;
    mniAddRegExp: TMenuItem;
    btnGetTestPage: TBitBtn;
    btnAddContainer: TSpeedButton;
    acAddContainer: TAction;
    acAddAction: TAction;
    btnAddAction: TSpeedButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tvTreeChange(Sender: TObject; Node: TTreeNode);
    procedure btnALClick(Sender: TObject);
    procedure btnSelectHTMLClick(Sender: TObject);
    procedure DevToolsActivate(Sender: Tobject);
    procedure AfterEntityPanelChange(aControl: TControl);
    //procedure udContainerStepClick(Sender: TObject; Button: TUDBtnType);
    procedure btnAddLevelClick(Sender: TObject);
    procedure cbbLevelChange(Sender: TObject);
    procedure tvTreeDblClick(Sender: TObject);
    procedure btnDLvClick(Sender: TObject);
    procedure acAddLinkExecute(Sender: TObject);
    procedure acAddRecordExecute(Sender: TObject);
    procedure acRemoveExecute(Sender: TObject);
    procedure acAddChildLinkExecute(Sender: TObject);
    procedure acAddChildRecordExecute(Sender: TObject);
    procedure acAddChildCutExecute(Sender: TObject);
    procedure acAddCutExecute(Sender: TObject);
    procedure acAddRegExpExecute(Sender: TObject);
    procedure udContainerStepClick(Sender: TObject; Button: TUDBtnType);
    procedure btnGetTestPageClick(Sender: TObject);
    procedure acAddContainerExecute(Sender: TObject);
    procedure acAddActionExecute(Sender: TObject);
  private
    { Private declarations }
    FDevToolsEnabled: Boolean;
    procedure AfterLevelSelected;
  protected
    procedure InitView; override;
  public
    { Public declarations }
    pnlEntityFields: TEntityPanel;

    function GetLevelIndex: integer;
    function GetSelectedLevel: TJobLevel;
    function GetParentEntity: TEntityAbstract;

    function GetSelectedRule: TJobRule;
    function GetSelectedRootRule: TJobRule;
    function TreeIndex: Integer;

    procedure SetLevels(aLevelList: TLevelList; aIndex: Integer = 0);
    procedure RenderLevelRulesTree(aLevelRules: TLevelRuleRelList);
    procedure RecourseTreeBranch(aRule: TJobRule);
    procedure AddRuleToTree(aParentRule: TJobRule; aRule: TJobRule);
    procedure AddRegExpToTree(aParentRule: TJobRule; aRegExp: TJobRegExp);
    procedure RemoveTreeNode;
    procedure ClearRuleTree;
  end;

var
  ViewRules: TViewRules;

implementation

{$R *.dfm}

uses
  System.UITypes;

procedure TViewRules.ClearRuleTree;
var
  Node: TTreeNode;
begin
  for Node in tvTree.Items do
    FBind.RemoveBind(Node);

  tvTree.Items.Clear;
end;

function TViewRules.GetSelectedRootRule: TJobRule;
var
  isRootLevel: Boolean;
  CurrNode: TTreeNode;
begin
  Result := nil;
  isRootLevel := False;
  CurrNode := tvTree.Selected;

  repeat
    if CurrNode.Level = 0 then
      begin
        isRootLevel := True;
        Result := FBind.GetEntityByControl(CurrNode) as TJobRule;
      end;

    CurrNode := CurrNode.Parent;
  until isRootLevel;
end;

function TViewRules.TreeIndex: Integer;
begin
  Result := tvTree.Selected.Index;
end;

function TViewRules.GetParentEntity: TEntityAbstract;
var
  Node: TTreeNode;
begin
  Node := tvTree.Selected.Parent;
  Result := FBind.GetEntityByControl(Node);
end;

procedure TViewRules.RemoveTreeNode;
begin
  tvTree.Selected.Delete;
end;

procedure TViewRules.acAddChildLinkExecute(Sender: TObject);
begin
  SendMessage('AddChildLink');
end;

procedure TViewRules.acAddRecordExecute(Sender: TObject);
begin
  SendMessage('AddRecord');
end;

procedure TViewRules.acAddRegExpExecute(Sender: TObject);
begin
  SendMessage('AddRegExp');
end;

procedure TViewRules.acAddChildRecordExecute(Sender: TObject);
begin
  SendMessage('AddChildRecord');
end;

procedure TViewRules.acAddContainerExecute(Sender: TObject);
begin
  SendMessage('AddContainer');
end;

procedure TViewRules.acAddCutExecute(Sender: TObject);
begin
  SendMessage('AddChildCut');
end;

procedure TViewRules.acRemoveExecute(Sender: TObject);
var
  Entity: TEntityAbstract;
begin
  Entity := FBind.GetEntityByControl(tvTree.Selected);

  if Entity is TJobRule then
    SendMessage('RemoveRule');
end;

procedure TViewRules.AddRegExpToTree(aParentRule: TJobRule; aRegExp: TJobRegExp);
var
  RegExpNode, ParentNode: TTreeNode;
begin
  ParentNode := TTreeNode(FBind.GetControlByEntity(aParentRule));
  RegExpNode := tvTree.Items.AddChild(ParentNode, aRegExp.Notes);

  RegExpNode.ImageIndex := 3;
  RegExpNode.SelectedIndex := 3;

  ParentNode.Expand(True);
  FBind.AddBind(RegExpNode, aRegExp);
end;

procedure TViewRules.AddRuleToTree(aParentRule: TJobRule; aRule: TJobRule);
var
  RuleNode, ParentNode: TTreeNode;
begin
  if aParentRule <> nil then
    ParentNode := TTreeNode(FBind.GetControlByEntity(aParentRule))
  else
    ParentNode := nil;

  RuleNode := tvTree.Items.AddChild(ParentNode, aRule.Notes);

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
      RenderLevelRulesTree(GetSelectedLevel.RuleRels);
    end
  else
    ClearRuleTree;
end;

function TViewRules.GetSelectedRule: TJobRule;
begin
  Result := FBind.GetEntityByControl(tvTree.Selected) as TJobRule;
end;

function TViewRules.GetSelectedLevel: TJobLevel;
begin
  Result := FBind.GetEntityByControl(cbbLevel, GetLevelIndex) as TJobLevel;
end;

function TViewRules.GetLevelIndex: integer;
begin
  Result := cbbLevel.ItemIndex;
end;

procedure TViewRules.acAddActionExecute(Sender: TObject);
begin
  SendMessage('AddAction');
end;

procedure TViewRules.acAddChildCutExecute(Sender: TObject);
begin
  SendMessage('AddChildCut');
end;

procedure TViewRules.acAddLinkExecute(Sender: TObject);
begin
  SendMessage('AddLink');
end;

procedure TViewRules.AfterEntityPanelChange(aControl: TControl);
begin
  if aControl.Name = 'cntrlVISUAL_COLOR' then
    SendMessage('TreeNodeSelected');

  if aControl.Name = 'cntrlNOTES' then
    tvTree.Selected.Text := (aControl as TEdit).Text;
end;

procedure TEntityPanel.InitPanel;
begin
  OnAfterEditChange := ViewRules.AfterEntityPanelChange;
end;

procedure TViewRules.RecourseTreeBranch(aRule: TJobRule);
var
  ChildRuleRel: TRuleRuleRel;
  RegExp: TJobRegExp;
begin
  for ChildRuleRel in aRule.ChildRuleRels do
    begin
      AddRuleToTree(aRule, ChildRuleRel.ChildRule);

      for RegExp in ChildRuleRel.ChildRule.RegExps do
        AddRegExpToTree(ChildRuleRel.ChildRule, RegExp);

      RecourseTreeBranch(ChildRuleRel.ChildRule);
    end;
end;

procedure TViewRules.RenderLevelRulesTree(aLevelRules: TLevelRuleRelList);
var
  LevelRuleRel: TLevelRuleRel;
  CurrentRule: TJobRule;
  RegExp: TJobRegExp;
begin
  ClearRuleTree;

  for LevelRuleRel in aLevelRules do
    begin
      CurrentRule := LevelRuleRel.Rule;
      AddRuleToTree(nil, CurrentRule);

      for RegExp in CurrentRule.RegExps do
        AddRegExpToTree(CurrentRule, RegExp);

      RecourseTreeBranch(CurrentRule);
    end;
end;

procedure TViewRules.SetLevels(aLevelList: TLevelList; aIndex: Integer = 0);
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

procedure TViewRules.tvTreeChange(Sender: TObject; Node: TTreeNode);
var
  Entity, ParentEntity: TEntityAbstract;
begin
  pnlXPath.Visible := False;
  btnAddLevel.Enabled := False;
  btnSelectHTML.Enabled := False;

  Entity := FBind.GetEntityByControl(Node);
  pnlEntityFields.ClearControls;
  pnlEntityFields.BuildControls(Entity);

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

procedure TViewRules.tvTreeDblClick(Sender: TObject);
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

procedure TViewRules.btnAddLevelClick(Sender: TObject);
begin
  SendMessage('SelectNewLevelLink');
end;

procedure TViewRules.btnApplyClick(Sender: TObject);
begin
  SendMessage('StoreJobRules');
end;

procedure TViewRules.btnALClick(Sender: TObject);
begin
  SendMessage('CreateLink');
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
  pnlEntityFields := TEntityPanel.Create(pnlFields);
end;

procedure TViewRules.DevToolsActivate(Sender: Tobject);
begin
  if FDevToolsEnabled then
    begin
      chdtDevTools.CloseDevTools(chrmBrowser.Browser);
      Splitter.Visible := False;
      chdtDevTools.Visible := False;

      FDevToolsEnabled := False;
    end
  else
    begin
      chdtDevTools.Visible := True;
      Splitter.Visible := True;
      chdtDevTools.ShowDevTools(chrmBrowser.Browser);

      FDevToolsEnabled := True;
    end;
end;

procedure TViewRules.InitView;
begin
  ViewRules := Self;
end;

end.
