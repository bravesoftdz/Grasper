unit eRequest;

interface

uses
  API_ORM,
  eRuleAction;

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
    function GetTimeOut: Integer;
    procedure SetTimeOut(aValue: integer);
  ////////////////////
  public
    function GetTrigerActionList: TJobActionList;
    property JobRuleID: Integer read GetJobRuleID write SetJobRuleID;
    property TimeOut: Integer read GetTimeOut write SetTimeOut;
  end;

  TJobRequestList = TEntityList<TJobRequest>;

implementation

uses
  System.SysUtils,
  Data.DB;

function TJobRequest.GetTimeOut: Integer;
begin
  Result := FData.Items['TIME_OUT'];
end;

procedure TJobRequest.SetTimeOut(aValue: integer);
begin
  FData.AddOrSetValue('TIME_OUT', aValue);
end;

function TJobRequest.GetTrigerActionList: TJobActionList;
var
  Filter: string;
begin
  Filter := Format('TRIGER_REQUEST_ID = %d', [ID]);
  Result := TJobActionList.Create(FDBEngine, [Filter], []);
end;

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
  AddField(Result.FieldList, 'TIME_OUT', ftInteger);
end;

end.
