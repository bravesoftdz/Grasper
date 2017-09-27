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
    function GetLink: string;
    procedure SetLink(aValue: string);
    function GetMethod: Integer;
    procedure SetMethod(aValue: Integer);
  ////////////////////
  public
    property JobRuleID: Integer read GetJobRuleID write SetJobRuleID;
    property Link: string read GetLink write SetLink;
    property Method: Integer read GetMethod write SetMethod;
  end;

  TJobRequestList = TEntityList<TJobRequest>;

implementation

uses
  Data.DB;

function TJobRequest.GetMethod: Integer;
begin
  Result := FData.Items['METHOD'];
end;

procedure TJobRequest.SetMethod(aValue: Integer);
begin
  FData.AddOrSetValue('METHOD', aValue);
end;

function TJobRequest.GetLink: string;
begin
  Result := FData.Items['LINK'];
end;

procedure TJobRequest.SetLink(aValue: string);
begin
  FData.AddOrSetValue('LINK', aValue);
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
  AddField(Result.FieldList, 'LINK', ftString);
  AddField(Result.FieldList, 'METHOD', ftInteger);
end;

end.
