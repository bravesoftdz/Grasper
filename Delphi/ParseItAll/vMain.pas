unit vMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.StdCtrls,
  Vcl.Buttons,
  API_MVC,
  eJob,
  cefvcl, Vcl.Menus, System.ImageList, Vcl.ImgList, Vcl.XPMan,
  ZColorStringGrid, System.Actions, Vcl.ActnList;

type
  TViewMain = class(TViewAbstract)
    pnlJobs: TPanel;
    pnlButtons: TPanel;
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
    ilIcons: TImageList;
    strgrdJobs: TZColorStringGrid;
    actlstMain: TActionList;
    acCreateJob: TAction;
    btnClear: TButton;
    btnSaveToCSV: TBitBtn;
    btnCopy: TBitBtn;
    btnTest: TButton;
    btnStop: TBitBtn;
    tmrJobsGridUpdate: TTimer;
    mniService: TMenuItem;
    mniVacuumCommand: TMenuItem;
    mniClearSequences: TMenuItem;
    tmr1: TTimer;
    Edit1: TEdit;
    btnEditExportFields: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure btnEditJobClick(Sender: TObject);
    procedure btnEditRulesClick(Sender: TObject);
    procedure btnGoClick(Sender: TObject);
    procedure acCreateJobExecute(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnSaveToCSVClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure tmrJobsGridUpdateTimer(Sender: TObject);
    procedure mniVacuumCommandClick(Sender: TObject);
    procedure mniClearSequencesClick(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure btnEditExportFieldsClick(Sender: TObject);
  private
    { Private declarations }
    function GetSelectedJobID: integer;
  protected
    procedure InitMVC; override;
    procedure InitView; override;
  public
    { Public declarations }
    procedure SetJobsGrid(aJobs: TJobList);
    procedure SetJobProgressInfo(aJobID, aHandledCount, aTotalCount: Integer);
    property SelectedJobID: Integer read GetSelectedJobID;
  end;

var
  ViewMain: TViewMain;

implementation

{$R *.dfm}

uses
  WinProcs,
  cController;

procedure TViewMain.SetJobProgressInfo(aJobID, aHandledCount, aTotalCount: Integer);
var
  i: Integer;
begin
  for i := 0 to strgrdJobs.RowCount - 1 do
    if strgrdJobs.Cells[0, i] = aJobID.ToString then
      begin
        strgrdJobs.CellStyle[2, i].HorizontalAlignment := taRightJustify;
        strgrdJobs.Cells[2, i] := aHandledCount.ToString;
        strgrdJobs.CellStyle[3, i].HorizontalAlignment := taRightJustify;
        strgrdJobs.Cells[3, i] := aTotalCount.ToString;
      end;
end;

procedure TViewMain.btnCopyClick(Sender: TObject);
begin
 SendMessage('TempCopy');
end;

procedure TViewMain.SetJobsGrid(aJobs: TJobList);
var
  i: Integer;
  Job: TJob;
begin
  i := 0;
  strgrdJobs.RowCount := 2;
  for Job in aJobs do
    begin
      if i > 0 then strgrdJobs.RowCount := strgrdJobs.RowCount + 1;
      strgrdJobs.Cells[0, strgrdJobs.RowCount - 1] := IntToStr(Job.ID);
      strgrdJobs.Cells[1, strgrdJobs.RowCount - 1] := Job.Caption;
      Inc(i);
    end;
end;

procedure TViewMain.tmr1Timer(Sender: TObject);
begin
 Edit1.Text := TimeToStr(Time);
end;

procedure TViewMain.tmrJobsGridUpdateTimer(Sender: TObject);
begin
  SendMessage('UpdateProcessInfo');
end;

function TViewMain.GetSelectedJobID: Integer;
begin
  Result := StrToInt(strgrdJobs.Cells[0, strgrdJobs.Row]);
end;

procedure TViewMain.InitView;
begin
  ViewMain := Self;
  strgrdJobs.Cells[0,0] := 'ID';
  strgrdJobs.CellStyle[0,0].HorizontalAlignment := taCenter;

  strgrdJobs.Cells[1,0] := 'Title';
  strgrdJobs.CellStyle[1,0].HorizontalAlignment := taCenter;

  strgrdJobs.ColWidths[2] := 70;
  strgrdJobs.Cells[2,0] := 'Handled Links';
  strgrdJobs.CellStyle[2,0].HorizontalAlignment := taCenter;

  strgrdJobs.ColWidths[3] := 70;
  strgrdJobs.Cells[3,0] := 'Total Links';
  strgrdJobs.CellStyle[3,0].HorizontalAlignment := taCenter;
end;

procedure TViewMain.mniClearSequencesClick(Sender: TObject);
begin
  SendMessage('DBClearSeq');
end;

procedure TViewMain.mniVacuumCommandClick(Sender: TObject);
begin
  SendMessage('DBVacuum');
end;

procedure TViewMain.acCreateJobExecute(Sender: TObject);
begin
  SendMessage('CreateJob');
end;

procedure TViewMain.btnTestClick(Sender: TObject);
begin
  //SendMessage('Test');
  if tmr1.Enabled then tmr1.Enabled := False;
  if not tmr1.Enabled then tmr1.Enabled := True;
end;

procedure TViewMain.btnClearClick(Sender: TObject);
begin
  SendMessage('ClearJobLinks');
end;

procedure TViewMain.btnEditExportFieldsClick(Sender: TObject);
begin
  SendMessage('EditExportFields');
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

procedure TViewMain.btnSaveToCSVClick(Sender: TObject);
begin
  SendMessage('ExportJobResultsToCSV');
end;

procedure TViewMain.btnStopClick(Sender: TObject);
begin
  SendMessage('StopJob');
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
