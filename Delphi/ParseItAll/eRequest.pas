unit eRequest;

interface

uses
  API_ORM;

type
  TJobRequest = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
  // Getters Setters
    function GetJobRuleID: Integer;
    procedure SetJobRuleID(aValue: Integer);
  ////////////////////
  public
    property JobRuleID: Integer read GetJobRuleID write SetJobRuleID;
  end;

implementation

uses
  Data.DB;

function TJobRequest.GetJobRuleID: Integer;
begin
  Result := FData.Items['JOB_RULE_ID'];
end;

procedure TJobRequest.SetJobRuleID(aValue: Integer);
begin
  FData.AddOrSetValue('JOB_RULE_ID', aValue);
end;

class function TJobRequest.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'JOB_REQUESTS';

  AddField(Result.FieldList, 'JOB_RULE_ID', ftInteger);
end;

end.
