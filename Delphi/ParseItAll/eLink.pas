unit eLink;

interface

uses
  System.Generics.Collections,
  API_ORM,
  eRecord;

type
  TLinkRel = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
  // Getters Setters
    function GetParentLinkID: Integer;
    procedure SetParentLinkID(aValue: Integer);
  ////////////////////
  public
    property ParentLinkID: Integer read GetParentLinkID write SetParentLinkID;
  end;

  TLink = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  protected
    procedure SaveLists; override;
  ////////////////////
  private
    FRecords: TRecordList;
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
    function GetParentRel: TLinkRel;
    procedure SetParentRel(aValue: TLinkRel);
    function GetHandled: Integer;
    procedure SetHandled(aValue: Integer);
    function GetHandleTime: TDateTime;
    procedure SetHandleTime(aValue: TDateTime);
    function GetRecordList: TRecordList;
  ////////////////////
  public
    function GetRecordsByKey(aKey: string; aResult: TObjectList<TRecord> = nil): TObjectList<TRecord>;
    property JobID: Integer read GetJobID write SetJobID;
    property Level: Integer read GetLevel write SetLevel;
    property Num: Integer read GetNum write SetNum;
    property Link: string read GetLink write SetLink;
    property LinkHash: string read GetLinkHash write SetLinkHash;
    property ParentRel: TLinkRel read GetParentRel write SetParentRel;
    property Handled: Integer read GetHandled write SetHandled;
    property HandleTime: TDateTime read GetHandleTime write SetHandleTime;
    property Records: TRecordList read GetRecordList;
  end;

implementation

uses
  Data.DB;

function TLink.GetRecordsByKey(aKey: string; aResult: TObjectList<TRecord> = nil): TObjectList<TRecord>;
var
  Rec: TRecord;
  ParentLink: TLink;
begin
  if aResult = nil then
    Result := TObjectList<TRecord>.Create(True)
  else
    Result := aResult;

  for Rec in Records do
    if Rec.Key = aKey then
      begin
        Records.Extract(Rec);
        Result.Add(Rec);
      end;

  if ParentRel <> nil then
    begin
      ParentLink := TLink.Create(FDBEngine, ParentRel.ParentLinkID);
      try
        ParentLink.GetRecordsByKey(aKey, Result);
      finally
        ParentLink.Free;
      end;
    end;
end;

procedure TLink.SaveLists;
begin
  if Assigned(FRecords) then FRecords.SaveList(ID);
end;

function TLink.GetRecordList: TRecordList;
begin
  if not Assigned(FRecords) then
    FRecords := TRecordList.Create(Self, 'LINK_ID', ID);

  Result := FRecords;
end;

function TLink.GetHandleTime: TDateTime;
begin
  Result := FData.Items['HANDLE_TIME'];
end;

procedure TLink.SetHandleTime(aValue: TDateTime);
begin
  FData.AddOrSetValue('HANDLE_TIME', aValue);
end;

function TLink.GetLinkHash: string;
begin
  Result := FData.Items['LINK_HASH'];
end;

procedure TLink.SetLinkHash(aValue: string);
begin
  FData.AddOrSetValue('LINK_HASH', aValue);
end;

function TLink.GetHandled: Integer;
begin
  Result := FData.Items['HANDLED'];
end;

procedure TLink.SetHandled(aValue: Integer);
begin
  FData.AddOrSetValue('HANDLED', aValue);
end;

procedure TLink.SetParentRel(aValue: TLinkRel);
begin
  FOneRelations.AddOrSetValue('LINK2LINK', aValue);
end;

function TLinkRel.GetParentLinkID: Integer;
begin
  Result := FData.Items['PARENT_LINK_ID'];
end;

procedure TLinkRel.SetParentLinkID(aValue: Integer);
begin
  FData.AddOrSetValue('PARENT_LINK_ID', aValue);
end;

function TLink.GetParentRel: TLinkRel;
begin
  Result := FOneRelations.Items['LINK2LINK'] as TLinkRel;
end;

class function TLinkRel.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'LINK2LINK';

  AddField(Result.FieldList, 'PARENT_LINK_ID', ftInteger);
  AddField(Result.FieldList, 'CHILD_LINK_ID', ftInteger);
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
  AddField(Result.FieldList, 'HANDLE_TIME', ftDateTime);

  AddOneRelation(Result.OneRelatedList, 'CHILD_LINK_ID', '', TLinkRel);
end;

end.
