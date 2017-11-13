unit eRuleCut;

interface

uses
  API_ORM;

type
  TJobCut = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  end;

  TCutList = TEntityList<TJobCut>;

implementation

uses
  Data.DB;

class function TJobCut.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'JOB_RULE_CUTS';

  AddField(Result.FieldList, 'JOB_RULE_ID', ftInteger);
end;

end.
