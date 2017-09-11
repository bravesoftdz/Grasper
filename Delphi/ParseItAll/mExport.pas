unit mExport;

interface

uses
  API_MVC_DB,
  eLevel,
  eRule;

type
  TModelExport = class(TModelDB)
  private
    function GetRuleKeysFromLevel(aLevel: TJobLevel): TArray<string>;
    function GetKeysFromRule(aRule: TJobRule): TArray<string>;
    procedure GetLinkslist(aJobID: Integer; aKeys: TArray<string>);
    procedure ProcessLinkResults(aLinkID: Integer; aKeys:TArray<string>);
  published
    procedure ExportToCSV;
  end;

implementation

uses
  System.SysUtils,
  FireDAC.Comp.Client,
  eJob,
  eLink;

procedure TModelExport.ProcessLinkResults(aLinkID: Integer; aKeys:TArray<string>);
var
  Link: TLink;
begin
  Link := TLink.Create(FDBEngine, aLinkID);
  try

  finally
    FreeAndNil(Link);
  end;
end;

procedure TModelExport.GetLinkslist(aJobID: Integer; aKeys: TArray<string>);
var
  dsQuery: TFDQuery;
begin
  dsQuery := TFDQuery.Create(nil);
  try
    dsQuery.SQL.Text :=
      'select l.Id ' +
      'from links l ' +
      'where not exists (select Id from link2link l2l where l2l.parent_link_id = l.Id) ' +
      'and exists (select Id from records r where r.link_id = l.Id) ' +
      'and l.job_id = :JobID ' +
      'order by l.id';
    dsQuery.ParamByName('JobID').AsInteger := aJobID;
    FDBEngine.OpenQuery(dsQuery, False);

    while not dsQuery.EOF do
      begin
        ProcessLinkResults(dsQuery.FieldByName('Id').AsInteger, aKeys);
        dsQuery.Next;
      end;
  finally
    dsQuery.Free;
  end;
end;

function TModelExport.GetKeysFromRule(aRule: TJobRule): TArray<string>;
var
  RuleRuleRel: TRuleRuleRel;
begin
  Result := [];

  if aRule.Rec <> nil then
    Result := Result + [aRule.Rec.Key];

  for RuleRuleRel in aRule.ChildRuleRels do
    Result := Result + GetKeysFromRule(RuleRuleRel.ChildRule);
end;

function TModelExport.GetRuleKeysFromLevel(aLevel: TJobLevel): TArray<string>;
var
  LevelRuleRel: TLevelRuleRel;
begin
  Result := [];

  for LevelRuleRel in aLevel.RuleRels do
    Result := Result + GetKeysFromRule(LevelRuleRel.Rule);
end;

procedure TModelExport.ExportToCSV;
var
  i: Integer;
  Job: TJob;
  Level: TJobLevel;
  Keys: TArray<string>;
begin
  Job := (FObjData.Items['Job'] as TJob);

  Keys := [];
  for i := 0 to Job.Levels.Count - 1 do
    begin
      Level := Job.Levels[i];
      Keys := Keys + GetRuleKeysFromLevel(Level);
    end;

  GetLinkslist(Job.ID, Keys);
end;

end.
