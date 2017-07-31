unit eEntities;

interface

uses
  System.Generics.Collections,
  System.UITypes,
  Data.DB,
  API_ORM;

type
  TRecord = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
  // Getters Setters
    function GetLinkID: Integer;
    procedure SetLinkID(aValue: Integer);
    function GetNum: Integer;
    procedure SetNum(aValue: Integer);
    function GetKey: String;
    procedure SetKey(aValue: String);
    function GetValue: String;
    procedure SetValue(aValue: String);
  ///////////////////////
  public
    property LinkID: Integer read GetLinkID write SetLinkID;
    property Num: Integer read GetNum write SetNum;
    property Key: string read GetKey write SetKey;
    property Value: string read GetValue write SetValue;
  end;

  TLinkRel = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
  // Getters Setters
    function GetMasterLinkID: Integer;
    procedure SetMasterLinkID(aValue: Integer);
  ////////////////////
  public
    property MasterLinkID: Integer read GetMasterLinkID write SetMasterLinkID;
  end;

  TLink = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
  // Getters Setters
    function GetJobID: Integer;
    procedure SetJobID(aValue: Integer);
    function GetLevel: Integer;
    procedure SetLevel(aValue: Integer);
    function GetNum: Integer;
    procedure SetNum(aValue: Integer);
    function GetLink: string;
    procedure SetLink(aValue: string);
    function GetLinkHash: string;
    procedure SetLinkHash(aValue: string);
    function GetMasterRel: TLinkRel;
    procedure SetMasterRel(aValue: TLinkRel);
    function GetHandled: Integer;
    procedure SetHandled(aValue: Integer);
  ////////////////////
  public
    property JobID: Integer read GetJobID write SetJobID;
    property Level: Integer read GetLevel write SetLevel;
    property Num: Integer read GetNum write SetNum;
    property Link: string read GetLink write SetLink;
    property LinkHash: string read GetLinkHash write SetLinkHash;
    property MasterRel: TLinkRel read GetMasterRel write SetMasterRel;
    property Handled: Integer read GetHandled write SetHandled;
  end;

  TJobNode = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
  // Getters Setters
    function GetTag: string;
    procedure SetTag(aValue: string);
    function GetIndex: integer;
    procedure SetIndex(aValue: integer);
    function GetTagID: string;
    procedure SetTagID(aValue: string);
    function GetClassName: string;
    procedure SetClassName(aValue: string);
    function GetName: string;
    procedure SetName(aValue: string);
  ////////////////////
  public
    property Tag: string read GetTag write SetTag;
    property Index: Integer read GetIndex write SetIndex;
    property TagID: string read GetTagID write SetTagID;
    property ClassName: string read GetClassName write SetClassName;
    property Name: string read GetName write SetName;
  end;

  TNodeList = TEntityList<TJobNode>;

  TJobCut = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
  // Getters Setters
    function GetNotes: string;
    procedure SetNotes(aValue: string);
  ////////////////////
  public
    property Notes: string read GetNotes write SetNotes;
  end;

  TCutList = TEntityList<TJobCut>;

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

  TJobRule = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  protected
    procedure SaveLists; override;
  ////////////////////
  private
    FNodes: TNodeList;
  // Getters Setters
    function GetGroupID: Integer;
    procedure SetGroupID(aValue: integer);
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
  //////////////////
  public
    function GetContainerInsideNodes: TNodeList;
    property GroupID: Integer read GetGroupID write SetGroupID;
    property Notes: string read GetNotes write SetNotes;
    property ContainerOffset: Integer read GetContainerOffset write SetContainerOffset;
    property CriticalType: Integer read GetCriticalType write SetCriticalType;
    property VisualColor: TColor read GetVisualColor write SetVisualColor;
    property OrderNum: Integer read GetOrderNum write SetOrderNum;
    property Link: TJobLink read GetLink write SetLink;
    property Rec: TJobRecord read GetRec write SetRec;
    property Cut: TJobCut read GetCut write SetCut;
    property Nodes: TNodeList read GetNodeList;
  end;

  TRuleList = TEntityList<TJobRule>;

  TJobGroup = class(TEntityAbstract)
  private
    // Getters Setters
    function GetLevelID: Integer;
    procedure SetLevelID(aValue: integer);
    function GetNotes: string;
    procedure SetNotes(aValue: string);
    function GetRuleList: TRuleList;
    //////////////////
  protected
    procedure SaveLists; override;
  private
    FRules: TRuleList;
  public
    class function GetEntityStruct: TEntityStruct; override;
    function GetContainerNodes: TNodeList;
    property LevelID: Integer read GetLevelID write SetLevelID;
    property Notes: string read GetNotes write SetNotes;
    property Rules: TRuleList read GetRuleList;
    destructor Destroy; override;
  end;

  TGroupList = TEntityList<TJobGroup>;

  TJobLevel = class(TEntityAbstract)
  protected
    FGroups: TGroupList;
    // Getters Setters
    function GetGroups: TGroupList;
    function GetLevel: integer;
    procedure SetLevel(aValue: integer);
    function GetBaseLink: string;
    procedure SetBaseLink(aValue: string);
    //////////////////
    procedure SaveLists; override;
  public
    class function GetEntityStruct: TEntityStruct; override;
    property Level: Integer read GetLevel write SetLevel;
    property BaseLink: string read GetBaseLink write SetBaseLink;
    property Groups: TGroupList read GetGroups;
  end;

  TLevelList = TEntityList<TJobLevel>;

  TJob = class(TEntityAbstract)
  protected
    FLevels: TLevelList;
    // Getters Setters
    function GetLevels: TLevelList;
    function GetCaption: string;
    procedure SetCaption(aValue: string);
    function GetZeroLink: string;
    procedure SetZeroLink(aValue: string);
    //////////////////
    procedure SaveLists; override;
  public
    class function GetEntityStruct: TEntityStruct; override;
    function GetLevel(aLevel: integer): TJobLevel;
  published
    property Caption: string read GetCaption write SetCaption;
    property ZeroLink: string read GetZeroLink write SetZeroLink;
    property Levels: TLevelList read GetLevels;
  end;

  TJobList = TEntityList<TJob>;

