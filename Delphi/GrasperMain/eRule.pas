unit eRule;

interface

uses
  API_ORM,
  eCommon,
  eRuleLink;

type
  TJobRule = class(TCommonEntity)
  private
    FLink: TRuleLink;
    FNotes: string;
  public
    class function GetStructure: TSructure; override;
  published
    property Link: TRuleLink read FLink write FLink;
    property Notes: string read FNotes write FNotes;
  end;

implementation

class function TJobRule.GetStructure: TSructure;
begin
  Result.TableName := 'JOB_RULES';
end;

end.
