unit eNodes;

interface

uses
  API_ORM;

type
  TDOMNode = record
    Tag: string;
    Index: Integer;
    KeyID: Integer;
    RuleID: Integer;
    Name: string;
    TagID: string;
    ClassName: string;
    ChildNodes: TArray<TDOMNode>;
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

implementation

uses
  Data.DB;

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

end.
