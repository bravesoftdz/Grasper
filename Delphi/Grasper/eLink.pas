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
    function GetChildLinkID: Integer;
    procedure SetChildLinkID(aValue: Integer);
  ////////////////////
  public
    property ParentLinkID: Integer read GetParentLinkID write SetParentLinkID;
    property ChildLinkID: Integer read GetChildLinkID write SetChildLinkID;
  end;

  TLinkRelList = TEntityList<TLinkRel>;

  TLink = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  protected
    procedure SaveLists; override;
  ////////////////////
  private
    FRecords: TRecordList;
    FChildLinkRels: TLinkRelList;
    function CheckGroupInChain(aRecGroupID, aCheckGroupID: integer): Boolean;
  // Getters Setters
    function GetLevel: Integer;
    procedure SetLevel(aValue: Integer);
    function GetGroupID: Integer;
    procedure SetGroupID(aValue: Integer);
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
    function GetChildLinkRels: TLinkRelList;
  ////////////////////
  private
  //////////////////////////////////////////////////////////////////////////////
    function GetParentLinkID(aLinkID: integer; out aGroupID: Integer): Integer;
    function GetRecIDsByKey(aKey: string): TArray<Integer>;
  //////////////////////////////////////////////////////////////////////////////
  public
  //////////////////////////////////////////////////////////////////////////////
    function CreateRecListByKey(aKey: string): TRecordList;
    function GetFirstValueByKey(aKey: string): string;
  //////////////////////////////////////////////////////////////////////////////
    function GetRecordsByKey(aKey: string; aResult: TObjectList<TRecord> = nil; aOrignLink: TLink = nil; aGroupID: Integer = 0): TObjectList<TRecord>;
    property GroupID: Integer read GetGroupID write SetGroupID;
    property Level: Integer read GetLevel write SetLevel;
    property Link: string read GetLink write SetLink;
    property LinkHash: string read GetLinkHash write SetLinkHash;
    property ParentRel: TLinkRel read GetParentRel write SetParentRel;
    property Handled: Integer read GetHandled write SetHandled;
    property HandleTime: TDateTime read GetHandleTime write SetHandleTime;
    property Records: TRecordList read GetRecordList;
    property ChildLinkRels: TLinkRelList read GetChildLinkRels;
  end;

implementation

uses
  Data.DB,
  FireDAC.Comp.Client,
  eGroup,
  System.SysUtils;

function TLink.GetFirstValueByKey(aKey: string): string;
var
  RecList: TRecordList;
begin
  RecList := CreateRecListByKey(aKey);
  try
    if RecList.Count > 0 then
      Result := RecList[0].Value
    else
      Result := '';
  finally
    RecList.Free;
  end;
end;

function TLink.GetParentLinkID(aLinkID: Integer; out aGroupID: Integer): Integer;
var
  ParentLink: TLink;
begin
  ParentLink := TLink.Create(FDBEngine, aLinkID);
  try
    if ParentLink.ParentRel <> nil then
      begin
        Result := ParentLink.ParentRel.ParentLinkID;
        aGroupID := ParentLink.GroupID;
      end
    else
      Result := 0;
  finally
    ParentLink.Free;
  end;
end;

function TLink.GetRecIDsByKey(aKey: string): TArray<Integer>;
var
  dsQuery: TFDQuery;
  GroupID: Integer;
  LinkID: Integer;
  ParentLinkID: Integer;
  SQL: string;
begin
  LinkID := Self.ID;
  ParentLinkID := 0;

  dsQuery := TFDQuery.Create(nil);
  try
    repeat
      SQL := 'select Id, group_id from records where link_id = :LinkID and key = :Key order by Id';

      dsQuery.SQL.Text := SQL;
      dsQuery.ParamByName('LinkID').AsInteger := LinkID;
      dsQuery.ParamByName('Key').AsString := aKey;

      FDBEngine.OpenQuery(dsQuery);

      while not dsQuery.EOF  do
        begin
          if ((ParentLinkID > 0) and
              CheckGroupInChain(GroupID, dsQuery.FieldByName('group_id').AsInteger)
             )
             or (ParentLinkID = 0)
          then
            Result := Result + [dsQuery.FieldByName('Id').AsInteger];

          dsQuery.Next;
        end;

      ParentLinkID := GetParentLinkID(LinkID, GroupID);
      if (Length(Result) = 0) and (ParentLinkID > 0) then
        LinkID := ParentLinkID;

    until (Length(Result) > 0) or (ParentLinkID = 0);
  finally
    dsQuery.Free;
  end;
