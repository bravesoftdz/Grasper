unit vMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, API_MVC_VCL, Vcl.Menus, VirtualTrees,
  eJob;

type
  TViewMain = class(TViewVCLBase)
    mmMenu: TMainMenu;
    vstJobs: TVirtualStringTree;
    procedure FormCreate(Sender: TObject);
    procedure vstJobsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
  private
    { Private declarations }
    procedure InitView; override;
  public
    { Public declarations }
    procedure RenderJobList(aJobList: TJobList);
  end;

var
  ViewMain: TViewMain;

implementation

{$R *.dfm}

uses
  cController;

procedure TViewMain.RenderJobList(aJobList: TJobList);
var
  Job: TJob;
  VirtualNode: PVirtualNode;
begin
  for Job in aJobList do
    VirtualNode := vstJobs.AddChild(nil, Job);
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
