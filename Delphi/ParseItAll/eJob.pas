unit eJob;

interface

uses
  System.Generics.Collections,
  API_ORM,
  eExportField,
  eLevel,
  eRule,
  eRuleRecords;

type
  TJob = class(TEntityAbstract)
  // overrides
  private
    procedure SaveLists; override;
  public
    class function GetEntityStruct: TEntityStruct; override;
    procedure Assign(aSourceEntity: TEntityAbstract); override;
  ////////////////////
  private
    FExportFields: TExportFieldList;
    FLevels: TLevelList;
  // Getters Setters
    function GetLevels: TLevelList;
    function GetCaption: string;
    procedure SetCaption(aValue: string);
    function GetZeroLink: string;
    procedure SetZeroLink(aValue: string);

    function GetExportFields: TExportFieldList;
  public
    function CreateRuleRecFullList: TJobRecordList;

    function GetLevel(aLevel: integer): TJobLevel;
    function GetMaxLevel: TJobLevel;
    function GetMinLevel: TJobLevel;

    property Caption: string read GetCaption write SetCaption;
    property ExportFields: TExportFieldList read GetExportFields;
    property Levels: TLevelList read GetLevels;
    property ZeroLink: string read GetZeroLink write SetZeroLink;
  end;

  TJobList = TEntityList<TJob>;

  TJobState = record
    JobID: integer;
    StateID: integer;
  end;

implementation

uses
  Data.DB,
  API_ORM_Helper;

function TJob.GetExportFields: TExportFieldList;
begin
  if not Assigned(FExportFields) then
    FExportFields := TExportFieldList.Create(Self, 'JOB_ID', ID, 'ORDER_NUM');

  Result := FExportFields;
end;

function TJob.CreateRuleRecFullList: TJobRecordList;
var
  Level: TJobLevel;
  RuleRelList: TRuleRuleRelList;
  RuleRel: TRuleRuleRel;
begin
  RuleRelList := TRuleRuleRelList.Create(False);
  Result := TJobRecordList.Create(False);
  try
    for Level in Self.Levels do
      begin
        for RuleRel in Level.BodyRule.ChildRuleRels  do

          RuleRel.RecursionSearch<TRuleRuleRel>(
            RuleRelList,
            function(aEntity: TRuleRuleRel): TEntityList<TRuleRuleRel>
              begin
                Result := aEntity.ChildRule.ChildRuleRels;
              end,
            function(aEntity: TRuleRuleRel): Boolean
              begin
                if aEntity.ChildRule.Rec <> nil then
                  Result := True
                else
                  Result := False;
              end
          );

      end;

    for RuleRel in RuleRelList do
      Result.Add(RuleRel.ChildRule.Rec);
  finally
    RuleRelList.Free;
  end;
end;

procedure TJob.Assign(aSourceEntity: TEntityAbstract);
begin
  inherited;

  // Copy One To Many Relations
  if aSourceEntity is TJob then
    begin
      Levels.Assign(TJob(aSourceEntity).Levels);
      ExportFields.Assign(TJob(aSourceEntity).ExportFields);
    end;
end;

function TJob.GetMinLevel: TJobLevel;
var
  Level: TJobLevel;
begin
  if Levels.Count > 0 then
    begin
      Result := Levels[0];

      for Level in Levels do
        if Result.Level > Level.Level then Result := Level;
    end
  else
    Result := nil;
end;

function TJob.GetMaxLevel: TJobLevel;
var
  Level: TJobLevel;
begin
  if Levels.Count > 0 then
    begin
      Result := Levels[0];

      for Level in Levels do
        if Result.Level < Level.Level then Result := Level;
    end
  else
    Result := nil;
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
  if Assigned(FExportFields) then FExportFields.SaveList(ID);
end;

function TJob.GetLevels: TLevelList;
begin
  if not Assigned(FLevels) then
    FLevels := TLevelList.Create(Self, 'JOB_ID', ID, 'LEVEL');

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
