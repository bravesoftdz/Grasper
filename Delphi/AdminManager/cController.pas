unit cController;

interface

uses
  API_MVC,
  API_MVC_DB,
  API_DB_MySQL,
  cefvcl,
  cefLib,
  eEntities;

type
  TJSExtension = class
    class procedure databack(const data: string);
  end;

  TCustomRenderProcessHandler = class(TCefRenderProcessHandlerOwn)
  protected
    procedure OnWebKitInitialized; override;
  end;

  TController = class(TControllerDB)
  private
    procedure crmProcessMessageReceived(Sender: TObject;
            const browser: ICefBrowser; sourceProcess: TCefProcessId;
            const message: ICefProcessMessage; out Result: Boolean);
    function GetSelectedLevel: TJobLevel;
    function GetSelectedGroup: TJobGroup;
    function GetSelectedRule: TJobRule;
  protected
    procedure InitDB; override;
    procedure PerfomViewMessage(aMsg: string); override;
    procedure EventListener(aEventMsg: string); override;
  published
    procedure GetJobList;

    procedure EditJobRules;
    procedure StoreJobRules;

    procedure TreeNodeSelected;

    procedure CreateGroup;
    procedure DeleteGroup;

    procedure CreateLink;
    procedure DeleteLink;

    procedure CreateRecord;
    procedure DeleteRecord;

    procedure SelectHTMLNode;

    procedure CreateNodes(aNodesData: string);
  end;

  // FObjData Item Keys
  // Job
  // LevelList
  // Level

implementation

uses
  Vcl.Dialogs,
  System.SysUtils,
  System.JSON,
  API_Files,
  API_ORM,
  API_MVC_Bind,
  vMain,
  vLogin,
  vJob,
  vRules,
  mLogin,
  mJobs,
  mRules;

function TController.GetSelectedLevel: TJobLevel;
begin
  Result := FObjData.Items['Level'] as TJobLevel;
end;

function TController.GetSelectedGroup: TJobGroup;
begin
  Result := GetSelectedLevel.Groups.Items[ViewRules.GroupIndex];
end;

function TController.GetSelectedRule: TJobRule;
begin
  if ViewRules.RuleIndex <= GetSelectedGroup.Links.Count then
    Result := GetSelectedGroup.Links.Items[ViewRules.RuleIndex].Rule
  else
    Result := GetSelectedGroup.Records.Items[ViewRules.RuleIndex - GetSelectedGroup.Links.Count].Rule;
end;

procedure TController.CreateNodes(aNodesData: string);
var
  jsnNodes: TJSONArray;
  jsnValue: TJSONValue;
  jsnNode: TJSONObject;

  Rule: TJobRule;
begin
  jsnNodes:=TJSONObject.ParseJSONValue(aNodesData) as TJSONArray;
  Rule := GetSelectedRule;

  for jsnValue in jsnNodes do
    begin
      jsnNode:=jsnValue as TJSONObject;
    end;
end;

procedure TController.crmProcessMessageReceived(Sender: TObject;
        const browser: ICefBrowser; sourceProcess: TCefProcessId;
        const message: ICefProcessMessage; out Result: Boolean);
begin
  if message.Name = 'databack' then CreateNodes(message.ArgumentList.GetString(0));
end;

procedure TController.SelectHTMLNode;
var
  InjectJS: string;
begin
  InjectJS := TFilesEngine.GetTextFromFile(GetCurrentDir + '\JS\DOMSelector.js');
  ViewRules.chrmBrowser.Browser.MainFrame.ExecuteJavaScript(InjectJS, 'about:blank', 0);
end;

procedure TController.CreateRecord;
var
  Level: TJobLevel;
  Group: TJobGroup;
  JobRecord: TJobRecord;
begin
  Level := FObjData.Items['Level'] as TJobLevel;
  Group := Level.Groups[ViewRules.tvTree.Selected.Index];

  JobRecord := TJobRecord.Create(FDBEngine);
  Group.Records.Add(JobRecord);

  ViewRules.SetControlTree(Level.Groups);
end;

procedure TController.DeleteRecord;
var
  Level: TJobLevel;
  Group: TJobGroup;
begin
  Level := FObjData.Items['Level'] as TJobLevel;
  Group := Level.Groups[ViewRules.tvTree.Selected.Parent.Index];

  Group.Records.DeleteByIndex(ViewRules.tvTree.Selected.Index - Group.Links.Count);
  ViewRules.SetControlTree(Level.Groups);
  ViewRules.pnlEntityFields.ClearControls;
end;

procedure TController.DeleteLink;
var
  Level: TJobLevel;
  Group: TJobGroup;
begin
  Level := FObjData.Items['Level'] as TJobLevel;
  Group := Level.Groups[ViewRules.tvTree.Selected.Parent.Index];

  Group.Links.DeleteByIndex(ViewRules.tvTree.Selected.Index);
  ViewRules.SetControlTree(Level.Groups);
  ViewRules.pnlEntityFields.ClearControls;
end;

procedure TController.CreateLink;
var
  Level: TJobLevel;
  Group: TJobGroup;
  Link: TJobLink;
begin
  Level := FObjData.Items['Level'] as TJobLevel;
  Group := Level.Groups[ViewRules.tvTree.Selected.Index];

  Link := TJobLink.Create(FDBEngine);
  Group.Links.Add(Link);

  ViewRules.SetControlTree(Level.Groups);