implementation

uses
  System.SysUtils;

function TLink.GetLinkHash: string;
begin
  Result := FData.Items['LINK_HASH'];
end;

procedure TLink.SetLinkHash(aValue: string);
begin
  FData.AddOrSetValue('LINK_HASH', aValue);
end;

function TRecord.GetNum: Integer;
begin
  Result := FData.Items['NUM'];
end;

procedure TRecord.SetNum(aValue: Integer);
begin
  FData.AddOrSetValue('NUM', aValue);
end;

function TRecord.GetKey: String;
begin
  Result := FData.Items['KEY'];
end;

procedure TRecord.SetKey(aValue: String);
begin
  FData.AddOrSetValue('KEY', aValue);
end;

function TRecord.GetValue: String;
begin
  Result := FData.Items['VALUE'];
end;

procedure TRecord.SetValue(aValue: String);
begin
  FData.AddOrSetValue('VALUE', aValue);
end;

function TRecord.GetLinkID: Integer;
begin
  Result := FData.Items['LINK_ID'];
end;

procedure TRecord.SetLinkID(aValue: Integer);
begin
  FData.AddOrSetValue('LINK_ID', aValue);
end;

class function TRecord.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'RECORDS';

  AddField(Result.FieldList, 'LINK_ID', ftInteger);
  AddField(Result.FieldList, 'NUM', ftInteger);
  AddField(Result.FieldList, 'KEY', ftString);
  AddField(Result.FieldList, 'VALUE', ftString);
end;

function TLink.GetHandled: Integer;
begin
  Result := FData.Items['HANDLED'];
end;

procedure TLink.SetHandled(aValue: Integer);
begin
  FData.AddOrSetValue('HANDLED', aValue);
end;

procedure TLink.SetMasterRel(aValue: TLinkRel);
begin
  FRelations.AddOrSetValue('LINK2LINK', aValue);
end;

function TLinkRel.GetMasterLinkID: Integer;
begin
  Result := FData.Items['MASTER_LINK_ID'];
end;

procedure TLinkRel.SetMasterLinkID(aValue: Integer);
begin
  FData.AddOrSetValue('MASTER_LINK_ID', aValue);
end;

function TLink.GetMasterRel: TLinkRel;
begin
  Result := FRelations.Items['LINK2LINK'] as TLinkRel;
end;

class function TLinkRel.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'LINK2LINK';

  AddField(Result.FieldList, 'MASTER_LINK_ID', ftInteger);
  AddField(Result.FieldList, 'SLAVE_LINK_ID', ftInteger);
end;

function TJob.GetLevel(aLevel: integer): TJobLevel;
var
  Level: TJobLevel;
begin
  Result := nil;

  for Level in Levels do
    if Level.Level = aLevel then Exit(Level);
end;

function TLink.GetLink: string;
begin
  Result := FData.Items['LINK'];
end;

procedure TLink.SetLink(aValue: string);
begin
  FData.AddOrSetValue('LINK', aValue);
end;

function TLink.GetNum: Integer;
begin
  Result := FData.Items['NUM'];
end;

procedure TLink.SetNum(aValue: Integer);
begin
  FData.AddOrSetValue('NUM', aValue);
