unit eLevel;

interface

uses
  API_ORM,
  eRule;

type
  TJobLevel = class(TEntityAbstract)
  // overrides
  private
    procedure SaveLists; override;
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
    FRules: TRuleList;
  // Getters Setters
    function GetRules: TRuleList;
    function GetLevel: integer;
    procedure SetLevel(aValue: integer);
    function GetBaseLink: string;
    procedure SetBaseLink(aValue: string);
  //////////////////
  public
    property Level: Integer read GetLevel write SetLevel;
    property BaseLink: string read GetBaseLink write SetBaseLink;
    property Rules: TRuleList read GetRules;
  end;

  TLevelList = TEntityList<TJobLevel>;

implementation

uses
  Data.DB;

procedure TJobLevel.SaveLists;
begin
  if Assigned(FRules) then FRules.SaveList(ID);
end;

function TJobLevel.GetRules: TRuleList;
begin
  if not Assigned(FRules)  then
    FRules := TRuleList.Create(Self, 'LEVEL_ID', ID);

  Result := FRules;
end;

function TJobLevel.GetBaseLink: string;
begin
  Result := FData.Items['BASE_LINK'];
end;

procedure TJobLevel.SetBaseLink(aValue: string);
begin
  FData.AddOrSetValue('BASE_LINK', aValue);
end;

function TJobLevel.GetLevel: integer;
begin
  Result := FData.Items['LEVEL'];
end;

procedure TJobLevel.SetLevel(aValue: integer);
begin
  FData.AddOrSetValue('LEVEL', aValue);
end;

class function TJobLevel.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'JOB_LEVELS';
  AddField(Result.FieldList, 'JOB_ID', ftInteger);
  AddField(Result.FieldList, 'LEVEL', ftInteger);
  AddField(Result.FieldList, 'BASE_LINK', ftString);
end;

end.
