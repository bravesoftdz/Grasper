unit eRuleRecords;

interface

uses
  API_ORM;

type
  TJobRecord = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
  // Getters Setters
    function GetKey: string;
    procedure SetKey(aValue: string);
  //////////////////
  public
    property Key: string read GetKey write SetKey;
  end;

  TRecordList = TEntityList<TJobRecord>;

implementation

uses
  Data.DB;

procedure TJobRecord.SetKey(aValue: string);
begin
  FData.AddOrSetValue('KEY', aValue);
end;

function TJobRecord.GetKey: string;
begin
  Result := FData.Items['KEY'];
end;

class function TJobRecord.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'JOB_RULE_RECORDS';
  AddField(Result.FieldList, 'JOB_RULE_ID', ftInteger);
  AddField(Result.FieldList, 'KEY', ftString);
end;

end.
