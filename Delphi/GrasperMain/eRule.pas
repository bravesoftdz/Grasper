unit eRule;

interface

uses
  API_ORM,
  eCommon;

type
  TJobRule = class(TCommonEntity)
  private
    FNotes: string;
  public
    class function GetStructure: TSructure; override;
  published
    property Notes: string read FNotes write FNotes;
  end;

implementation

class function TJobRule.GetStructure: TSructure;
begin
  Result.TableName := 'JOB_RULES';
end;

end.
