unit eLevel;

interface

uses
  API_ORM,
  eRule,
  eTestLink;

type
  TJobLevel = class(TEntityAbstract)
  // overrides
  private
    procedure SaveLists; override;
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
    FTestLinks: TTestLinkList;
  // Getters Setters
    function GetTestLinks: TTestLinkList;
    function GetLevel: integer;
    procedure SetLevel(aValue: integer);
    function GetBaseLink: string;
    procedure SetBaseLink(aValue: string);
    function GetBodyRuleID: Integer;
    procedure SetBodyRuleID(aValue: integer);
    function GetBodyRule: TJobRule;
    procedure SetBodyRule(aValue: TJobRule);
    function GetCurrentTestLink: string;
  //////////////////
    function CreateBodyRule: TJobRule;
  public
    function GetActualTestLink(aLevel: Integer): TTestLink;
    property Level: Integer read GetLevel write SetLevel;
    property BaseLink: string read GetBaseLink write SetBaseLink;
    property BodyRuleID: Integer read GetBodyRuleID write SetBodyRuleID;
    property BodyRule: TJobRule read GetBodyRule write SetBodyRule;
    property TestLinks: TTestLinkList read GetTestLinks;
    property TestLink: string read GetCurrentTestLink;
  end;

  TLevelList = TEntityList<TJobLevel>;

implementation

uses
  System.UITypes,
  Data.DB,
  eNodes;

function TJobLevel.CreateBodyRule: TJobRule;
var
  Node: TJobNode;
begin
  Result := TJobRule.Create(FDBEngine);
  Result.Notes := 'Body';
  Result.CriticalType := 1;
  Result.VisualColor := TColor($FFFFFF);

  Node := TJobNode.Create(FDBEngine);
  Node.Tag := 'HTML';
  Node.Index := 1;
  Result.Nodes.Add(Node);

  Node := TJobNode.Create(FDBEngine);
  Node.Tag := 'BODY';
  Node.Index := 1;
  Result.Nodes.Add(Node);
end;

function TJobLevel.GetBodyRule: TJobRule;
begin
  Result := FOneRelations.Items['JOB_RULES'] as TJobRule;

  if Result = nil then
    begin
      SetBodyRule(CreateBodyRule);
      Result := GetBodyRule;
    end;

  Result.IsBodyRule := True;
end;

procedure TJobLevel.SetBodyRule(aValue: TJobRule);
begin
  FOneRelations.AddOrSetValue('JOB_RULES', aValue);
end;

function TJobLevel.GetBodyRuleID: Integer;
begin
  Result := FData.Items['BODY_RULE_ID'];
end;

procedure TJobLevel.SetBodyRuleID(aValue: integer);
begin
  FData.AddOrSetValue('BODY_RULE_ID', aValue);
end;

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

procedure TJobLevel.SaveLists;
begin
  if Assigned(FTestLinks) then FTestLinks.SaveList(ID);
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
  AddField(Result.FieldList, 'BODY_RULE_ID', ftInteger);

  AddOneRelation(Result.OneRelatedList, 'ID', 'BODY_RULE_ID', TJobRule);
end;

end.
