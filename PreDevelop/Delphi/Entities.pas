unit Entities;

interface

uses
   System.Generics.Collections
  ,API_DBases;

type
  TJobNode = record
    ID: integer;
    Tag: string;
    Index: integer;
    TagID: string;
    ClassName: string;
    Name: string;
  end;

  TJobNodes = TArray<TJobNode>;

  TJobRegExp = record
    RegExp: string;
    TypeRefID: Integer;
  end;

  TJobRegExps = TArray<TJobRegExp>;

  TJobRule = class abstract (TObject)
  private
    FID: Integer;
    FDescription: string;
    FNodes: TJobNodes;
    FRegExps: TJobRegExps;
    FCriticalType: Integer;
    FContainerOffset: Integer;
    FCustomJSProcName: string;
  public
    constructor Create(aRuleID: integer; aMySQLEngine: TMySQLEngine); virtual;
    function GetContainerInsideNodes: TJobNodes;
    property ID: Integer read FID;
    property Description: string read FDescription;
    property Nodes: TJobNodes read FNodes;
    property RegExps: TJobRegExps read FRegExps;
    property CriticalType: Integer read FCriticalType;
    property ContainerOffset: Integer read FContainerOffset;
    property CustomJSProcName: string read FCustomJSProcName;
  end;

  TJobLinksRule = class(TJobRule)
  private
    FLevel: Integer;
  public
    constructor Create(aRuleID: integer; aMySQLEngine: TMySQLEngine); override;
    property Level: Integer read FLevel;
  end;

  TJobLinksRules = TObjectList<TJobLinksRule>;

  TJobRecordsRule = class(TJobRule)
  private
    FKey: string;
    FTypeRefID: integer;
  public
    constructor Create(aRuleID: integer; aMySQLEngine: TMySQLEngine); override;
    property Key: string read FKey;
    property TypeRefID: Integer read FTypeRefID;
  end;

  TJobRecordsRules = TObjectList<TJobRecordsRule>;

  TJobRulesGroup = record
    ID: Integer;
    JobLinksRules: TJobLinksRules;
    JobRecordsRules: TJobRecordsRules;
    function GetContainerNodes: TJobNodes;
  end;

  TJobRulesGroups = TArray<TJobRulesGroup>;

  TJobLevel = record
    Level: Integer;
    JobRulesGroups: TJobRulesGroups
  end;

  TJobLevels = TArray<TJobLevel>;

  TJob = class
    FID: Integer;
    FZeroLink: string;
    FLevels: TJobLevels;
  public
    constructor Create(aJobID: integer; aMySQLEngine: TMySQLEngine);
    function GetRulesGroupsByLevel(aLevel: integer): TJobRulesGroups;
    property ID: Integer read FID;
    property ZeroLink: string read FZeroLink;
    property Levels: TJobLevels read FLevels;
  end;

  TCurrLink = record
    ID: Integer;
    Link: string;
    Level: Integer;
  end;

implementation

uses
   FireDAC.Comp.Client
  ,API_Parse;

function TJobRule.GetContainerInsideNodes: TJobNodes;
begin
  Result:=Copy(FNodes, Length(FNodes)-FContainerOffset, Length(FNodes));
end;

function TJobRulesGroup.GetContainerNodes: TJobNodes;
var
  i: integer;
begin
  Result:=[];
  if JobLinksRules.Count>0 then
    for i := 0 to Length(JobLinksRules[0].Nodes)-1-JobLinksRules[0].ContainerOffset do
      Result:=Result+[JobLinksRules[0].Nodes[i]];

  if (Length(Result)=0) and (JobRecordsRules.Count>0) then
    for i := 0 to Length(JobRecordsRules[0].Nodes)-1-JobRecordsRules[0].ContainerOffset do
      Result:=Result+[JobRecordsRules[0].Nodes[i]];
end;

constructor TJobRecordsRule.Create(aRuleID: integer; aMySQLEngine: TMySQLEngine);
var
  dsRecord: TFDQuery;
