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
    function GetGrabType: integer;
    procedure SetGrabType(aValue: integer);
    function GetSpecialID: integer;
    procedure SetSpecialID(aValue: integer);
  //////////////////
  public
    property Key: string read GetKey write SetKey;
    property GrabType: Integer read GetGrabType write SetGrabType;
    property SpecialID: Integer read GetSpecialID write SetSpecialID;
  end;

  TRecordList = TEntityList<TJobRecord>;

implementation

uses
  Data.DB;

function TJobRecord.GetSpecialID: integer;
begin
  Result := FData.Items['SPECIAL_ID'];
end;

procedure TJobRecord.SetSpecialID(aValue: integer);
begin
  FData.AddOrSetValue('SPECIAL_ID', aValue);
end;

function TJobRecord.GetGrabType: integer;
begin
  Result := FData.Items['GRAB_TYPE'];
end;

procedure TJobRecord.SetGrabType(aValue: integer);
begin
  FData.AddOrSetValue('GRAB_TYPE', aValue);
end;

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
  AddField(Result.FieldList, 'GRAB_TYPE', ftInteger);
  AddField(Result.FieldList, 'SPECIAL_ID', ftInteger);
end;

end.