end;

function TLink.GetLevel: Integer;
begin
  Result := FData.Items['LEVEL'];
end;

procedure TLink.SetLevel(aValue: Integer);
begin
  FData.AddOrSetValue('LEVEL', aValue);
end;

function TLink.GetJobID: Integer;
begin
  Result := FData.Items['JOB_ID'];
end;

procedure TLink.SetJobID(aValue: Integer);
begin
  FData.AddOrSetValue('JOB_ID', aValue);
end;

class function TLink.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'LINKS';

  AddField(Result.FieldList, 'JOB_ID', ftInteger);
  AddField(Result.FieldList, 'LEVEL', ftInteger);
  AddField(Result.FieldList, 'NUM', ftInteger);
  AddField(Result.FieldList, 'LINK', ftString);
  AddField(Result.FieldList, 'LINK_HASH', ftString);
  AddField(Result.FieldList, 'HANDLED', ftInteger);

  AddRelation(Result.RelatedList, 'SLAVE_LINK_ID', '', TLinkRel);
end;

procedure TJobRule.SetCut(aValue: TJobCut);
begin
  FRelations.AddOrSetValue('JOB_RULE_CUTS', aValue);
end;

function TJobRule.GetCut: TJobCut;
begin
  Result := FRelations.Items['JOB_RULE_CUTS'] as TJobCut;
end;

function TJobRule.GetRec: TJobRecord;
begin
  Result := FRelations.Items['JOB_RULE_RECORDS'] as TJobRecord;
end;

procedure TJobRule.SetRec(aValue: TJobRecord);
begin
  FRelations.AddOrSetValue('JOB_RULE_RECORDS', aValue);
end;

function TJobRule.GetLink: TJobLink;
begin
  Result := FRelations.Items['JOB_RULE_LINKS'] as TJobLink;
end;

procedure TJobRule.SetLink(aValue: TJobLink);
begin
  FRelations.AddOrSetValue('JOB_RULE_LINKS', aValue);
end;

function TJobGroup.GetRuleList: TRuleList;
begin
  if not Assigned(FRules) then
    FRules := TRuleList.Create(Self, 'GROUP_ID', ID, 'ORDER_NUM');

  Result := FRules;
end;

function TJobRule.GetOrderNum: Integer;
begin
  Result := FData.Items['ORDER_NUM'];
end;

procedure TJobRule.SetOrderNum(aValue: Integer);
begin
  FData.AddOrSetValue('ORDER_NUM', aValue);
end;

function TJobCut.GetNotes: string;
begin
  Result := FData.Items['NOTES'];
end;

procedure TJobCut.SetNotes(aValue: string);
begin
  FData.AddOrSetValue('NOTES', aValue);
end;

class function TJobCut.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'JOB_RULE_CUTS';

  AddField(Result.FieldList, 'JOB_RULE_ID', ftInteger);
  AddField(Result.FieldList, 'NOTES', ftString);
end;

function TJobRule.GetVisualColor: TColor;
begin
  Result := FData.Items['VISUAL_COLOR'];
end;

procedure TJobRule.SetVisualColor(aValue: TColor);
begin
  FData.AddOrSetValue('VISUAL_COLOR', aValue);
end;

function TJobRule.GetContainerInsideNodes: TNodeList;
var
  Node: TJobNode;
  i: Integer;
begin
  Result := TNodeList.Create(False);
  i := 0;
  for Node in Self.Nodes do
    begin
      Inc(i);
      if i > Nodes.Count - Self.ContainerOffset then
        Result.Add(Node);
    end;
end;

function TJobGroup.GetContainerNodes: TNodeList;
var
  i: integer;
  Nodes: TNodeList;
begin
  Result := TNodeList.Create(False);

  if Self.Rules.Count > 0 then
    begin
      Nodes := Self.Rules[0].Nodes;
      for i := 0 to Nodes.Count - 1 do
        if i < Nodes.Count - Self.Rules[0].ContainerOffset then
          Result.Add(Nodes[i]);
    end;
end;

function TJobNode.GetName: string;
begin
  Result := FData.Items['NAME'];
end;

procedure TJobNode.SetName(aValue: string);
begin
  FData.AddOrSetValue('NAME', aValue);
end;

function TJobNode.GetClassName: string;
begin
  Result := FData.Items['CLASS'];
end;

procedure TJobNode.SetClassName(aValue: string);
begin
  FData.AddOrSetValue('CLASS', aValue);
end;

function TJobNode.GetTagID: string;
begin
  Result := FData.Items['TAG_ID'];
end;

procedure TJobNode.SetTagID(aValue: string);
begin
  FData.AddOrSetValue('TAG_ID', aValue);
end;

