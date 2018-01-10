unit eLevel;

interface

uses
  API_ORM,
  eCommon,
  eRule;

type
  TJobLevel = class(TCommonEntity)
  private
    FBaseLink: string;
    FBodyRule: TJobRule;
    FBodyRuleID: Integer;
    FJobID: Integer;
    FLevel: Integer;
  public
    class function GetStructure: TSructure; override;
  published
    property BaseLink: string read FBaseLink write FBaseLink;
    property BodyRule: TJobRule read FBodyRule write FBodyRule;
    property BodyRuleID: Integer read FBodyRuleID write FBodyRuleID;
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
  AddForeignKey(Result.ForeignKeyArr, 'BODY_RULE_ID', TJobRule, 'ID');
end;

end.