end;

function TLink.CreateRecListByKey(aKey: string): TRecordList;
var
  RecID: Integer;
  RecIDs: TArray<Integer>;
begin
  Result := TRecordList.Create(True);

  RecIDs := GetRecIDsByKey(aKey);

  for RecID in RecIDs do
    Result.Add(TRecord.Create(FDBEngine, RecID));
end;

function TLink.CheckGroupInChain(aRecGroupID, aCheckGroupID: integer): Boolean;
var
  Group: TGroup;
  CurrentGroupID: Integer;
begin
  Result := False;
  if aCheckGroupID = 0 then Exit(True);

  CurrentGroupID := aCheckGroupID;

  repeat
    if CurrentGroupID = aRecGroupID then Exit(True);

    Group := TGroup.Create(FDBEngine, CurrentGroupID);
    try
      CurrentGroupID := Group.ParentGroupID;
    finally
      Group.Free;
    end;

  until CurrentGroupID = 0;
end;

function TLinkRel.GetChildLinkID: Integer;
begin
  Result := FData.Items['CHILD_LINK_ID'];
end;

procedure TLinkRel.SetChildLinkID(aValue: Integer);
begin
  FData.AddOrSetValue('CHILD_LINK_ID', aValue);
end;

function TLink.GetChildLinkRels: TLinkRelList;
begin
  if not Assigned(FChildLinkRels) then
    FChildLinkRels := TLinkRelList.Create(Self, 'PARENT_LINK_ID', ID);

  Result := FChildLinkRels;
end;

function TLink.GetRecordsByKey(aKey: string; aResult: TObjectList<TRecord> = nil; aOrignLink: TLink = nil; aGroupID: Integer = 0): TObjectList<TRecord>;
var
  Rec: TRecord;
  ParentLink, ChildLink: TLink;
  ChildLinkRel: TLinkRel;
  OrignLink: TLink;
begin
  if aResult = nil then
    Result := TObjectList<TRecord>.Create(True)
  else
    Result := aResult;

  if aOrignLink = nil then
    OrignLink := Self
  else
    OrignLink := aOrignLink;

  for Rec in Records do
    if (Rec.Key = aKey) and (CheckGroupInChain(Rec.GroupID, aGroupID)) then
      begin
        Records.Extract(Rec);
        Result.Add(Rec);
      end;

  if (Result.Count = 0) and (aOrignLink <> nil) then
    if ID = aOrignLink.ParentRel.ParentLinkID then
      for ChildLinkRel in ChildLinkRels do
        begin
          ChildLink := TLink.Create(FDBEngine, ChildLinkRel.ChildLinkID);
          try
            if ChildLink.Level < aOrignLink.Level then
              for Rec in ChildLink.Records do
                if Rec.Key = aKey then
                  begin
                    ChildLink.Records.Extract(Rec);
                    Result.Add(Rec);
                  end;
          finally
            ChildLink.Free;
          end;
        end;

  if Result.Count = 0 then
    if ParentRel <> nil then
      begin
        ParentLink := TLink.Create(FDBEngine, ParentRel.ParentLinkID);
        try
          ParentLink.GetRecordsByKey(aKey, Result, OrignLink, Self.GroupID);
        finally
          ParentLink.Free;
        end;
      end;
end;

procedure TLink.SaveLists;
begin
  if Assigned(FRecords) then FRecords.SaveList(ID);
  if Assigned(FChildLinkRels) then FChildLinkRels.SaveList(ID);
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

function TLink.GetGroupID: Integer;
begin
  Result := FData.Items['GROUP_ID'];
end;

procedure TLink.SetGroupID(aValue: Integer);
begin
  FData.AddOrSetValue('GROUP_ID', aValue);
end;

function TLink.GetLevel: Integer;
begin
  Result := FData.Items['LEVEL'];
end;

procedure TLink.SetLevel(aValue: Integer);
begin
  FData.AddOrSetValue('LEVEL', aValue);
end;

class function TLink.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'LINKS';

  AddField(Result.FieldList, 'GROUP_ID', ftInteger);
  AddField(Result.FieldList, 'LEVEL', ftInteger);
  AddField(Result.FieldList, 'LINK', ftString);
  AddField(Result.FieldList, 'LINK_HASH', ftString);
  AddField(Result.FieldList, 'HANDLED', ftInteger);
  AddField(Result.FieldList, 'HANDLE_TIME', ftDateTime);

  AddOneRelation(Result.OneRelatedList, 'CHILD_LINK_ID', '', TLinkRel);
end;

end.
