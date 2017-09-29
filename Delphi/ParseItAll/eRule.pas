unit eRule;

interface

uses
  System.UITypes,
  API_ORM,
  eRuleLink,
  eRuleRecords,
  eRuleCut,
  eRuleAction,
  eRegExp,
  eNodes,
  eRequest;

type
  TJobRule = class;

  TRuleRuleRel = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
  // Getters Setters
    function GetParentRuleID: Integer;
    procedure SetParentRuleID(aValue: Integer);
    function GetChildRuleID: Integer;
    procedure SetChildRuleID(aValue: Integer);
    function GetChildRule: TJobRule;
    procedure SetChildRule(aValue: TJobRule);
  //////////////////
  public
    property ParentRuleID: Integer read GetParentRuleID write SetParentRuleID;
    property ChildRuleID: Integer read GetChildRuleID write SetChildRuleID;
    property ChildRule: TJobRule read GetChildRule write SetChildRule;
  end;

  TRuleRuleRelList = TEntityList<TRuleRuleRel>;

  TJobRule = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
    procedure Assign(aSourceEntity: TEntityAbstract); override;
  protected
    procedure SaveLists; override;
  ////////////////////
  private
    FNodes: TNodeList;
    FChildRules: TRuleRuleRelList;
    FRegExps: TJobRegExpList;
    FIsBodyRule: Boolean;
  // Getters Setters
    function GetNotes: string;
    procedure SetNotes(aValue: string);
    function GetContainerOffset: integer;
    procedure SetContainerOffset(aValue: integer);
    function GetCriticalType: integer;
    procedure SetCriticalType(aValue: integer);
    function GetVisualColor: TColor;
    procedure SetVisualColor(aValue: TColor);
    function GetOrderNum: Integer;
    procedure SetOrderNum(aValue: Integer);
    function GetNodeList: TNodeList;
    function GetLink: TJobLink;
    procedure SetLink(aValue: TJobLink);
    function GetRec: TJobRecord;
    procedure SetRec(aValue: TJobRecord);
    function GetCut: TJobCut;
    procedure SetCut(aValue: TJobCut);
    function GetAction: TJobAction;
    procedure SetAction(aValue: TJobAction);
    function GetRequest: TJobRequest;
    procedure SetRequest(aValue: TJobRequest);
    function GetChildRules: TRuleRuleRelList;
    function GetRegExps: TJobRegExpList;
  //////////////////
    function HaveIndexOfRule(aJobRule, aTargetRule: TJobRule; var aIndexes: TArray<Integer>): Boolean;
  public
    function IndexOfChildRule(aJobRule: TJobRule): Integer;
    function GetChildIndexes(aJobRule: TJobRule): TArray<Integer>;
    function GetTreeChildRuleByID(aID: integer): TJobRule;
    property Notes: string read GetNotes write SetNotes;
    property ContainerOffset: Integer read GetContainerOffset write SetContainerOffset;
    property CriticalType: Integer read GetCriticalType write SetCriticalType;
    property VisualColor: TColor read GetVisualColor write SetVisualColor;
    property OrderNum: Integer read GetOrderNum write SetOrderNum;
    property Link: TJobLink read GetLink write SetLink;
    property Rec: TJobRecord read GetRec write SetRec;
    property Cut: TJobCut read GetCut write SetCut;
    property Action: TJobAction read GetAction write SetAction;
    property Request: TJobRequest read GetRequest write SetRequest;
    property Nodes: TNodeList read GetNodeList;
    property ChildRuleRels: TRuleRuleRelList read GetChildRules;
    property RegExps: TJobRegExpList read GetRegExps;
    property IsBodyRule: Boolean read FIsBodyRule write FIsBodyRule;
  end;

  TRuleList = TEntityList<TJobRule>;

implementation

uses
  Data.DB;

function TJobRule.GetTreeChildRuleByID(aID: integer): TJobRule;
var
  RuleRel: TRuleRuleRel;
begin
  for RuleRel in ChildRuleRels do
    begin
      if RuleRel.ChildRule.ID = aID then Exit(RuleRel.ChildRule);
      Result := RuleRel.ChildRule.GetTreeChildRuleByID(aID);
    end;
