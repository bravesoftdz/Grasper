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
  //////////////////
  public
    property LevelID: integer read GetLevelID write SetLevelID;
    property Level: integer read GetLevel write SetLevel;
    property Link: string read GetLink write SetLink;
  end;

  TTestLinkList = TEntityList<TTestLink>;

implementation

uses
  Data.DB;

class function TTestLink.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'JOB_TEST_LINKS';

  AddField(Result.FieldList, 'LEVEL_ID', ftInteger);
  AddField(Result.FieldList, 'LEVEL', ftInteger);
  AddField(Result.FieldList, 'LINK', ftString);
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
