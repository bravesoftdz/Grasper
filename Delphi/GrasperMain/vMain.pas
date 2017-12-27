unit vMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, API_MVC_VCL, Vcl.Menus, VirtualTrees,
  eJob, Vcl.ToolWin, Vcl.ComCtrls, Vcl.ActnMan, Vcl.ActnCtrls,
  Vcl.PlatformDefaultStyleActnCtrls, System.Actions, Vcl.ActnList,
  System.ImageList, Vcl.ImgList, Vcl.ActnColorMaps, LbCipher, LbClass, LbAsym,
  LbRSA;

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
    lbrs1: TLbRSA;
    procedure FormCreate(Sender: TObject);
    procedure vstJobsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure acAddJobExecute(Sender: TObject);
    procedure acEditJobExecute(Sender: TObject);
    procedure acRemoveJobExecute(Sender: TObject);
  private
    { Private declarations }
    function GetJob: TJob;
    procedure InitView; override;
  public
    { Public declarations }
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

procedure TViewMain.acRemoveJobExecute(Sender: TObject);
begin
  inherited;
  SendMessage('RemoveJob');
end;

procedure TViewMain.FormCreate(Sender: TObject);
begin
  inherited;

  vstJobs.NodeDataSize := SizeOf(TJob);
  SendMessage('PullJobList');
end;

procedure TViewMain.InitView;
begin
  FControllerClass := TController;
  ViewMain := Self;
end;

end.
