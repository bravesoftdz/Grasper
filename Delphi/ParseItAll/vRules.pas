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
    btnDL: TBitBtn;
    btnAR: TBitBtn;
    btnDR: TBitBtn;
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
    procedure btnAGClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tvTreeChange(Sender: TObject; Node: TTreeNode);
    procedure btnDGClick(Sender: TObject);
    procedure btnALClick(Sender: TObject);
    procedure btnDLClick(Sender: TObject);
    procedure btnARClick(Sender: TObject);
    procedure btnDRClick(Sender: TObject);
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
  private
    { Private declarations }
    FDevToolsEnabled: Boolean;
    //function GetUpperNode(aLevelBreak: Integer): TTreeNode;
  protected
    procedure InitView; override;
  public
    { Public declarations }
    pnlEntityFields: TEntityPanel;

    function GetGroupIndex: integer;
    //function GetRuleIndex: Integer;
    function GetLevelIndex: integer;

    function GetSelectedLevel: TJobLevel;
    function GetSelectedGroup: TJobGroup;
    //function GetSelectedRule: TJobRule;

    procedure SetLevels(aLevelList: TLevelList; aIndex: Integer = 0);
    procedure RenderLevelRulesTree(aJobGroupList: TGroupList);
    procedure AfterLevelSelected;

    procedure AddLinkToTree(aLink: TJobLink);
  end;

var
  ViewRules: TViewRules;

implementation

{$R *.dfm}

uses
  System.UITypes;

procedure TViewRules.acAddRecordExecute(Sender: TObject);
begin
  SendMessage('AddRecord');
end;

procedure TViewRules.AddlinkToTree(aLink: TJobLink);
var
  LinkNode: TTreeNode;
begin
  LinkNode := tvTree.Items.AddChild(nil, aLink.Level.ToString);
  FBind.AddBind(LinkNode, aLink);
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

{function TViewRules.GetSelectedRule: TJobRule;
begin
  Result := GetSelectedGroup.Rules[GetRuleIndex];
end;  }

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

{function TViewRules.GetUpperNode(aLevelBreak: Integer): TTreeNode;
var
  i: Integer;
begin
  Result:= tvTree.Selected;
  for i := tvTree.Selected.Level downto aLevelBreak + 1 do
    begin
      Result := Result.Parent;
    end;
end;}

{function TViewRules.GetRuleIndex: Integer;
begin
  Result := GetUpperNode(1).Index;
end;}

function TViewRules.GetGroupIndex: integer;
begin
  Result := -1;
  //Result := GetUpperNode(0).Index;
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
      for JobRule in Group.Rules do
        begin
          if JobRule.Link <> nil then
            begin
              AddlinkToTree(JobRule.Link);
            end;
        end;
    end;

  {for Group in aJobGroupList do
    begin
      GroupNode := tvTree.Items.Add(nil, Group.Notes);
      GroupNode.ImageIndex := 0;
      GroupNode.SelectedIndex := 0;

      for JobRule in Group.Rules do
        begin
          if JobRule.Link <> nil then
            begin
              RuleNode := tvTree.Items.AddChild(GroupNode, JobRule.Link.Level.ToString);
              RuleNode.ImageIndex := 1;
              RuleNode.SelectedIndex := 1;
            end;

          if JobRule.Rec <> nil then
            begin
              RuleNode := tvTree.Items.AddChild(GroupNode, JobRule.Notes);
              RuleNode.ImageIndex := 2;
              RuleNode.SelectedIndex := 2;
            end;

          if JobRule.Cut <> nil then
            begin
              RuleNode := tvTree.Items.AddChild(GroupNode, JobRule.Notes);
              RuleNode.ImageIndex := 3;
              RuleNode.SelectedIndex := 3;
            end;
        end;
    end;

  ViewRules.tvTree.FullExpand; }
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

procedure TViewRules.btnARClick(Sender: TObject);
begin
  SendMessage('CreateRecord');
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

procedure TViewRules.btnDLClick(Sender: TObject);
begin
  SendMessage('DeleteLink');
end;

procedure TViewRules.btnDLvClick(Sender: TObject);
begin
  SendMessage('DeleteLevel');
end;

procedure TViewRules.btnDRClick(Sender: TObject);
begin
  SendMessage('DeleteRecord');
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
