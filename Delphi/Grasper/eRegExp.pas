unit eRegExp;

interface

uses
  API_ORM;

type
  TJobRegExp = class(TEntityAbstract)
  // overrides
  public
    class function GetEntityStruct: TEntityStruct; override;
  ////////////////////
  private
  // Getters Setters
    function GetJobRuleID: integer;
    procedure SetJobRuleID(aValue: integer);
    function GetRegExpTypeID: integer;
    procedure SetRegExpTypeID(aValue: integer);
    function GetRegExp: string;
    procedure SetRegExp(aValue: string);
    function GetReplaceValue: string;
    procedure SetReplaceValue(aValue: string);
    function GetNotes: string;
    procedure SetNotes(aValue: string);
  //////////////////
  public
    property JobRuleID: Integer read GetJobRuleID write SetJobRuleID;
    property RegExpTypeID: Integer read GetRegExpTypeID write SetRegExpTypeID;
    property RegExp: string read GetRegExp write SetRegExp;
    property ReplaceValue: string read GetReplaceValue write SetReplaceValue;
    property Notes: string read GetNotes write SetNotes;
  end;

  TJobRegExpList = TEntityList<TJobRegExp>;

implementation

uses
  Data.DB;

function TJobRegExp.GetNotes: string;
begin
  Result := FData.Items['NOTES'];
end;

procedure TJobRegExp.SetNotes(aValue: string);
begin
  FData.AddOrSetValue('NOTES', aValue);
end;

function TJobRegExp.GetReplaceValue: string;
begin
  Result := FData.Items['REPLACE_VALUE'];
end;

procedure TJobRegExp.SetReplaceValue(aValue: string);
begin
  FData.AddOrSetValue('REPLACE_VALUE', aValue);
end;

function TJobRegExp.GetRegExp: string;
begin
  Result := FData.Items['REGEXP'];
end;

procedure TJobRegExp.SetRegExp(aValue: string);
begin
  FData.AddOrSetValue('REGEXP', aValue);
end;

function TJobRegExp.GetRegExpTypeID: integer;
begin
  Result := FData.Items['REGEXP_TYPE_ID'];
end;

procedure TJobRegExp.SetRegExpTypeID(aValue: integer);
begin
  FData.AddOrSetValue('REGEXP_TYPE_ID', aValue);
end;

function TJobRegExp.GetJobRuleID: integer;
begin
  Result := FData.Items['JOB_RULE_ID'];
end;

procedure TJobRegExp.SetJobRuleID(aValue: integer);
begin
  FData.AddOrSetValue('JOB_RULE_ID', aValue);
end;

class function TJobRegExp.GetEntityStruct: TEntityStruct;
begin
  Result.TableName := 'JOB_REGEXPS';

  AddField(Result.FieldList, 'JOB_RULE_ID', ftInteger);
  AddField(Result.FieldList, 'REGEXP_TYPE_ID', ftInteger);
  AddField(Result.FieldList, 'REGEXP', ftString);
  AddField(Result.FieldList, 'REPLACE_VALUE', ftString);
  AddField(Result.FieldList, 'NOTES', ftString);
end;

end.
