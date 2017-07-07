unit vMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.StdCtrls,
  Vcl.Buttons,
  API_MVC,
  eEntities, cefvcl, Vcl.Menus, System.ImageList, Vcl.ImgList, Vcl.XPMan;

type
  TViewMain = class(TViewAbstract)
    pnlJobs: TPanel;
    stgdJobs: TStringGrid;
    pnlButtons: TPanel;
    btnNewJob: TBitBtn;
    btnEditJob: TBitBtn;
    btnEditRules: TBitBtn;
    btnGo: TBitBtn;
    mmMenu: TMainMenu;
    mniProject: TMenuItem;
    mniNewProject: TMenuItem;
    xpmnfstXP: TXPManifest;
    splJobBrowser: TSplitter;
    chrmBrowser: TChromium;
    btnCreateJob: TSpeedButton;
    Image1: TImage;
    ilIcons: TImageList;
    procedure btnNewJobClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnEditJobClick(Sender: TObject);
    procedure btnEditRulesClick(Sender: TObject);
    procedure btnGoClick(Sender: TObject);
    procedure stgdJobsDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
    function GetSelectedJobID: integer;
  protected
    procedure InitMVC; override;
    procedure InitView; override;
  public
    { Public declarations }
    procedure SetJobsGrid(aJobs: TJobList);
    property SelectedJobID: Integer read GetSelectedJobID;
  end;

var
  ViewMain: TViewMain;

implementation

{$R *.dfm}

uses
  WinProcs,
  cController;

procedure TViewMain.SetJobsGrid(aJobs: TJobList);
var
  i: Integer;
  Job: TJob;
begin
  i := 0;
  stgdJobs.RowCount := 2;
  for Job in aJobs do
    begin
      if i > 0 then stgdJobs.RowCount := stgdJobs.RowCount + 1;
      stgdJobs.Cells[0, stgdJobs.RowCount - 1] := Job.Caption;
      Inc(i);
    end;
end;

procedure TViewMain.stgdJobsDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  F: Word;
  C: array[0..255] of Char;
begin
  if ARow = 0 then
    F := DT_CENTER;

  stgdJobs.Canvas.FillRect(Rect);
  StrPCopy(C, stgdJobs.Cells[ACol, 0]);
  WinProcs.DrawText(stgdJobs.Canvas.Handle, C, StrLen(C), Rect, F);
end;

function TViewMain.GetSelectedJobID: Integer;
begin
  Result := StrToInt(stgdJobs.Cells[0, stgdJobs.Row]);
end;

procedure TViewMain.InitView;
begin
  ViewMain := Self;
  stgdJobs.Cells[0,0] := 'Title';
end;

procedure TViewMain.btnEditJobClick(Sender: TObject);
begin
  SendMessage('EditJob');
end;

procedure TViewMain.btnEditRulesClick(Sender: TObject);
begin
  SendMessage('EditJobRules');
end;

procedure TViewMain.btnGoClick(Sender: TObject);
begin
  SendMessage('StartJob');
end;

procedure TViewMain.btnNewJobClick(Sender: TObject);
begin
  SendMessage('CreateJob');
end;

procedure TViewMain.FormShow(Sender: TObject);
begin
  Self.SendMessage('GetJobList');
end;

procedure TViewMain.InitMVC;
begin
  FControllerClass := TController;
end;

end.
