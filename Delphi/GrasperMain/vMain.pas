unit vMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, API_MVC_VCL, Vcl.Menus, VirtualTrees,
  eJob, Vcl.ToolWin, Vcl.ComCtrls, Vcl.ActnMan, Vcl.ActnCtrls,
  Vcl.PlatformDefaultStyleActnCtrls, System.Actions, Vcl.ActnList,
  System.ImageList, Vcl.ImgList, Vcl.ActnColorMaps, Vcl.StdCtrls;

type
  TViewMain = class(TViewVCLBase)
    vstJobs: TVirtualStringTree;
    ActionManager: TActionManager;
    ActionToolBar: TActionToolBar;
    acAddJob: TAction;
    ilActionIcons: TImageList;
    acEditJob: TAction;
    acRemoveJob: TAction;
    scmColorMap: TStandardColorMap;
    acStartJob: TAction;
    acStopJob: TAction;
    acEditJobRules: TAction;
    procedure FormCreate(Sender: TObject);
    procedure vstJobsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure acAddJobExecute(Sender: TObject);
    procedure acEditJobExecute(Sender: TObject);
    procedure acRemoveJobExecute(Sender: TObject);
    procedure vstJobsFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure acStartJobExecute(Sender: TObject);
    procedure acStopJobExecute(Sender: TObject);
    procedure acEditJobRulesExecute(Sender: TObject);
  private
    { Private declarations }
    function GetJob: TJob;
    procedure DisableEditActions;
    procedure EnableEditActions;
    procedure InitView; override;
  public
    { Public declarations }
    function RemoveSelectedJob: Boolean;
    procedure RenderJob(aJob: TJob);
    procedure RenderJobList(aJobList: TJobList);
    property SelectedJob: TJob read GetJob;
  end;

var
  ViewMain: TViewMain;

implementation

{$R *.dfm}

uses
  cController;

function TViewMain.RemoveSelectedJob: Boolean;
var
  VirtualNode: PVirtualNode;
begin
  if Application.MessageBox('Are You Sure?', 'Delete Job', MB_OKCANCEL) = 1 then
    begin
      VirtualNode := vstJobs.FocusedNode;
      vstJobs.DeleteNode(VirtualNode);

      Result := True;
    end
  else
    Result := False;
end;

procedure TViewMain.DisableEditActions;
begin
  acEditJob.Enabled := False;
  acRemoveJob.Enabled := False;

  acStartJob.Enabled := False;
  acStopJob.Enabled := False;

  acEditJobRules.Enabled := False;
end;

procedure TViewMain.EnableEditActions;
begin
  acEditJob.Enabled := True;
  acRemoveJob.Enabled := True;

  acStartJob.Enabled := True;
  acStopJob.Enabled := True;

  acEditJobRules.Enabled := True;
end;

function TViewMain.GetJob: TJob;
var
  Job: PJob;
  VirtualNode: PVirtualNode;
begin
  VirtualNode := vstJobs.FocusedNode;

  if VirtualNode <> nil then
    begin
      Job := vstJobs.GetNodeData(VirtualNode);
      Result := Job^;
    end;
end;

procedure TViewMain.RenderJob(aJob: TJob);
var
  VirtualNode: PVirtualNode;
begin
  VirtualNode := vstJobs.AddChild(nil, aJob);
end;

procedure TViewMain.RenderJobList(aJobList: TJobList);
var
  Job: TJob;
begin
  for Job in aJobList do
    RenderJob(Job);
end;

procedure TViewMain.vstJobsFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  inherited;

  if Sender.FocusedNode <> nil then
    EnableEditActions
  else
    DisableEditActions;
end;

procedure TViewMain.vstJobsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  Job: PJob;
begin
  inherited;

  Job := Sender.GetNodeData(Node);

  case Column of
    0: CellText := Job^.Caption;
    1: CellText := Job^.ZeroLink;
  end;
end;

procedure TViewMain.acAddJobExecute(Sender: TObject);
begin
  inherited;
  SendMessage('AddJob');
end;

procedure TViewMain.acEditJobExecute(Sender: TObject);
begin
  inherited;
  SendMessage('EditJob');
end;

procedure TViewMain.acEditJobRulesExecute(Sender: TObject);
begin
  inherited;

  SendMessage('EditJobRules');
end;

procedure TViewMain.acRemoveJobExecute(Sender: TObject);
begin
  inherited;
  SendMessage('RemoveJob');
end;

procedure TViewMain.acStartJobExecute(Sender: TObject);
begin
  inherited;

  SendMessage('StartJob');
end;

procedure TViewMain.acStopJobExecute(Sender: TObject);
begin
  inherited;
  //
end;

procedure TViewMain.FormCreate(Sender: TObject);
begin
  inherited;

  DisableEditActions;
  vstJobs.NodeDataSize := SizeOf(TJob);
  SendMessage('PullJobList');
end;

procedure TViewMain.InitView;
begin
  FControllerClass := TController;
  ViewMain := Self;
end;

end.
