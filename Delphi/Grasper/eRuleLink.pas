unit eRuleLink;

interface

uses
  API_ORM;

type
  TJobLink = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
  // Getters Setters
    function GetLevel: integer;
    procedure SetLevel(aValue: integer);
  //////////////////
  public
    property Level: Integer read GetLevel write SetLevel;
  end;

  TLinkList = TEntityList<TJobLink>;

implementation

uses
  Data.DB;

function TJobLink.GetLevel: integer;
begin
  Result := FData.Items['LEVEL'];
end;

procedure TJobLink.SetLevel(aValue: integer);
begin
  FData.AddOrSetValue('LEVEL', aValue);
end;

class function TJobLink.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'JOB_RULE_LINKS';
  AddField(Result.FieldList, 'JOB_RULE_ID', ftInteger);
  AddField(Result.FieldList, 'LEVEL', ftInteger);
end;

end.
