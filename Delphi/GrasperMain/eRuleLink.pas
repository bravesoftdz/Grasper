unit eRuleLink;

interface

uses
  API_ORM,
  eCommon;

type
  TRuleLink = class(TCommonEntity)
  private
    FJobRuleID: Integer;
    FLevel: Integer;
  public
    class function GetStructure: TSructure; override;
  published
    property JobRuleID: Integer read FJobRuleID write FJobRuleID;
    property Level: Integer read FLevel write FLevel;
  end;

implementation

uses
  eRule;

class function TRuleLink.GetStructure: TSructure;
begin
  Result.TableName := 'JOB_RULE_LINKS';

  AddForeignKey(Result.ForeignKeyArr, 'JOB_RULE_ID', TJobRule, 'ID');
end;

end.
