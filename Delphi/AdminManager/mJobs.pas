unit mJobs;

interface

uses
  API_MVC_DB;

type
  {$M+}

  TModelJobs = class(TModelDB)
  published
    procedure GetJob;
  end;

implementation

uses
  System.SysUtils,
  FireDAC.Comp.Client,
  eEntities;

procedure TModelJobs.GetJob;
var
  Job: TJob;
begin
  Job := TJob.Create(FDBEngine, FData.Items['JobID']);

  FObjData.AddOrSetValue('Job', Job);
  CreateEvent('GetJobDone');
end;

end.
