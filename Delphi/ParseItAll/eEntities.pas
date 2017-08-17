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

 {TJobGroup = class(TEntityAbstract)
  private
    // Getters Setters
    function GetLevelID: Integer;
    procedure SetLevelID(aValue: integer);
    function GetNotes: string;
    procedure SetNotes(aValue: string);
    function GetRuleList: TRuleList;
    function GetRulesCount: Integer;
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
    property RulesCount: Integer read GetRulesCount;
    destructor Destroy; override;
  end;

  TGroupList = TEntityList<TJobGroup>;}

implementation

uses
  System.SysUtils;

{function TJobGroup.GetRulesCount: Integer;
begin
  if Rules <> nil then
    Result := Rules.Count
  else Result := 0;
end;   }

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

{function TJobGroup.GetRuleList: TRuleList;
begin
  if not Assigned(FRules) then
    FRules := TRuleList.Create(Self, 'GROUP_ID', ID, 'ORDER_NUM');

  Result := FRules;
end; }

{function TJobGroup.GetContainerNodes: TNodeList;
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
end; }

{procedure TJobGroup.SaveLists;
begin
  if Assigned(FRules) then FRules.SaveList(ID);
end;}

{destructor TJobGroup.Destroy;
begin
  inherited;
end;}

{function TJobGroup.GetNotes: string;
begin
  Result := FData.Items['NOTES'];
end;  }

{procedure TJobGroup.SetNotes(aValue: string);
begin
  FData.AddOrSetValue('NOTES', aValue);
end;}

{function TJobGroup.GetLevelID: Integer;
begin
  Result := FData.Items['LEVEL_ID'];
end;}

{procedure TJobGroup.SetLevelID(aValue: integer);
begin
  FData.AddOrSetValue('LEVEL_ID', aValue);
end; }

{class function TJobGroup.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'JOB_GROUPS';
  AddField(Result.FieldList, 'LEVEL_ID', ftInteger);
  AddField(Result.FieldList, 'NOTES', ftString);
end;}

end.