procedure TJobRule.SaveLists;
begin
  if Assigned(FNodes) then FNodes.SaveList(ID);
end;

function TJobNode.GetIndex: integer;
begin
  Result := FData.Items['INDEX'];
end;

procedure TJobNode.SetIndex(aValue: integer);
begin
  FData.AddOrSetValue('INDEX', aValue);
end;

function TJobNode.GetTag: string;
begin
  Result := FData.Items['TAG'];
end;

procedure TJobNode.SetTag(aValue: string);
begin
  FData.AddOrSetValue('TAG', aValue);
end;

function TJobRule.GetNodeList: TNodeList;
begin
  if not Assigned(FNodes) then
    FNodes := TNodeList.Create(Self, 'JOB_RULE_ID', ID);

  Result := FNodes;
end;

class function TJobNode.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'JOB_NODES';
  AddField(Result.FieldList, 'JOB_RULE_ID', ftInteger);
  AddField(Result.FieldList, 'TAG', ftString);
  AddField(Result.FieldList, 'INDEX', ftInteger);
  AddField(Result.FieldList, 'TAG_ID', ftString);
  AddField(Result.FieldList, 'CLASS', ftString);
  AddField(Result.FieldList, 'NAME', ftString);
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
end;

procedure TJobGroup.SaveLists;
begin
  if Assigned(FRules) then FRules.SaveList(ID);
end;

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
  AddField(Result.FieldList, 'GROUP_ID', ftInteger);
  AddField(Result.FieldList, 'NOTES', ftString);
  AddField(Result.FieldList, 'CONTAINER_OFFSET', ftInteger);
  AddField(Result.FieldList, 'CRITICAL_TYPE', ftInteger);
  AddField(Result.FieldList, 'VISUAL_COLOR', ftInteger);
  AddField(Result.FieldList, 'ORDER_NUM', ftInteger);

  AddRelation(Result.RelatedList, 'JOB_RULE_ID', '', TJobLink);
  AddRelation(Result.RelatedList, 'JOB_RULE_ID', '', TJobRecord);
  AddRelation(Result.RelatedList, 'JOB_RULE_ID', '', TJobCut);
end;

destructor TJobGroup.Destroy;
begin
  inherited;
end;

procedure TJobLevel.SaveLists;
begin
  if Assigned(FGroups) then FGroups.SaveList(ID);
end;

procedure TJob.SaveLists;
begin
  if Assigned(FLevels) then FLevels.SaveList(ID);
end;

function TJob.GetLevels: TLevelList;
begin
  if not Assigned(FLevels) then
    FLevels := TLevelList.Create(Self, 'JOB_ID', ID);

  Result := FLevels;
end;

function TJobRule.GetGroupID: Integer;
begin
  Result := FData.Items['GROUP_ID'];
end;

procedure TJobRule.SetGroupID(aValue: integer);
begin
  FData.AddOrSetValue('GROUP_ID', aValue);
end;

function TJobRule.GetNotes: string;
begin
  Result := FData.Items['NOTES'];
end;

procedure TJobRule.SetNotes(aValue: string);
begin
  FData.AddOrSetValue('NOTES', aValue);
end;

function TJobLevel.GetGroups: TGroupList;
begin
  if not Assigned(FGroups)  then
    FGroups := TGroupList.Create(Self, 'LEVEL_ID', ID);

  Result := FGroups;
end;

function TJobGroup.GetNotes: string;
begin
  Result := FData.Items['NOTES'];
end;

procedure TJobGroup.SetNotes(aValue: string);
begin
  FData.AddOrSetValue('NOTES', aValue);
end;

function TJobGroup.GetLevelID: Integer;
begin
  Result := FData.Items['LEVEL_ID'];
end;

procedure TJobGroup.SetLevelID(aValue: integer);
begin
  FData.AddOrSetValue('LEVEL_ID', aValue);
end;

class function TJobGroup.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'JOB_GROUPS';
  AddField(Result.FieldList, 'LEVEL_ID', ftInteger);
  AddField(Result.FieldList, 'NOTES', ftString);
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

procedure TJob.SetZeroLink(aValue: string);
begin
  FData.AddOrSetValue('ZERO_LINK', aValue);
end;

function TJob.GetZeroLink: string;
begin
  Result := FData.Items['ZERO_LINK'];
end;

procedure TJob.SetCaption(aValue: string);
begin
  FData.AddOrSetValue('CAPTION', aValue);
end;

function TJob.GetCaption;
begin
  Result := FData.Items['CAPTION'];
end;

class function TJob.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'JOBS';
  AddField(Result.FieldList, 'CAPTION', ftString);
  AddField(Result.FieldList, 'ZERO_LINK', ftString);
end;

end.
