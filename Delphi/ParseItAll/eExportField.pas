unit eExportField;

interface

uses
  API_ORM;

type
  TExportField = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
  // Getters Setters
    function GetJobID: Integer;
    procedure SetJobID(aValue: Integer);
    function GetRuleRecID: Integer;
    procedure SetRuleRecID(aValue: Integer);
    function GetOrderNum: Integer;
    procedure SetOrderNum(aValue: Integer);
    function GetIsEnabled: Boolean;
    procedure SetIsEnabled(aValue: Boolean);
  ///////////////////////
  public
    property JobID: Integer read GetJobID write SetJobID;
    property RuleRecID: Integer read GetRuleRecID write SetRuleRecID;
    property OrderNum: Integer read GetOrderNum write SetOrderNum;
    property IsEnabled: Boolean read GetIsEnabled write SetIsEnabled;
  end;

  TExportFieldList = TEntityList<TExportField>;

implementation

uses
  Data.DB;

function TExportField.GetRuleRecID: Integer;
begin
  Result := FData.Items['JOB_RULE_REC_ID'];
end;

procedure TExportField.SetRuleRecID(aValue: Integer);
begin
  FData.AddOrSetValue('JOB_RULE_REC_ID', aValue);
end;

function TExportField.GetOrderNum: Integer;
begin
  Result := FData.Items['ORDER_NUM'];
end;

procedure TExportField.SetOrderNum(aValue: Integer);
begin
  FData.AddOrSetValue('ORDER_NUM', aValue);
end;

function TExportField.GetIsEnabled: Boolean;
begin
  Result := FData.Items['IS_ENABLED'];
end;

procedure TExportField.SetIsEnabled(aValue: Boolean);
begin
  FData.AddOrSetValue('IS_ENABLED', aValue);
end;

function TExportField.GetJobID: Integer;
begin
  Result := FData.Items['JOB_ID'];
end;

procedure TExportField.SetJobID(aValue: Integer);
begin
  FData.AddOrSetValue('JOB_ID', aValue);
end;

class function TExportField.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'EXPORT_FIELDS';

  AddField(Result.FieldList, 'JOB_ID', ftInteger);
  AddField(Result.FieldList, 'JOB_RULE_REC_ID', ftInteger);
  AddField(Result.FieldList, 'ORDER_NUM', ftInteger);
  AddField(Result.FieldList, 'IS_ENABLED', ftBoolean);
end;

end.
