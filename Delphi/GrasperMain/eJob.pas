unit eJob;

interface

uses
  API_ORM,
  eCommon,
  eLevel;

type
  PJob = ^TJob;
  TJob = class(TCommonEntity)
  private
    FCaption: string;
    FLevels: TJobLevelList;
    FZeroLink: string;
    function GetLevels: TJobLevelList;
  public
    class function GetStructure: TSructure; override;
    property Levels: TJobLevelList read GetLevels;
  published
    property Caption: string read FCaption write FCaption;
    property ZeroLink: string read FZeroLink write FZeroLink;
  end;

  TJobList = TCommonEntityList<TJob>;

implementation

uses Data.DB;

function TJob.GetLevels: TJobLevelList;
begin
  if not Assigned(FLevels) then
    FLevels := TJobLevelList.Create(Self);

  Result := FLevels;
end;

class function TJob.GetStructure: TSructure;
begin
  Result.TableName := 'JOBS';
end;

end.
