unit cController;

interface

uses
  API_DB,
  API_MVC_DB;

type
  TController = class(TControllerDB)
  protected
    procedure InitDB; override;
  public
    constructor Create; override;
  published
    procedure PullJobList;
    procedure Test;
  end;

var
  DBEngine: TDBEngine;

implementation

uses
  API_DB_SQLite,
  eJob,
  System.SysUtils;

constructor TController.Create;
begin
  inherited;

  // for use in global project context
  DBEngine := FDBEngine;
end;

procedure TController.PullJobList;
var
  Job: TJob;
  JobList: TJobList;
begin
  JobList := TJobList.Create([], ['ID']);

  Job := JobList[0];
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
