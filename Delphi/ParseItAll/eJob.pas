unit eJob;

interface

uses
  API_ORM,
  eLevel;

type
  TJob = class(TEntityAbstract)
  // overrides
  private
    procedure SaveLists; override;
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
    FLevels: TLevelList;
  // Getters Setters
    function GetLevels: TLevelList;
    function GetCaption: string;
    procedure SetCaption(aValue: string);
    function GetZeroLink: string;
    procedure SetZeroLink(aValue: string);
  //////////////////
  public
    function GetLevel(aLevel: integer): TJobLevel;
    function GetMinLevel: Integer;
    property Caption: string read GetCaption write SetCaption;
    property ZeroLink: string read GetZeroLink write SetZeroLink;
    property Levels: TLevelList read GetLevels;
  end;

  TJobList = TEntityList<TJob>;

implementation

uses
  Data.DB;

function TJob.GetMinLevel: Integer;
var
  Level: TJobLevel;
begin
  if Levels.Count > 0 then
    begin
      Result := MaxInt;

      for Level in Levels do
        if Level.Level < Result then Result := Level.Level;
    end
  else
    Result := -1
end;

function TJob.GetLevel(aLevel: integer): TJobLevel;
var
  JobLevel: TJobLevel;
begin
  for JobLevel in Levels do
    if JobLevel.Level = aLevel then
      Exit(JobLevel);
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
  AddField(Result.FieldList, 'CAPTION', ftString);
  AddField(Result.FieldList, 'ZERO_LINK', ftString);
end;

end.
