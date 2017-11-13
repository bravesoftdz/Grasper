unit eRecord;

interface

uses
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
    function GetGroupID: Integer;
    procedure SetGroupID(aValue: Integer);
    function GetKey: String;
    procedure SetKey(aValue: String);
    function GetValue: String;
    procedure SetValue(aValue: String);
    function GetValueHash: String;
    procedure SetValueHash(aValue: String);
  ///////////////////////
  public
    property LinkID: Integer read GetLinkID write SetLinkID;
    property GroupID: Integer read GetGroupID write SetGroupID;
    property Key: string read GetKey write SetKey;
    property Value: string read GetValue write SetValue;
    property ValueHash: string read GetValueHash write SetValueHash;
  end;

  TRecordList = TEntityList<TRecord>;

implementation

uses
  Data.DB;

function TRecord.GetValueHash: String;
begin
  Result := FData.Items['VALUE_HASH'];
end;

procedure TRecord.SetValueHash(aValue: String);
begin
  FData.AddOrSetValue('VALUE_HASH', aValue);
end;

function TRecord.GetGroupID: Integer;
begin
  Result := FData.Items['GROUP_ID'];
end;

procedure TRecord.SetGroupID(aValue: Integer);
begin
  FData.AddOrSetValue('GROUP_ID', aValue);
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
  AddField(Result.FieldList, 'GROUP_ID', ftInteger);
  AddField(Result.FieldList, 'KEY', ftString);
  AddField(Result.FieldList, 'VALUE', ftString);
  AddField(Result.FieldList, 'VALUE_HASH', ftString);
end;

end.