begin
  inherited;

  dsRecord:=TFDQuery.Create(nil);
  try
    dsRecord.SQL.Text:='select * from job_rule_records where job_rule_id=:JobRuleID';
    dsRecord.ParamByName('JobRuleID').AsInteger:=aRuleID;
    aMySQLEngine.OpenQuery(dsRecord);
    FKey:=dsRecord.FieldByName('key').AsString;
    FTypeRefID:=dsRecord.FieldByName('type_refid').AsInteger;
  finally
    dsRecord.Free;
  end;
end;

constructor TJobLinksRule.Create(aRuleID: integer; aMySQLEngine: TMySQLEngine);
var
  dsLink: TFDQuery;
begin
  inherited;

  dsLink:=TFDQuery.Create(nil);
  try
    dsLink.SQL.Text:='select * from job_rule_links where job_rule_id=:JobRuleID';
    dsLink.ParamByName('JobRuleID').AsInteger:=aRuleID;
    aMySQLEngine.OpenQuery(dsLink);
    FLevel:=dsLink.FieldByName('level').AsInteger;
  finally
    dsLink.Free;
  end;
end;

constructor TJobRule.Create(aRuleID: integer; aMySQLEngine: TMySQLEngine);
var
  dsRule, dsNodes, dsRegExps: TFDQuery;
  Node: TJobNode;
  RegExp: TJobRegExp;
  sql: string;
begin
  dsRule:=TFDQuery.Create(nil);
  dsNodes:=TFDQuery.Create(nil);
  dsRegExps:=TFDQuery.Create(nil);
  try
    sql:='select *';
    sql:=sql+' from job_rules jr';
    sql:=sql+' left join job_custom_procs jcp on jcp.job_rule_id=jr.id and jcp.script_lang_refid=1';
    sql:=sql+' where jr.id=:ID';
    dsRule.SQL.Text:=sql;
    dsRule.ParamByName('ID').AsInteger:=aRuleID;
    aMySQLEngine.OpenQuery(dsRule);
    FID:=dsRule.FieldByName('Id').AsInteger;
    FDescription:=dsRule.FieldByName('description').AsString;
    FCriticalType:=dsRule.FieldByName('critical_type').AsInteger;
    FContainerOffset:=dsRule.FieldByName('container_offset').AsInteger;
    FCustomJSProcName:=dsRule.FieldByName('custom_proc_name').AsString;

    FNodes:=[];
    dsNodes.SQL.Text:='select * from job_nodes where job_rule_id=:JobRuleID order by id';
    dsNodes.ParamByName('JobRuleID').AsInteger:=aRuleID;
    aMySQLEngine.OpenQuery(dsNodes);
    while not dsNodes.EOF do
      begin
        Node.ID:=dsNodes.FieldByName('Id').AsInteger;
        Node.Tag:=dsNodes.FieldByName('tag').AsString;
        Node.Index:=dsNodes.FieldByName('index').AsInteger;
        Node.TagID:=dsNodes.FieldByName('tag_id').AsString;
        Node.ClassName:=TParseTools.GetNormalizeString(dsNodes.FieldByName('class').AsString);
        Node.Name:=dsNodes.FieldByName('name').AsString;

        FNodes := FNodes + [Node];
        dsNodes.Next;
      end;

    FRegExps:=[];
    dsRegExps.SQL.Text:='select * from job_regexp where job_rule_id=:JobRuleID order by id';
    dsRegExps.ParamByName('JobRuleID').AsInteger:=aRuleID;
    aMySQLEngine.OpenQuery(dsRegExps);
    while not dsRegExps.EOF do
      begin
        RegExp.RegExp:=dsRegExps.FieldByName('regexp').AsString;
        RegExp.TypeRefID:=dsRegExps.FieldByName('type_refid').AsInteger;

        FRegExps := FRegExps + [RegExp];
        dsRegExps.Next;
      end;
  finally
    dsRule.Free;
    dsNodes.Free;
    dsRegExps.Free;
  end;
end;

