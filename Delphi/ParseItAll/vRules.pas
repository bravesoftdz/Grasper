unit vRules;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, cefvcl, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.ImgList,
  API_MVC,
  API_ORM,
  API_ORM_Cntrls,
  eEntities, System.ImageList, System.Actions, Vcl.ActnList, Vcl.Menus;

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
    btnAG: TBitBtn;
    ilButtons: TImageList;
    btnDG: TBitBtn;
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
    acAddLinkSameGroup: TAction;
    mniAddLinkSameGroup: TMenuItem;
    acAddRecSameGroup: TAction;
    mniAddRecSameGroup: TMenuItem;
    acAddCut: TAction;
    btnAddCut: TSpeedButton;
    procedure btnAGClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tvTreeChange(Sender: TObject; Node: TTreeNode);
    procedure btnDGClick(Sender: TObject);
    procedure btnALClick(Sender: TObject);
    procedure btnSelectHTMLClick(Sender: TObject);
    procedure DevToolsActivate(Sender: Tobject);
    procedure AfterEntityPanelChange(aControl: TControl);
    //procedure udContainerStepClick(Sender: TObject; Button: TUDBtnType);
    procedure btnAddLevelClick(Sender: TObject);
    procedure cbbLevelChange(Sender: TObject);
    procedure tvTreeDblClick(Sender: TObject);
    procedure mniAddCutClick(Sender: TObject);
    procedure btnDLvClick(Sender: TObject);
    procedure acAddLinkExecute(Sender: TObject);
    procedure acAddRecordExecute(Sender: TObject);
    procedure acRemoveExecute(Sender: TObject);
    procedure acAddLinkSameGroupExecute(Sender: TObject);
    procedure acAddRecSameGroupExecute(Sender: TObject);
    procedure acAddCutExecute(Sender: TObject);
  private
    { Private declarations }
    FDevToolsEnabled: Boolean;
    function GetUpperNode(aLevelBreak: Integer): TTreeNode;
  protected
    procedure InitView; override;
  public
    { Public declarations }
    pnlEntityFields: TEntityPanel;

    function GetGroupIndex: integer;
    function GetRuleIndex: Integer;
    function GetLevelIndex: integer;

    function GetSelectedLevel: TJobLevel;
    function GetSelectedGroup: TJobGroup;
    function GetSelectedRule: TJobRule;

    procedure SetLevels(aLevelList: TLevelList; aIndex: Integer = 0);
    procedure RenderLevelRulesTree(aJobGroupList: TGroupList);
    procedure AfterLevelSelected;

    procedure AddRuleToTree(aGroup: TJobGroup; aRule: TJobRule);
    procedure AddGroupToTree(aGroup: TJobGroup; aSibling: TTreeNode = nil);
    procedure RemoveTreeNode;
  end;

var
  ViewRules: TViewRules;

implementation

{$R *.dfm}

uses
  System.UITypes;

procedure TViewRules.RemoveTreeNode;
begin
  tvTree.Selected.Delete;
end;

procedure TViewRules.acAddLinkSameGroupExecute(Sender: TObject);
begin
  SendMessage('AddLinkSameGroup');
end;

procedure TViewRules.acAddRecordExecute(Sender: TObject);
begin
  SendMessage('AddRecord');
end;

procedure TViewRules.acAddRecSameGroupExecute(Sender: TObject);
begin
  SendMessage('AddRecSameGroup');
end;

procedure TViewRules.acRemoveExecute(Sender: TObject);
var
  Node: TObject;
  Entity: TEntityAbstract;
begin
  Node := tvTree.Selected;
  Entity := FBind.GetEntityByControl(Node);

  if Entity is TJobRule then
    SendMessage('RemoveRule');
end;

procedure TViewRules.AddGroupToTree(aGroup: TJobGroup; aSibling: TTreeNode = nil);
var
  GroupNode: TTreeNode;
  Rule: TJobRule;
begin
  if aSibling = nil then
    GroupNode := tvTree.Items.AddChild(nil, aGroup.Notes)
  else
    GroupNode := tvTree.Items.Insert(aSibling, aGroup.Notes);

  GroupNode.ImageIndex := 2;
  GroupNode.SelectedIndex := 2;

  FBind.AddBind(GroupNode, aGroup);

  for Rule in aGroup.Rules do
    AddRuleToTree(aGroup, Rule);
end;

procedure TViewRules.AddRuleToTree(aGroup: TJobGroup; aRule: TJobRule);
var
  RuleNode, ParentNode: TTreeNode;
begin
  if aGroup.RulesCount > 1 then
    begin
      ParentNode := TTreeNode(FBind.GetControlByEntity(aGroup));
      if ParentNode = nil then
        begin
          AddGroupToTree(aGroup, tvTree.Selected);
          tvTree.Selected.Delete;
          ParentNode := TTreeNode(FBind.GetControlByEntity(aGroup));
          ParentNode.Expand(False);
          Exit;
        end;
    end
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

  FBind.AddBind(RuleNode, aRule);
end;

procedure TViewRules.AfterLevelSelected;
begin
  pnlEntityFields.ClearControls;
  pnlXPath.Visible := False;

  if GetSelectedLevel <> nil then
    begin
      chrmBrowser.Load(GetSelectedLevel.BaseLink);
      RenderLevelRulesTree(GetSelectedLevel.Groups);
    end
  else
    tvTree.Items.Clear;
end;

function TViewRules.GetSelectedRule: TJobRule;
begin
  Result := GetSelectedGroup.Rules[GetRuleIndex];
end;

function TViewRules.GetSelectedGroup: TJobGroup;
begin
  Result := GetSelectedLevel.Groups.Items[GetGroupIndex];
end;

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

procedure TViewRules.acAddCutExecute(Sender: TObject);
begin
  SendMessage('AddCut');
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

function TViewRules.GetUpperNode(aLevelBreak: Integer): TTreeNode;
var
  i: Integer;
begin
  Result:= tvTree.Selected;
  for i := tvTree.Selected.Level downto aLevelBreak + 1 do
    begin
      Result := Result.Parent;
    end;
end;

function TViewRules.GetRuleIndex: Integer;
begin
  Result := GetUpperNode(1).Index;
end;

function TViewRules.GetGroupIndex: integer;
begin
  Result := GetUpperNode(0).Index;
end;

procedure TEntityPanel.InitPanel;
begin
  OnAfterEditChange := ViewRules.AfterEntityPanelChange;
end;

procedure TViewRules.RenderLevelRulesTree(aJobGroupList: TGroupList);
var
  Group: TJobGroup;
  JobRule: TJobRule;
  GroupNode, RuleNode: TTreeNode;
begin
  tvTree.Items.Clear;
  //tvTree.OnChange := nil;
  //tvTree.OnChange := tvTreeChange;

  for Group in aJobGroupList do
    begin
      if Group.RulesCount > 1 then
        AddGroupToTree(Group)
      else
        for JobRule in Group.Rules do
          AddRuleToTree(Group, JobRule);
    end;

  ViewRules.tvTree.FullExpand;
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

procedure TViewRules.btnAGClick(Sender: TObject);
begin
  SendMessage('CreateGroup');
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

procedure TViewRules.btnDGClick(Sender: TObject);
begin
  if MessageDlg('Are you sure?', mtConfirmation, [mbYes, mbCancel], 0) = mrYes then
    SendMessage('DeleteGroup');
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

procedure TViewRules.mniAddCutClick(Sender: TObject);
begin
  SendMessage('CreateCut');
end;

end.
