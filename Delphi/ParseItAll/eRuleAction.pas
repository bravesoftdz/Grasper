unit eRuleAction;

interface

uses
  API_ORM;

type
  TJobAction = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
  // Getters Setters
    function GetJobRuleID: Integer;
    procedure SetJobRuleID(aValue: integer);
    function GetActionTypeID: Integer;
    procedure SetActionTypeID(aValue: integer);
    function GetReGrabAfterAction: Boolean;
    procedure SetReGrabAfterAction(aValue: Boolean);
  //////////////////
  public
    property JobRuleID: Integer read GetJobRuleID write SetJobRuleID;
    property ActionTypeID: Integer read GetActionTypeID write SetActionTypeID;
    property ReGrabAfterAction: Boolean read GetReGrabAfterAction write SetReGrabAfterAction;
  end;

implementation

uses
  Data.DB;

function TJobAction.GetReGrabAfterAction: Boolean;
begin
  Result := FData.Items['REGRAB_AFTER_ACTION'];
end;

procedure TJobAction.SetReGrabAfterAction(aValue: Boolean);
begin
  FData.AddOrSetValue('REGRAB_AFTER_ACTION', aValue);
end;

function TJobAction.GetActionTypeID: Integer;
begin
  Result := FData.Items['ACTION_TYPE_ID'];
end;

procedure TJobAction.SetActionTypeID(aValue: integer);
begin
  FData.AddOrSetValue('ACTION_TYPE_ID', aValue);
end;

function TJobAction.GetJobRuleID: Integer;
begin
  Result := FData.Items['JOB_RULE_ID'];
end;

procedure TJobAction.SetJobRuleID(aValue: integer);
begin
  FData.AddOrSetValue('JOB_RULE_ID', aValue);
end;

class function TJobAction.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'JOB_RULE_ACTIONS';

  AddField(Result.FieldList, 'JOB_RULE_ID', ftInteger);
  AddField(Result.FieldList, 'ACTION_TYPE_ID', ftInteger);
  AddField(Result.FieldList, 'REGRAB_AFTER_ACTION', ftBoolean);
end;

end.
