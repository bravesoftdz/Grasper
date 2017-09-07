unit eLevel;

interface

uses
  API_ORM,
  eRule,
  eTestLink;

type
  TLevelRuleRel = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
  // Getters Setters
    function GetLevelID: Integer;
    procedure SetLevelID(aValue: Integer);
    function GetRuleID: Integer;
    procedure SetRuleID(aValue: Integer);
    function GetRule: TJobRule;
    procedure SetRule(aValue: TJobRule);
  //////////////////
  public
    property LevelID: Integer read GetLevelID write SetLevelID;
    property RuleID: Integer read GetRuleID write SetRuleID;
    property Rule: TJobRule read GetRule write SetRule;
  end;

  TLevelRuleRelList = TEntityList<TLevelRuleRel>;

  TJobLevel = class(TEntityAbstract)
  // overrides
  private
    procedure SaveLists; override;
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
    FRuleRels: TLevelRuleRelList;
    FTestLinks: TTestLinkList;
  // Getters Setters
    function GetTestLinks: TTestLinkList;
    function GetRuleRels: TLevelRuleRelList;
    function GetLevel: integer;
    procedure SetLevel(aValue: integer);
    function GetBaseLink: string;
    procedure SetBaseLink(aValue: string);
    function GetCurrentTestLink: string;
  //////////////////
  public
    function GetActualTestLink(aLevel: Integer): TTestLink;
    property Level: Integer read GetLevel write SetLevel;
    property BaseLink: string read GetBaseLink write SetBaseLink;
    property RuleRels: TLevelRuleRelList read GetRuleRels;
    property TestLinks: TTestLinkList read GetTestLinks;
    property TestLink: string read GetCurrentTestLink;
  end;

  TLevelList = TEntityList<TJobLevel>;

implementation

uses
  Data.DB;

function TJobLevel.GetCurrentTestLink: string;
var
  TestLink: TTestLink;
begin
  TestLink := GetActualTestLink(Level);

  if TestLink = nil then
    Result := BaseLink
  else
    Result := TestLink.Link;
end;

function TJobLevel.GetActualTestLink(aLevel: Integer): TTestLink;
var
  TestLink: TTestLink;
begin
  Result := nil;

  for TestLink in TestLinks do
    if (TestLink.Level = aLevel) and TestLink.IsActual then Exit(TestLink);
end;

function TJobLevel.GetTestLinks: TTestLinkList;
begin
  if not Assigned(FTestLinks) then
    FTestLinks := TTestLinkList.Create(Self, 'LEVEL_ID', ID, 'IS_ACTUAL DESC');

  Result := FTestLinks;
end;

function TLevelRuleRel.GetRule: TJobRule;
begin
  Result := FRelations.Items['JOB_RULES'] as TJobRule;
end;

procedure TLevelRuleRel.SetRule(aValue: TJobRule);
begin
  FRelations.AddOrSetValue('JOB_RULES', aValue);
end;

function TLevelRuleRel.GetRuleID: Integer;
begin
  Result := FData.Items['RULE_ID'];
end;

procedure TLevelRuleRel.SetRuleID(aValue: Integer);
begin
  FData.AddOrSetValue('RULE_ID', aValue);
end;

function TLevelRuleRel.GetLevelID: Integer;
begin
  Result := FData.Items['LEVEL_ID'];
end;

procedure TLevelRuleRel.SetLevelID(aValue: integer);
begin
  FData.AddOrSetValue('LEVEL_ID', aValue);
end;

class function TLevelRuleRel.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'JOB_LEVEL2RULE';
  AddField(Result.FieldList, 'LEVEL_ID', ftInteger);
  AddField(Result.FieldList, 'RULE_ID', ftInteger);

  AddRelation(Result.RelatedList, 'ID', 'RULE_ID', TJobRule);
end;

procedure TJobLevel.SaveLists;
begin
  if Assigned(FRuleRels) then FRuleRels.SaveList(ID);
  if Assigned(FTestLinks) then FTestLinks.SaveList(ID);
end;

function TJobLevel.GetRuleRels: TLevelRuleRelList;
begin
  if not Assigned(FRuleRels) then
    FRuleRels := TLevelRuleRelList.Create(Self, 'LEVEL_ID', ID);

  Result := FRuleRels;
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
