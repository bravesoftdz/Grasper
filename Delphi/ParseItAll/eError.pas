unit eError;

interface

uses
  API_ORM;

type
  TError = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
  // Getters Setters
    function GetErrorTime: TDateTime;
    procedure SetErrorTime(aValue: TDateTime);
    function GetLinkID: Integer;
    procedure SetLinkID(aValue: Integer);
    function GetErrorTypeID: Integer;
    procedure SetErrorTypeID(aValue: Integer);
    function GetText: String;
    procedure SetText(aValue: String);
  ////////////////////
  public
    property ErrorTime: TDateTime read GetErrorTime write SetErrorTime;
    property LinkID: Integer read GetLinkID write SetLinkID;
    property ErrorTypeID: Integer read GetErrorTypeID write SetErrorTypeID;
    property Text: String read GetText write SetText;
  end;

implementation

uses
  Data.DB;

function TError.GetText: String;
begin
  Result := FData.Items['TEXT'];
end;

procedure TError.SetText(aValue: String);
begin
  FData.AddOrSetValue('TEXT', aValue);
end;

function TError.GetErrorTypeID: Integer;
begin
  Result := FData.Items['ERROR_TYPE_ID'];
end;

procedure TError.SetErrorTypeID(aValue: Integer);
begin
  FData.AddOrSetValue('ERROR_TYPE_ID', aValue);
end;

function TError.GetLinkID: Integer;
begin
  Result := FData.Items['LINK_ID'];
end;

procedure TError.SetLinkID(aValue: Integer);
begin
  FData.AddOrSetValue('LINK_ID', aValue);
end;

function TError.GetErrorTime: TDateTime;
begin
  Result := FData.Items['ERROR_TIME'];
end;

procedure TError.SetErrorTime(aValue: TDateTime);
begin
  FData.AddOrSetValue('ERROR_TIME', aValue);
end;

class function TError.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'ERRORS';

  AddField(Result.FieldList, 'ERROR_TIME', ftDateTime);
  AddField(Result.FieldList, 'LINK_ID', ftInteger);
  AddField(Result.FieldList, 'ERROR_TYPE_ID', ftInteger);
  AddField(Result.FieldList, 'TEXT', ftString);
end;

end.
