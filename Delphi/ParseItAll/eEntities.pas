unit eEntities;

interface

uses
  System.Generics.Collections,
  System.UITypes,
  Data.DB,
  API_ORM;

type
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
    function GetDescription: string;
    procedure SetDescription(aValue: string);
    function GetContainerOffset: integer;
    procedure SetContainerOffset(aValue: integer);
    function GetCriticalType: integer;
    procedure SetCriticalType(aValue: integer);
    function GetVisualColor: TColor;
    procedure SetVisualColor(aValue: TColor);
    function GetNodeList: TNodeList;
  //////////////////
  public
    function GetContainerInsideNodes: TNodeList;
    property GroupID: Integer read GetGroupID write SetGroupID;
    property Description: string read GetDescription write SetDescription;
    property ContainerOffset: Integer read GetContainerOffset write SetContainerOffset;
    property CriticalType: Integer read GetCriticalType write SetCriticalType;
    property VisualColor: TColor read GetVisualColor write SetVisualColor;
    property Nodes: TNodeList read GetNodeList;
  end;

  TJobRecord = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
  // Getters Setters
    function GetKey: string;
    procedure SetKey(aValue: string);
    function GetRule: TJobRule;
  //////////////////
  public
    property Key: string read GetKey write SetKey;
    property Rule: TJobRule read GetRule;
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
    function GetRule: TJobRule;
  //////////////////
  public
    property Level: Integer read GetLevel write SetLevel;
    property Rule: TJobRule read GetRule;
  end;

  TLinkList = TEntityList<TJobLink>;

  TJobGroup = class(TEntityAbstract)
  private
    // Getters Setters
    function GetLevelID: Integer;
    procedure SetLevelID(aValue: integer);
    function GetNotes: string;
    procedure SetNotes(aValue: string);
    function GetLinkList: TLinkList;
    function GetRecordList: TRecordList;
    //////////////////
  protected
    procedure SaveLists; override;
  private
    FLinks: TLinkList;
    FRecords: TRecordList;
  public
    class function GetEntityStruct: TEntityStruct; override;
    function GetContainerNodes: TNodeList;
    property LevelID: Integer read GetLevelID write SetLevelID;
    property Notes: string read GetNotes write SetNotes;
    property Links: TLinkList read GetLinkList;
    property Records: TRecordList read GetRecordList;
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
    function GetUserID: integer;
    procedure SetUserID(aValue: integer);
    //////////////////
    procedure SaveLists; override;
  public
    class function GetEntityStruct: TEntityStruct; override;
  published
    property Caption: string read GetCaption write SetCaption;
    property ZeroLink: string read GetZeroLink write SetZeroLink;
    property UserID: Integer read GetUserID write SetUserID;
    property Levels: TLevelList read GetLevels;
  end;

  TJobList = TEntityList<TJob>;

implementation

uses
  System.SysUtils;

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

  if Self.Links.Count > 0 then
    begin
      Nodes := Self.Links[0].Rule.Nodes;
      for i := 0 to Nodes.Count - 1 do
        if i < Nodes.Count - Self.Links[0].Rule.ContainerOffset then
          Result.Add(Nodes[i]);
    end;

  if (Result.Count = 0) and (Self.Records.Count > 0) then
    begin
      Nodes := Self.Records[0].Rule.Nodes;
      for i := 0 to Nodes.Count - 1 do
        if i < Nodes.Count - Self.Records[0].Rule.ContainerOffset then
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

function TJobRecord.GetRule: TJobRule;
begin
  Result := FRelations.Items['JOB_RULES'] as TJobRule;
end;

function TJobLink.GetRule: TJobRule;
begin
  Result := FRelations.Items['JOB_RULES'] as TJobRule;
end;

function TJobGroup.GetRecordList: TRecordList;
begin
  if not Assigned(FRecords) then
    FRecords := TRecordList.Create(Self, 'GROUP_ID', ID);

  Result := FRecords;
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
  AddRelation(Result.RelatedList, 'ID', 'JOB_RULE_ID', TJobRule);
end;

procedure TJobGroup.SaveLists;
begin
  if Assigned(FLinks) then FLinks.SaveList(ID);
  if Assigned(FRecords) then FRecords.SaveList(ID);
end;

function TJobGroup.GetLinkList: TLinkList;
begin
  if not Assigned(FLinks) then
    FLinks := TLinkList.Create(Self, 'GROUP_ID', ID);

  Result := FLinks;
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
  AddRelation(Result.RelatedList, 'ID', 'JOB_RULE_ID', TJobRule);
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
  AddField(Result.FieldList, 'DESCRIPTION', ftString);
  AddField(Result.FieldList, 'CONTAINER_OFFSET', ftInteger);
  AddField(Result.FieldList, 'CRITICAL_TYPE', ftInteger);
  AddField(Result.FieldList, 'VISUAL_COLOR', ftInteger);
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

function TJobRule.GetDescription: string;
begin
  Result := FData.Items['DESCRIPTION'];
end;

procedure TJobRule.SetDescription(aValue: string);
begin
  FData.AddOrSetValue('DESCRIPTION', aValue);
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

function TJob.GetUserID: integer;
begin
  Result := FData.Items['USER_ID'];
end;

procedure TJob.SetUserID(aValue: integer);
begin
  FData.AddOrSetValue('USER_ID', aValue);
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
  AddField(Result.FieldList, 'USER_ID', ftInteger);
  AddField(Result.FieldList, 'CAPTION', ftString);
  AddField(Result.FieldList, 'ZERO_LINK', ftString);
end;

end.
