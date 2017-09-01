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

implementation

uses
  Data.DB;

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

end.
