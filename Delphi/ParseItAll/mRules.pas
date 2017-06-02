unit mRules;

interface

uses
  API_MVC_DB;

type
  TModelRules = class(TModelDB)
  published
    procedure GetLevels;
  end;

implementation

uses
  System.SysUtils,
  API_ORM,
  eEntities;

procedure TModelRules.GetLevels;
var
  LevelList: TEntityList<TJobLevel>;
  JobID: integer;
  ListFilter: TArray<string>;
  ListOrder: TArray<string>;
begin
  JobID := FData.Items['JobID'];

  ListFilter := ListFilter + [Format('JOB_ID = "%d"', [JobID])];
  ListOrder := ListOrder + ['LEVEL'];
  //LevelList := TEntityList<TJobLevel>.Create(FDBEngine, ListFilter, ListOrder);

  FObjData.AddOrSetValue('LevelList', LevelList);
  CreateEvent('GetLevelsDone');
end;

end.