end;

procedure TController.GetJobList;
var
  JobList: TJobList;
begin
  JobList := TJobList.Create(FDBEngine, [], []);
  try
    ViewMain.SetJobsGrid(JobList);
  finally
    FreeAndNil(JobList);
  end;
end;

procedure TController.DeleteGroup;
var
  Groups: TGroupList;
begin
  Groups := (FObjData.Items['Level'] as TJobLevel).Groups;
  Groups.DeleteByIndex(ViewRules.tvTree.Selected.Index);

  ViewRules.SetControlTree(Groups);
  ViewRules.pnlEntityFields.ClearControls;
end;

procedure TController.TreeNodeSelected;
var
  Entity: TEntityAbstract;
begin
  ViewRules.pnlXPath.Visible := False;

  with ViewRules do
    begin
      case tvTree.Selected.Level of
        0:  Entity := GetSelectedGroup;
        1:  begin
              if GetSelectedLink <> -1 then
                Entity := GetSelectedLink
              else
                Entity := GetSelectedRecord;

              ViewRules.pnlXPath.Visible := True;
            end;
      end;

      pnlEntityFields.ClearControls;
      pnlEntityFields.BuildControls(Entity);
    end;
end;

procedure TController.EditJobRules;
var
  Job: TJob;
  Levels: TEntityList<TJobLevel>;
  Level: TJobLevel;
begin
  Job := TJob.Create(FDBEngine, ViewMain.SelectedJobID);
  FObjData.AddOrSetValue('Job', Job);

  Levels := Job.Levels;
  if Levels.Count = 0 then
    begin
      Level := TJobLevel.Create(FDBEngine, 0);
      Level.Level := 1;
      Level.BaseLink := Job.ZeroLink;
      Levels.Add(Level);
    end;
  FObjData.AddOrSetValue('Level', Levels[0]);

  CallView(TViewRules);
  ViewRules.SetLevels(Levels);
  ViewRules.SetControlTree(Levels[0].Groups);
  ViewRules.chrmBrowser.OnProcessMessageReceived := crmProcessMessageReceived;
end;

procedure TController.StoreJobRules;
var
  Job: TJob;
begin
  Job := FObjData.Items['Job'] as TJob;
  Job.SaveAll;
  ViewRules.Close;
end;

procedure TController.CreateGroup;
var
  Level: TJobLevel;
  Group: TJobGroup;
begin
  Level := FObjData.Items['Level'] as TJobLevel;

  Group := TJobGroup.Create(FDBEngine, 0);
  Group.Notes := 'New Group';

  Level.Groups.Add(Group);
  ViewRules.SetControlTree(Level.Groups);
end;

procedure TController.EventListener(aEventMsg: string);
var
  Job: TJob;
  JobList: TJobList;
  i: Integer;
begin
  if aEventMsg = 'LoginDone' then
    begin
      ViewLogin.Close;
      ViewMain.statBar.Panels[0].Text := 'user: ' + FData.Items['user'];
      ViewMain.statBar.Panels[1].Text := 'ip: ' + FData.Items['ip'];
      GetJobList;
    end;

  if aEventMsg = 'GetJobDone' then
    begin
      CallView(TViewJob);
      Job := FObjData.Items['Job'] as TJob;
      ViewJob.CRUDPanel.BuildCRUD(Job);
      ViewJob.SetBrowserLinks;
    end;
end;

procedure TController.PerfomViewMessage(aMsg: string);
begin
  if aMsg = 'ViewRulesClosed' then
    begin
      FObjData.Items['Job'].Free;
      //FObjData.
    end;

  if aMsg = 'ShowViewLogin' then CallView(TViewLogin);
  if aMsg = 'PerfomLoggining' then
    begin
      FData.Add('login', ViewLogin.edtLogin.Text);
      FData.Add('password', ViewLogin.edtPassword.Text);
      CallModel(TModelLogin);
    end;

  if aMsg = 'CreateJob' then
    begin
      FData.AddOrSetValue('JobID', 0);
      CallModel(TModelJobs, 'GetJob');
    end;
  if aMsg = 'EditJob' then
    begin
      FData.AddOrSetValue('JobID', ViewMain.SelectedJobID);
      CallModel(TModelJobs, 'GetJob');
    end;
  if aMsg = 'StoreJob' then
    begin
      ViewJob.Close;
      ViewJob.CRUDPanel.UpdateEntity;
      ViewJob.CRUDPanel.Entity.SaveEntity;
      CallModel(TModelJobs, 'GetJobList');
    end;
end;

procedure TController.InitDB;
begin
  FConnectOnCreate := True;
  FConnectParams := Self.GetConnectParams('Settings\MySQL.ini');
  FDBEngineClass := TMySQLEngine;
end;

{ TCustomRenderProcessHandler }
procedure TCustomRenderProcessHandler.OnWebKitInitialized;
begin
  TCefRTTIExtension.Register('app', TJSExtension);
end;

{ TTestExtension }
class procedure TJSExtension.databack(const data: string);
var
  msg: ICefProcessMessage;
begin
  msg := TCefProcessMessageRef.New('databack');
  msg.ArgumentList.SetString(0, data);
  TCefv8ContextRef.Current.Browser.SendProcessMessage(PID_BROWSER, msg);
end;

initialization
  CefRenderProcessHandler := TCustomRenderProcessHandler.Create;

end.