function TJob.GetRulesGroupsByLevel(aLevel: integer): TJobRulesGroups;
var
  JobLevel: TJobLevel;
begin
  Result:=[];
  for JobLevel in FLevels do
    if JobLevel.Level=aLevel then
      begin
        Result:=JobLevel.JobRulesGroups;
        Break;
      end;
end;

constructor TJob.Create(aJobID: Integer; aMySQLEngine: TMySQLEngine);
var
  dsJob, dsLevels, dsRules, dsGroups: TFDQuery;
  JobLevel: TJobLevel;
  JobRulesGroup: TJobRulesGroup;
  JobRulesGroups: TJobRulesGroups;
  JobLinksRule: TJobLinksRule;
  JobRecordsRule: TJobRecordsRule;
  sql: string;
begin
  FId:=aJobID;

  dsJob:=TFDQuery.Create(nil);
  dsLevels:=TFDQuery.Create(nil);
  dsRules:=TFDQuery.Create(nil);
  dsGroups:=TFDQuery.Create(nil);
  try
    dsJob.SQL.Text:='select * from jobs where id=:JobID';
    dsJob.ParamByName('JobID').AsInteger:=aJobID;
    aMySQLEngine.OpenQuery(dsJob);
    FZeroLink:=dsJob.FieldByName('zero_link').AsString;

    dsLevels.Close;
    dsLevels.SQL.Text:='select * from job_levels where job_id=:JobID order by level';
    dsLevels.ParamByName('JobID').AsInteger:=aJobID;
    aMySQLEngine.OpenQuery(dsLevels);
    Self.FLevels:=[];
    while not dsLevels.EOF do
      begin
        JobLevel.Level:=dsLevels.FieldByName('level').AsInteger;
        JobLevel.JobRulesGroups:=[];

        sql:='select * from job_groups where job_level_id=:JobLevel order by id';
        dsGroups.Close;
        dsGroups.SQL.Text:=sql;
        dsGroups.ParamByName('JobLevel').AsInteger:=dsLevels.FieldByName('Id').AsInteger;
        aMySQLEngine.OpenQuery(dsGroups);
        while not dsGroups.EOF do
          begin
            JobRulesGroup.ID:=dsGroups.FieldByName('Id').AsInteger;
            JobRulesGroup.JobLinksRules:=TJobLinksRules.Create;
            JobRulesGroup.JobRecordsRules:=TJobRecordsRules.Create;

            sql:='select j.id, jl.id as jlid, jr.id as jrid from job_rules j';
            sql:=sql+' left join job_rule_links jl on jl.job_rule_id=j.id';
            sql:=sql+' left join job_rule_records jr on jr.job_rule_id=j.id';
            sql:=sql+' where group_id=:GroupID order by j.id';
            dsRules.Close;
            dsRules.SQL.Text:=sql;
            dsRules.ParamByName('GroupID').AsInteger:=dsGroups.FieldByName('Id').AsInteger;
            aMySQLEngine.OpenQuery(dsRules);
            while not dsRules.EOF do
              begin
                if not dsRules.FieldByName('jlid').IsNull then
                  begin
                    JobLinksRule:=TJobLinksRule.Create(dsRules.FieldByName('Id').AsInteger, aMySQLEngine);
                    JobRulesGroup.JobLinksRules.Add(JobLinksRule);
                  end;

                if not dsRules.FieldByName('jrid').IsNull then
                  begin
                    JobRecordsRule:=TJobRecordsRule.Create(dsRules.FieldByName('Id').AsInteger, aMySQLEngine);
                    JobRulesGroup.JobRecordsRules.Add(JobRecordsRule);
                  end;

                dsRules.Next;
              end;

            JobLevel.JobRulesGroups:=JobLevel.JobRulesGroups+[JobRulesGroup];
            dsGroups.Next;
          end;

        Self.FLevels:=Self.FLevels + [JobLevel];
        dsLevels.Next;
      end;
  finally
    dsJob.Free;
    dsLevels.Free;
    dsRules.Free;
    dsGroups.Free;
  end;

end;

end.
