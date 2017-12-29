unit cController;

interface

uses
  API_MVC_VCL,
  eJob,
  LbCipher;

type
  TController = class(TControllerVCLBase)
  private
    function GetJobList: TJobList;
    procedure SetJobList(aValue: TJobList);
  protected
    procedure Init; override;
  public
    constructor Create; override;
    property JobList: TJobList read GetJobList write SetJobList;
  published
    procedure AddJob;
    procedure EditJob;
    procedure PullJobList;
    procedure RemoveJob;
    procedure Test;
    procedure ViewMainClosed;
  end;

const
  CryptKey: TKey128 = (168, 195, 109, 253, 15, 207, 211, 55, 254, 74, 229, 230, 16, 174, 49, 201);

implementation

uses
  API_Crypt,
  API_DB_SQLite,
  eCommon,
  System.SysUtils,
  Vcl.Controls,
  vJob,
  vMain;

procedure TController.RemoveJob;
var
  Job: TJob;
begin
  Job := ViewMain.SelectedJob;

  Job.Delete;
end;

procedure TController.EditJob;
var
  Job: TJob;
begin
  Job := ViewMain.SelectedJob;

  CreateView(TViewJob);
  ViewJob.BindEntity(Job);

  if ViewJob.ShowModal = mrOk then
    Job.Store
  else
    Job.Revert;
end;

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

  CreateView(TViewJob);
  ViewJob.BindEntity(Job);

  if ViewJob.ShowModal = mrOk then
    begin
      Job.Store;
      JobList.Add(Job);
      ViewMain.RenderJob(Job);
    end
  else
    Job.Free;
end;

procedure TController.ViewMainClosed;
begin
  JobList.Free;
end;

constructor TController.Create;
begin
  inherited;

  // for use in global project context
  eCommon.DBEngine := Self.DBEngine;
  eCommon.CryptEngine := Self.CryptEngine;
end;

procedure TController.PullJobList;
begin
  JobList := TJobList.Create([], ['ID']);

  ViewMain.RenderJobList(JobList);
end;

procedure TController.Test;
begin
end;

procedure TController.Init;
begin
  FConnectOnCreate := True;
  FConnectParams.DataBase := GetCurrentDir + '\DB\local.db';
  FDBEngineClass := TSQLiteEngine;

  FCryptParams.SynchKey := CryptKey;
  FCryptEngineClass := TCryptBlowfish;
end;

end.
