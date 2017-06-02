unit vRules;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, cefvcl, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.ImgList,
  API_MVC,
  API_ORM_Cntrls,
  eEntities;

type
  TEntityPanel = class(TEntityPanelAbstract)
  protected
    procedure InitPanel; override;
    procedure AfterEditChange(aEdit: TEdit);
  end;

  TViewRules = class(TViewAbstract)
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
    ilIcons: TImageList;
    btnAL: TBitBtn;
    btnApply: TButton;
    btnCancel: TButton;
    btnDG: TBitBtn;
    btnDL: TBitBtn;
    btnAR: TBitBtn;
    btnDR: TBitBtn;
    pnlXPath: TPanel;
    btnSelectHTML: TBitBtn;
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
  private
    { Private declarations }
    function GetUpperNode(aLevelBreak: Integer): TTreeNode;
    function GetGroupIndex: integer;
    function GetRuleIndex: Integer;
  protected
    procedure InitView; override;
  public
    { Public declarations }
    pnlEntityFields: TEntityPanel;
    procedure SetLevels(aLevelList: TLevelList);
    procedure SetControlTree(aJobGroupList: TGroupList);
    property GroupIndex: Integer read GetGroupIndex;
    property RuleIndex: Integer read GetRuleIndex;
  end;

  // FBindData Item Keys
  // GroupNodes

var
  ViewRules: TViewRules;

implementation

{$R *.dfm}

uses
  System.UITypes,
  API_MVC_Bind;

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

procedure TEntityPanel.AfterEditChange(aEdit: TEdit);
begin
  ViewRules.tvTree.Selected.Text := aEdit.Text;
end;

procedure TEntityPanel.InitPanel;
begin
  OnAfterEditChange := AfterEditChange;
end;

procedure TViewRules.SetControlTree(aJobGroupList: TGroupList);
var
  Group: TJobGroup;
  Link: TJobLink;
  JobRecord: TJobRecord;
  GroupNode, LinkNode, RecordNode: TTreeNode;
begin
  ViewRules.tvTree.Items.Clear;

  for Group in aJobGroupList do
    begin
      GroupNode := tvTree.Items.Add(nil, Group.Notes);
      GroupNode.ImageIndex := 0;
      GroupNode.SelectedIndex := 0;

      for Link in Group.Links do
        begin
          LinkNode := tvTree.Items.AddChild(GroupNode, Link.Level.ToString);
          LinkNode.ImageIndex := 1;
          LinkNode.SelectedIndex := 1;
        end;

      for JobRecord in Group.Records do
        begin
          RecordNode := tvTree.Items.AddChild(GroupNode, JobRecord.Key);
          RecordNode.ImageIndex := 2;
          RecordNode.SelectedIndex := 2;
        end;

      //FBindData.AddBind('GroupNodes', TreeNodes.Count - 1, Group.ID);
    end;

  ViewRules.tvTree.FullExpand;
end;

procedure TViewRules.SetLevels(aLevelList: TLevelList);
var
  Level: TJobLevel;
begin
  for Level in aLevelList  do
    begin
      cbbLevel.Items.Add(Level.Level.ToString);
    end;

  cbbLevel.ItemIndex := 0;
  chrmBrowser.Load(Level.BaseLink);
end;

procedure TViewRules.tvTreeChange(Sender: TObject; Node: TTreeNode);
begin
  SendMessage('TreeNodeSelected');
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

procedure TViewRules.btnDRClick(Sender: TObject);
begin
  SendMessage('DeleteRecord');
end;

procedure TViewRules.btnSelectHTMLClick(Sender: TObject);
begin
  SendMessage('SelectHTMLNode');
end;

procedure TViewRules.FormCreate(Sender: TObject);
begin
  pnlEntityFields := TEntityPanel.Create(pnlFields);
end;

procedure TViewRules.InitView;
begin
  ViewRules := Self;
end;

end.
