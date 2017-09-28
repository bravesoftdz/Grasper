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
    function GetFillValue: String;
    procedure SetFillValue(aValue: String);
    function GetExecuteAfterLoad: Boolean;
    procedure SetExecuteAfterLoad(aValue: Boolean);
  //////////////////
  public
    property JobRuleID: Integer read GetJobRuleID write SetJobRuleID;
    property ActionTypeID: Integer read GetActionTypeID write SetActionTypeID;
    property FillValue: string read GetFillValue write SetFillValue;
    property ExecuteAfterLoad: Boolean read GetExecuteAfterLoad write SetExecuteAfterLoad;
  end;

implementation

uses
  Data.DB;

function TJobAction.GetExecuteAfterLoad: Boolean;
begin
  Result := FData.Items['EXECUTE_AFTER_LOAD'];
end;

procedure TJobAction.SetExecuteAfterLoad(aValue: Boolean);
begin
  FData.AddOrSetValue('EXECUTE_AFTER_LOAD', aValue);
end;

function TJobAction.GetFillValue: String;
begin
  Result := FData.Items['FILL_VALUE'];
end;

procedure TJobAction.SetFillValue(aValue: String);
begin
  FData.AddOrSetValue('FILL_VALUE', aValue);
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
  AddField(Result.FieldList, 'FILL_VALUE', ftString);
  AddField(Result.FieldList, 'EXECUTE_AFTER_LOAD', ftBoolean);
end;

end.
