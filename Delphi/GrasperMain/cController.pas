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
    procedure ViewMainClosed;
  end;

var
  DBEngine: TDBEngine;

implementation

uses
  API_DB_SQLite,
  eJob,
  System.SysUtils,
  vMain;

procedure TController.ViewMainClosed;
var
  JobList: TJobList;
begin
  JobList := FDataObj.Items['JobList'] as TJobList;
  JobList.Free;
end;

constructor TController.Create;
begin
  inherited;

  // for use in global project context
  DBEngine := FDBEngine;
end;

procedure TController.PullJobList;
var
  JobList: TJobList;
begin
  JobList := TJobList.Create([], ['ID']);
  FDataObj.AddOrSetValue('JobList', JobList);

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
