unit cController;

interface

uses
  API_MVC_VCL,
  eJob;

type
  TController = class(TControllerVCLBase)
  private
    function GetJobList: TJobList;
    procedure SetJobList(aValue: TJobList);
  protected
    procedure InitDB; override;
  public
    constructor Create; override;
    property JobList: TJobList read GetJobList write SetJobList;
  published
    procedure AddJob;
    procedure PullJobList;
    procedure Test;
    procedure ViewMainClosed;
  end;

implementation

uses
  API_DB_SQLite,
  eCommon,
  System.SysUtils,
  vJob,
  vMain;

function TController.GetJobList: TJobList;
begin
  Result := FDataObj.Items['JobList'] as TJobList;
end;

procedure TController.SetJobList(aValue: TJobList);
begin
  FDataObj.AddOrSetValue('JobList', aValue);
end;

procedure TController.AddJob;
var
  Job: TJob;
begin
  Job := TJob.Create;

  CallView(TViewJob, True);

  Job.Caption := 'New Job';
  Job.ZeroLink := 'dfdsssssssss33333333';

  Job.Store;
  JobList.Add(Job);
  ViewMain.RenderJob(Job);
end;

procedure TController.ViewMainClosed;
begin
  JobList.Free;
end;

constructor TController.Create;
begin
  inherited;

  // for use in global project context
  DBEngine := FDBEngine;
end;

procedure TController.PullJobList;
begin
  JobList := TJobList.Create([], ['ID']);

  ViewMain.RenderJobList(JobList);
end;

procedure TController.Test;
begin
end;

procedure TController.InitDB;
begin
  FConnectOnCreate := True;
  FConnectParams.DataBase := GetCurrentDir + '\DB\local.db';
  FDBEngineClass := TSQLiteEngine;
end;

end.
