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
    procedure EditJobRules;
    procedure PullJobList;
    procedure RemoveJob;
    procedure StartJob;
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
  eLevel,
  eRule,
  mParser,
  System.SysUtils,
  Vcl.Controls,
  vJob,
  vMain,
  vRules;

procedure TController.EditJobRules;
begin
  CreateView<TViewRules>;

  ViewRules.Show;
end;

procedure TController.StartJob;
begin
  CallModel<TModel>;
end;

procedure TController.RemoveJob;
var
  Job: TJob;
begin
  Job := ViewMain.SelectedJob;

  if ViewMain.RemoveSelectedJob then
    begin
      Job.Delete;
      JobList.Remove(Job);
    end;
end;

procedure TController.EditJob;
var
  Job: TJob;
begin
  Job := ViewMain.SelectedJob;

  CreateView<TViewJob>;
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
  Job.ZeroLink := 'https://www.google.com/';

  CreateView<TViewJob>;
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
var
  Level: TJobLevel;
begin
  Level := TJobLevel.Create(6);

  Level.BodyRule := TJobRule.Create;

  Level.BodyRule.Notes := 'gfhgf654654';

  Level.StoreAll;

  Level.Free;
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
