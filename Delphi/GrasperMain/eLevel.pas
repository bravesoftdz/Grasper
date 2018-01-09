unit eLevel;

interface

uses
  API_ORM,
  eCommon;

type
  TJobLevel = class(TCommonEntity)
  private
    FBaseLink: string;
    FJobID: Integer;
    FLevel: Integer;
  public
    class function GetStructure: TSructure; override;
  published
    property BaseLink: string read FBaseLink write FBaseLink;
    property JobID: Integer read FJobID write FJobID;
    property Level: Integer read FLevel write FLevel;
  end;

  TJobLevelList = TCommonEntityList<TJobLevel>;

implementation

uses
  eJob;

class function TJobLevel.GetStructure: TSructure;
begin
  Result.TableName := 'JOB_LEVELS';

  AddForeignKey(Result.ForeignKeyArr, 'JOB_ID', TJob, 'ID');
end;

end.
