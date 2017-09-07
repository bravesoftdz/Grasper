unit eTestLink;

interface

uses
  API_ORM;

type
  TTestLink = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
  // Getters Setters
    function GetLevelID: integer;
    procedure SetLevelID(aValue: integer);
    function GetLevel: integer;
    procedure SetLevel(aValue: integer);
    function GetLink: string;
    procedure SetLink(aValue: string);
    function GetIsActual: Boolean;
    procedure SetIsActual(aValue: Boolean);
    function GetNum: integer;
    procedure SetNum(aValue: integer);
  //////////////////
  public
    property LevelID: integer read GetLevelID write SetLevelID;
    property Level: integer read GetLevel write SetLevel;
    property Num: Integer read GetNum write SetNum;
    property Link: string read GetLink write SetLink;
    property IsActual: Boolean read GetIsActual write SetIsActual;
  end;

  TTestLinkList = TEntityList<TTestLink>;

implementation

uses
  Data.DB;

function TTestLink.GetNum: integer;
begin
  Result := FData.Items['NUM'];
end;

procedure TTestLink.SetNum(aValue: integer);
begin
  FData.AddOrSetValue('NUM', aValue);
end;

function TTestLink.GetIsActual: Boolean;
begin
  Result := FData.Items['IS_ACTUAL'];
end;

procedure TTestLink.SetIsActual(aValue: Boolean);
begin
  FData.AddOrSetValue('IS_ACTUAL', aValue);
end;

class function TTestLink.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'JOB_TEST_LINKS';

  AddField(Result.FieldList, 'LEVEL_ID', ftInteger);
  AddField(Result.FieldList, 'LEVEL', ftInteger);
  AddField(Result.FieldList, 'NUM', ftInteger);
  AddField(Result.FieldList, 'LINK', ftString);
  AddField(Result.FieldList, 'IS_ACTUAL', ftBoolean);
end;

function TTestLink.GetLevelID: integer;
begin
  Result := FData.Items['LEVEL_ID'];
end;

procedure TTestLink.SetLevelID(aValue: integer);
begin
  FData.AddOrSetValue('LEVEL_ID', aValue);
end;

function TTestLink.GetLevel: integer;
begin
  Result := FData.Items['LEVEL'];
end;

procedure TTestLink.SetLevel(aValue: integer);
begin
  FData.AddOrSetValue('LEVEL', aValue);
end;

function TTestLink.GetLink: string;
begin
  Result := FData.Items['LINK'];
end;

procedure TTestLink.SetLink(aValue: string);
begin
  FData.AddOrSetValue('LINK', aValue);
end;

end.
