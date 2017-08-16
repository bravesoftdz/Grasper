unit vRules;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, cefvcl, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.ImgList,
  API_MVC,
  API_ORM,
  API_ORM_Cntrls,
  eEntities,
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
  private
    { Private declarations }
    FDevToolsEnabled: Boolean;
  protected
    procedure InitView; override;
  public
    { Public declarations }
    pnlEntityFields: TEntityPanel;

    function GetLevelIndex: integer;
    function GetSelectedLevel: TJobLevel;
    //function GetSelectedGroup: TJobGroup;
    function GetParentEntity: TEntityAbstract;

    function GetSelectedRule: TJobRule;
    function TreeIndex: Integer;

    procedure SetLevels(aLevelList: TLevelList; aIndex: Integer = 0);
    procedure RenderLevelRulesTree(aLevelRules: TLevelRuleRelList);
    procedure RecourseTreeBranch(aRule: TJobRule);
    procedure AfterLevelSelected;

    procedure AddRuleToTree(aParentRule: TJobRule; aRule: TJobRule);
    procedure AddRegExpToTree(aParentRule: TJobRule; aRegExp: TJobRegExp);
    //procedure AddGroupToTree(aGroup: TJobGroup; aSibling: TTreeNode = nil);
    procedure RemoveTreeNode;
  end;

var
  ViewRules: TViewRules;

implementation

{$R *.dfm}

uses
  System.UITypes;

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
    end;

  if aRule.Rec <> nil then
    begin
      RuleNode.ImageIndex := 1;
      RuleNode.SelectedIndex := 1;
    end;

  if aRule.Cut <> nil then
    begin
      RuleNode.ImageIndex := 2;
      RuleNode.SelectedIndex := 2;
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
      chrmBrowser.Load(GetSelectedLevel.BaseLink);
      RenderLevelRulesTree(GetSelectedLevel.Rules);
    end
  else
    tvTree.Items.Clear;
end;

function TViewRules.GetSelectedRule: TJobRule;
begin
  Result := FBind.GetEntityByControl(tvTree.Selected) as TJobRule;
end;

{function TViewRules.GetSelectedGroup: TJobGroup;
begin
  //Result := GetSelectedLevel.Groups.Items[GetGroupIndex];
end; }

function TViewRules.GetSelectedLevel: TJobLevel;
begin
  if GetLevelIndex >= 0 then
    Result := (FController.ObjData.Items['Job'] as TJob).Levels[GetLevelIndex]
  else
    Result := nil;
end;

function TViewRules.GetLevelIndex: integer;
begin
  Result := cbbLevel.ItemIndex;
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
  for ChildRuleRel in aRule.ChildRules do
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
  tvTree.Items.Clear;
  //tvTree.OnChange := nil;
  //tvTree.OnChange := tvTreeChange;

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
begin
  cbbLevel.Items.Clear;

  for Level in aLevelList  do
    begin
      cbbLevel.Items.Add(Level.Level.ToString);
    end;

  cbbLevel.ItemIndex := aIndex;
  SendMessage('LevelSelected');
end;

procedure TViewRules.tvTreeChange(Sender: TObject; Node: TTreeNode);
var
  Entity: TEntityAbstract;
begin
  pnlXPath.Visible := False;
  btnAddLevel.Enabled := False;

  {case Node.Level of
    {0:  begin
          SendMessage('GroupSelected');
          Entity := GetSelectedGroup;
        end;

    0:  begin
          SendMessage('RuleSelected');
          Entity := GetSelectedRule;

          pnlXPath.Visible := True;
          btnAddLevel.Enabled := FController.Data.Items['CanAddLevel'];
        end;
  end; }

  Entity := FBind.GetEntityByControl(Node);

  pnlEntityFields.ClearControls;
  pnlEntityFields.BuildControls(Entity);
end;

procedure TViewRules.tvTreeDblClick(Sender: TObject);
begin
  if tvTree.Selected.Level = 1 then
    SendMessage('ShowRuleResult');
end;

{procedure TViewRules.udContainerStepClick(Sender: TObject; Button: TUDBtnType);
begin
  if Button = btNext then
    GetSelectedRule.ContainerOffset := GetSelectedRule.ContainerOffset + 1
  else
    if GetSelectedRule.ContainerOffset > 0 then
      GetSelectedRule.ContainerOffset := GetSelectedRule.ContainerOffset - 1;

  pnlEntityFields.ClearControls;
  pnlEntityFields.BuildControls(GetSelectedRule);

  SendMessage('RuleSelected');
end; }

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

procedure TViewRules.btnSelectHTMLClick(Sender: TObject);
begin
  SendMessage('SelectHTMLNode');
end;

procedure TViewRules.cbbLevelChange(Sender: TObject);
begin
  SendMessage('LevelSelected');
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
