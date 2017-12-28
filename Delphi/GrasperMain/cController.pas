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

implementation

uses
  API_Crypt,
  API_DB_SQLite,
  eCommon,
  System.SysUtils,
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

  Job.Caption := 'We have modifited this title';
  Job.ZeroLink := 'https://support.softclub.by/secure/Dashboard.jspa';

  Job.Store;
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

  //Job.Free;

  Job.Caption := 'New Job';
  Job.ZeroLink := 'https://www.google.by/search?q=array+%5B0..15%5D+of+Byte&ei=rthEWp70JeXJ6ASFzquwAw&start=10&sa=N&biw=1345&bih=647';

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

  FCryptParams.PublicModulus := 'DD655AF932CECA8D9B72213DD99FE571';
  FCryptParams.PublicExponent := 'A930';
  FCryptParams.PrivateModulus := 'DD655AF932CECA8D9B72213DD99FE571';
  FCryptParams.PrivateExponent := '116D6F4E7095CA3D4FDC205CAF498658';
  FCryptEngineClass := TCryptRSA;
end;

end.