end;

function TJobRule.HaveIndexOfRule(aJobRule, aTargetRule: TJobRule; var aIndexes: TArray<Integer>): Boolean;
var
  RuleRel: TRuleRuleRel;
  i, level: Integer;
begin
  if aJobRule = aTargetRule then Exit(True);

  i := 0;
  SetLength(aIndexes, Length(aIndexes) + 1);
  level := Length(aIndexes) - 1;

  for RuleRel in aJobRule.ChildRuleRels do
    begin
      aIndexes[level] := i;
      if HaveIndexOfRule(RuleRel.ChildRule, aTargetRule, aIndexes) then
        Exit(True);
      Inc(i);
    end;

  SetLength(aIndexes, Length(aIndexes) - 1);
end;

function TJobRule.GetChildIndexes(aJobRule: TJobRule): TArray<Integer>;
begin
  HaveIndexOfRule(Self, aJobRule, Result);
end;

function TJobRule.GetRequest: TJobRequest;
begin
  Result := FOneRelations.Items['JOB_REQUESTS'] as TJobRequest;
end;

procedure TJobRule.SetRequest(aValue: TJobRequest);
begin
  FOneRelations.AddOrSetValue('JOB_REQUESTS', aValue);
end;

function TJobRule.GetAction: TJobAction;
begin
  Result := FOneRelations.Items['JOB_RULE_ACTIONS'] as TJobAction;
end;

procedure TJobRule.SetAction(aValue: TJobAction);
begin
  FOneRelations.AddOrSetValue('JOB_RULE_ACTIONS', aValue);
end;

procedure TJobRule.Assign(aSourceEntity: TEntityAbstract);
begin
  inherited;

  // Copy One To Many Relations
  if aSourceEntity is TJobRule then
    begin
      Nodes.Assign(TJobRule(aSourceEntity).Nodes);
      ChildRuleRels.Assign(TJobRule(aSourceEntity).ChildRuleRels);
      RegExps.Assign(TJobRule(aSourceEntity).RegExps);
    end;
end;

function TJobRule.IndexOfChildRule(aJobRule: TJobRule): Integer;
var
  RuleRuleRel: TRuleRuleRel;
  i: Integer;
begin
  Result := -1;
  i := 0;

  for RuleRuleRel in Self.ChildRuleRels do
    begin
      if RuleRuleRel.ChildRule = aJobRule then
        Exit(i);

      Inc(i);
    end;
end;

function TJobRule.GetRegExps: TJobRegExpList;
begin
  if not Assigned(FRegExps) then
    FRegExps := TJobRegExpList.Create(Self, 'JOB_RULE_ID', ID);

  Result := FRegExps;
end;

procedure TRuleRuleRel.SetChildRule(aValue: TJobRule);
begin
  FOneRelations.AddOrSetValue('JOB_RULES', aValue);
end;

function TRuleRuleRel.GetChildRule: TJobRule;
begin
  Result := FOneRelations.Items['JOB_RULES'] as TJobRule;
end;

function TJobRule.GetChildRules: TRuleRuleRelList;
begin
  if not Assigned(FChildRules) then
    FChildRules := TRuleRuleRelList.Create(Self, 'PARENT_RULE_ID', ID);

  Result := FChildRules;
end;

function TRuleRuleRel.GetChildRuleID: Integer;
begin
  Result := FData.Items['CHILD_RULE_ID'];
end;

procedure TRuleRuleRel.SetChildRuleID(aValue: Integer);
begin
  FData.AddOrSetValue('CHILD_RULE_ID', aValue);
end;

function TRuleRuleRel.GetParentRuleID: Integer;
begin
  Result := FData.Items['PARENT_RULE_ID'];
end;

procedure TRuleRuleRel.SetParentRuleID(aValue: Integer);
begin
  FData.AddOrSetValue('PARENT_RULE_ID', aValue);
end;

