unit eJob;

interface

uses
  API_ORM,
  eCommon;

type
  TLevel = class(TCommonEntity)
  private
    FLevel: Integer;
    FJobID: Integer;
  public
    class function GetStructure: TSructure; override;
  published
    property Level: Integer read FLevel write FLevel;
    property JobID: Integer read FJobID write FJobID;
  end;

  TLevelList = TCommonEntityList<TLevel>;

  PJob = ^TJob;
  TJob = class(TCommonEntity)
  private
    FCaption: string;
    FZeroLink: string;
    FLevels: TLevelList;
    function GetLevels: TLevelList;
  public
    class function GetStructure: TSructure; override;
    property Levels: TLevelList read GetLevels;
  published
    property Caption: string read FCaption write FCaption;
    property ZeroLink: string read FZeroLink write FZeroLink;
  end;

  TJobList = TCommonEntityList<TJob>;

implementation

uses Data.DB;

function TJob.GetLevels: TLevelList;
begin
  if not Assigned(FLevels) then
    FLevels := TLevelList.Create(Self);

  Result := FLevels;
end;

class function TLevel.GetStructure: TSructure;
begin
  Result.TableName := 'LEVELS';

  AddForeignKey(Result.ForeignKeyArr, 'JOB_ID', TJob, 'ID');
end;

class function TJob.GetStructure: TSructure;
begin
  Result.TableName := 'JOBS';
end;

end.
