unit eGroup;

interface

uses
  API_ORM;

type
  TGroup = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
  // Getters Setters
    function GetJobID: Integer;
    procedure SetJobID(aValue: Integer);
  ///////////////////////
  public
    property JobID: Integer read GetJobID write SetJobID;
  end;

implementation

uses
  Data.DB;

function TGroup.GetJobID: Integer;
begin
  Result := FData.Items['JOB_ID'];
end;

procedure TGroup.SetJobID(aValue: Integer);
begin
  FData.AddOrSetValue('JOB_ID', aValue);
end;

class function TGroup.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'GROUPS';

  AddField(Result.FieldList, 'JOB_ID', ftInteger);
end;

end.