class function TRuleRuleRel.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'JOB_RULE2RULE';

  AddField(Result.FieldList, 'PARENT_RULE_ID', ftInteger);
  AddField(Result.FieldList, 'CHILD_RULE_ID', ftInteger);

  AddOneRelation(Result.OneRelatedList, 'ID', 'CHILD_RULE_ID', TJobRule);
end;

procedure TJobRule.SetCut(aValue: TJobCut);
begin
  FOneRelations.AddOrSetValue('JOB_RULE_CUTS', aValue);
end;

function TJobRule.GetCut: TJobCut;
begin
  Result := FOneRelations.Items['JOB_RULE_CUTS'] as TJobCut;
end;

function TJobRule.GetRec: TJobRecord;
begin
  Result := FOneRelations.Items['JOB_RULE_RECORDS'] as TJobRecord;
end;

procedure TJobRule.SetRec(aValue: TJobRecord);
begin
  FOneRelations.AddOrSetValue('JOB_RULE_RECORDS', aValue);
end;

function TJobRule.GetLink: TJobLink;
begin
  Result := FOneRelations.Items['JOB_RULE_LINKS'] as TJobLink;
end;

procedure TJobRule.SetLink(aValue: TJobLink);
begin
  FOneRelations.AddOrSetValue('JOB_RULE_LINKS', aValue);
end;

function TJobRule.GetOrderNum: Integer;
begin
  Result := FData.Items['ORDER_NUM'];
end;

procedure TJobRule.SetOrderNum(aValue: Integer);
begin
  FData.AddOrSetValue('ORDER_NUM', aValue);
end;

function TJobRule.GetVisualColor: TColor;
begin
  Result := FData.Items['VISUAL_COLOR'];
end;

procedure TJobRule.SetVisualColor(aValue: TColor);
begin
  FData.AddOrSetValue('VISUAL_COLOR', aValue);
end;

procedure TJobRule.SaveLists;
begin
  if Assigned(FNodes) then FNodes.SaveList(ID);
  if Assigned(FChildRules) then FChildRules.SaveList(ID);
  if Assigned(FRegExps) then FRegExps.SaveList(ID);
end;

function TJobRule.GetNodeList: TNodeList;
begin
  if not Assigned(FNodes) then
    FNodes := TNodeList.Create(Self, 'JOB_RULE_ID', ID);

  Result := FNodes;
end;

function TJobRule.GetContainerOffset: integer;
begin
  Result := FData.Items['CONTAINER_OFFSET'];
end;

procedure TJobRule.SetContainerOffset(aValue: integer);
begin
  FData.AddOrSetValue('CONTAINER_OFFSET', aValue);
end;

function TJobRule.GetCriticalType: integer;
begin
  Result := FData.Items['CRITICAL_TYPE'];
end;

procedure TJobRule.SetCriticalType(aValue: integer);
begin
  FData.AddOrSetValue('CRITICAL_TYPE', aValue);
end;

class function TJobRule.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'JOB_RULES';

  AddField(Result.FieldList, 'NOTES', ftString);
  AddField(Result.FieldList, 'CONTAINER_OFFSET', ftInteger);
  AddField(Result.FieldList, 'CRITICAL_TYPE', ftInteger);
  AddField(Result.FieldList, 'VISUAL_COLOR', ftInteger);
  AddField(Result.FieldList, 'ORDER_NUM', ftInteger);

  AddOneRelation(Result.OneRelatedList, 'JOB_RULE_ID', '', TJobLink);
  AddOneRelation(Result.OneRelatedList, 'JOB_RULE_ID', '', TJobRecord);
  AddOneRelation(Result.OneRelatedList, 'JOB_RULE_ID', '', TJobCut);
  AddOneRelation(Result.OneRelatedList, 'JOB_RULE_ID', '', TJobAction);
  AddOneRelation(Result.OneRelatedList, 'JOB_RULE_ID', '', TJobRequest);
end;

function TJobRule.GetNotes: string;
begin
  Result := FData.Items['NOTES'];
end;

procedure TJobRule.SetNotes(aValue: string);
begin
  FData.AddOrSetValue('NOTES', aValue);
end;

end.
