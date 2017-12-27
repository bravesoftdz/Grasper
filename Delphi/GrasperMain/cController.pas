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
    procedure EditJob;
    procedure PullJobList;
    procedure RemoveJob;
    procedure Test;
    procedure ViewMainClosed;
  end;

implementation

uses
  API_DB_SQLite,
  eCommon,
  System.SysUtils,
  vJob,
  vMain,

  LbAsym;

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
  temp: string;
begin
  Job := ViewMain.SelectedJob;

  ViewMain.lbrs1.KeySize := aks128;

  ViewMain.lbrs1.GenerateKeyPair;

  temp := ViewMain.lbrs1.PrivateKey.Passphrase;

  temp := 'We have modifited this title';
  temp := ViewMain.lbrs1.EncryptString(temp);

  temp := ViewMain.lbrs1.DecryptString(temp);

  Job.Caption := 'We have modifited this title';
  Job.ZeroLink := 'https://support.softclub.by/secure/Dashboard.jspa';

  //Job.Store;
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

  CallView(TViewJob, True);

  Job.Free;

  //Job.Caption := 'New Job';
  //Job.ZeroLink := 'https://support.softclub.by/browse/NTDEV-6660';

  //Job.Store;
  //JobList.Add(Job);
  //ViewMain.RenderJob(Job);
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
