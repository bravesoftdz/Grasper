unit Model;

interface

uses
   System.SysUtils
  ,System.JSON
  ,System.Generics.Collections
  ,Vcl.Forms
  ,cefvcl
  ,CefLib
  ,API_DBases
  ,Entities
  ,DBService
  ,CustomHandles
  ,main;

type
  TJSExtension = class
    class procedure databack(const data: string);
  end;

  TCustomRenderProcessHandler = class(TCefRenderProcessHandlerOwn)
  protected
    procedure OnWebKitInitialized; override;
  end;

  TCustomJS = record
    JSFile: string;
    JSFunc: string;
  end;

  TPIAModel = class
  private
    FMySQLEngine: TMySQLEngine;
    FDBService: TPIADBService;
    FChromium: TChromium;
    FForm: TForm;
    FJob: TJob;
    FCurrLink: TCurrLink;
    FjsScript: string;
    procedure ChromiumInit;
    procedure ProcessNextLink;
    procedure ChromiumLoadEnd(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
    procedure ProcessRules(aFrame: ICefFrame);
    procedure crmProcessMessageReceived(Sender: TObject;
                const browser: ICefBrowser; sourceProcess: TCefProcessId;
                const message: ICefProcessMessage; out Result: Boolean);
    procedure InsertReceivedData(aData: string);
    procedure OnNoResult(aMessage: string; aRuleID, aCriticalType: Integer);
    procedure CheckCustomJS(var aCustomJS: TCustomJS; aCustomProcName: string);
    function GetCustomHandleProc(aJobRuleID: integer; aProcDictionary: TObjectDictionary<Integer, TCustomProc>): TCustomProc;
    function GetInjectJSForRulesGroup(aJobRulesGroup: TJobRulesGroup; aIsLast: Boolean): string;
    function EncodeNodesToJSON(aNodes: TJobNodes): TJSONArray;
    function EncodeRegExpsToJSON(aRegExps: TJobRegExps): TJSONArray;
    function GetCustomJSFileContent(aCustomJSFileName: string): string;
  public
    constructor Create(aJobID: integer);
    procedure StartJob;
    procedure Test(aForm: TMainForm; aLevel, aGroupID: integer);
  end;

implementation

uses
   Vcl.Controls
  ,Windows
  ,API_Parse
  ,API_Files;

function TPIAModel.GetCustomJSFileContent(aCustomJSFileName: string): string;
begin
  if aCustomJSFileName='' then Exit('');
  Result:=TFilesEngine.GetTextFromFile('D:\Git\Projects-Dev\ParseItAll\Web\js\custom\'+aCustomJSFileName+'.js');
  Result:=Result+#10#13;
end;

procedure TPIAModel.CheckCustomJS(var aCustomJS: TCustomJS; aCustomProcName: string);
var
  ResultArray: TArray<string>;
begin
  aCustomJS.JSFunc:='';
  ResultArray:=TParseTools.Explode(aCustomProcName, '.');
  if Length(ResultArray)=2 then
    begin
      aCustomJS.JSFile:=ResultArray[0];
      aCustomJS.JSFunc:=ResultArray[1];
    end;
end;

function TPIAModel.GetCustomHandleProc(aJobRuleID: integer; aProcDictionary: TObjectDictionary<Integer, TCustomProc>): TCustomProc;
var
  CustomHandleProcName: string;
  h:HWND;
begin
  if aProcDictionary.ContainsKey(aJobRuleID) then
    Result:=aProcDictionary.Items[aJobRuleID]
  else
    begin
      CustomHandleProcName:=FDBService.GetCustomHandleProcName(aJobRuleID);
      h:=GetModuleHandle(nil);
      @Result:=GetProcAddress(h, PChar(CustomHandleProcName));
      if @Result<>nil then
          aProcDictionary.Add(aJobRuleID, Result);
    end;
end;

procedure TPIAModel.Test(aForm: TMainForm; aLevel, aGroupID: integer);
var
  JobGroups: TJobRulesGroups;
  JobRulesGroup: TJobRulesGroup;
  InjectJS: string;
begin
  JobGroups:=FJob.GetRulesGroupsByLevel(aLevel);

  for JobRulesGroup in JobGroups do
    begin
      InjectJS:=GetInjectJSForRulesGroup(JobRulesGroup, false);
      TFilesEngine.SaveTextToFile('InjectJS.js', InjectJS); // DEBUG
      if JobRulesGroup.ID = aGroupID then Break;
    end;

  aForm.Show;
  aForm.crm.Load(FDBService.GetTestLink);
end;

function TPIAModel.EncodeRegExpsToJSON(aRegExps: TJobRegExps): TJSONArray;
var
  RegExp: TJobRegExp;
  jsnRegExp: TJSONObject;
begin
  Result:=TJSONArray.Create;
  for RegExp in aRegExps do
    begin
      jsnRegExp:=TJSONObject.Create;
      jsnRegExp.AddPair('regexp', RegExp.RegExp);
      jsnRegExp.AddPair('type', TJSONNumber.Create(RegExp.TypeRefID));

      Result.AddElement(jsnRegExp);
    end;
end;

function TPIAModel.EncodeNodesToJSON(aNodes: TJobNodes): TJSONArray;
var
  jsnNode: TJSONObject;
  Node: TJobNode;
begin
  Result:=TJSONArray.Create;
  for Node in aNodes do
    begin
      jsnNode:=TJSONObject.Create;
      jsnNode.AddPair('ID', TJSONNumber.Create(Node.ID));
      jsnNode.AddPair('tag', Node.Tag);
      jsnNode.AddPair('index', TJSONNumber.Create(Node.Index));
      jsnNode.AddPair('tagID', Node.TagID);
      jsnNode.AddPair('className', Node.ClassName);
      jsnNode.AddPair('name', Node.Name);
      Result.AddElement(jsnNode);
    end;
end;

procedure TPIAModel.InsertReceivedData(aData: string);
var
  jsnData: TJSONObject;
  jsnDataArray: TJSONArray;
  jsnObjArray: TJSONArray;
  jsnGroup, jsnValue: TJSONValue;
  jsnObj: TJSONObject;

  CustomHandleProc: TCustomProc;
  CustomHandleProcDictionary: TObjectDictionary<Integer, TCustomProc>;
  Link, Key, Text: string;
  Level, i: Integer;
  isLast: Boolean;
begin
  try
    jsnData:=TJSONObject.ParseJSONValue(aData) as TJSONObject;
    jsnDataArray:=jsnData.GetValue('result') as TJSONArray;

    CustomHandleProcDictionary:=TObjectDictionary<Integer, TCustomProc>.Create;

    i:=0;
    for jsnGroup in jsnDataArray do
      begin
        Inc(i);
        jsnObjArray:=jsnGroup as TJSONArray;
        for jsnValue in jsnObjArray do
          begin
            try
              jsnObj:=jsnValue as TJSONObject;

              if jsnObj.GetValue('noresult')<>nil then
                begin
                  OnNoResult(jsnObj.GetValue('noresult').Value, (jsnObj.GetValue('id') as TJSONNumber).asint, (jsnObj.GetValue('critical') as TJSONNumber).asint);
                  Continue;
                end;

              CustomHandleProc:=GetCustomHandleProc((jsnObj.GetValue('id') as TJSONNumber).AsInt, CustomHandleProcDictionary);

              if jsnObj.GetValue('href')<>nil then
                begin
                  Level:=(jsnObj.GetValue('level') as TJSONNumber).AsInt;
                  Link:=jsnObj.GetValue('href').Value;
                  if Assigned(CustomHandleProc) then Link:=CustomHandleProc(Link);
                  FDBService.AddLink(Link, FCurrLink.ID, Level, i);
                end;

              if jsnObj.GetValue('key')<>nil then
                begin
                  Key:=jsnObj.GetValue('key').Value;
                  Text:=jsnObj.GetValue('value').Value;
                  if Assigned(CustomHandleProc) then Text:=CustomHandleProc(Text);
                  FDBService.AddRecord(FCurrLink.Id, i, Key, Text);
                end;
            except
              // ловим ошибки каждой группы
            end;
          end;
      end;

    if jsnData.GetValue('islast')<>nil then isLast:=True
    else isLast:=False;

    if isLast then ProcessNextLink;
  finally
    jsnData.Free;
    CustomHandleProcDictionary.Free;
  end;
end;

procedure TPIAModel.crmProcessMessageReceived(Sender: TObject;
  const browser: ICefBrowser; sourceProcess: TCefProcessId;
  const message: ICefProcessMessage; out Result: Boolean);
begin
  if message.Name = 'databack' then
      InsertReceivedData(message.ArgumentList.GetString(0));
end;

function TPIAModel.GetInjectJSForRulesGroup(aJobRulesGroup: TJobRulesGroup; aIsLast: Boolean): string;
var
  JobLinksRule: TJobLinksRule;
  JobRecordsRule: TJobRecordsRule;
  jsnRuleGroup: TJSONObject;
  jsnRules: TJSONArray;
  jsnRule: TJSONObject;
  CustomJS: TCustomJS;
begin
  jsnRuleGroup:=TJSONObject.Create;
  jsnRules:=TJSONArray.Create;
  try
    jsnRuleGroup.AddPair('nodes', EncodeNodesToJSON(aJobRulesGroup.GetContainerNodes));

    for JobLinksRule in aJobRulesGroup.JobLinksRules  do
      begin
        CheckCustomJS(CustomJS, JobLinksRule.CustomJSProcName);

        jsnRule:=TJSONObject.Create;
        jsnRule.AddPair('id', TJSONNumber.Create(JobLinksRule.ID));
        jsnRule.AddPair('level', TJSONNumber.Create(JobLinksRule.Level));
        jsnRule.AddPair('nodes', EncodeNodesToJSON(JobLinksRule.GetContainerInsideNodes));
        jsnRule.AddPair('regexps', EncodeRegExpsToJSON(JobLinksRule.RegExps));
        jsnRule.AddPair('custom_func', CustomJS.JSFunc);
        jsnRule.AddPair('critical', TJSONNumber.Create(JobLinksRule.CriticalType));
        jsnRules.AddElement(jsnRule);
      end;

    for JobRecordsRule in aJobRulesGroup.JobRecordsRules do
      begin
        CheckCustomJS(CustomJS, JobRecordsRule.CustomJSProcName);

        jsnRule:=TJSONObject.Create;
        jsnRule.AddPair('id', TJSONNumber.Create(JobRecordsRule.ID));
        jsnRule.AddPair('key', JobRecordsRule.Key);
        jsnRule.AddPair('typeid', TJSONNumber.Create(JobRecordsRule.TypeRefID));
        jsnRule.AddPair('nodes', EncodeNodesToJSON(JobRecordsRule.GetContainerInsideNodes));
        jsnRule.AddPair('regexps', EncodeRegExpsToJSON(JobRecordsRule.RegExps));
        jsnRule.AddPair('custom_func', CustomJS.JSFunc);
        jsnRule.AddPair('critical', TJSONNumber.Create(JobRecordsRule.CriticalType));
        jsnRules.AddElement(jsnRule)
      end;

    jsnRuleGroup.AddPair('rules', jsnRules);
    if aIsLast then jsnRuleGroup.AddPair('islast', TJSONNumber.Create(1));

    Result:=GetCustomJSFileContent(CustomJS.JSFile);
    Result:=Result+'var group =';
    Result:=Result+jsnRuleGroup.ToJSON;
    Result:=Result+';'#10#13;
    Result:=Result+FjsScript;
  finally
    jsnRuleGroup.Free;
  end;
end;

procedure TPIAModel.ProcessRules(aFrame: ICefFrame);
var
  JobRulesGroups: TJobRulesGroups;
  JobRulesGroup: TJobRulesGroup;
  InjectJS: string;
  i: Integer;
  isLastGroup: Boolean;
begin
  isLastGroup:=False;
  i:=0;

  JobRulesGroups:=FJob.GetRulesGroupsByLevel(FCurrLink.Level);
  for JobRulesGroup in JobRulesGroups do
    begin
      if i=Length(JobRulesGroups)-1 then isLastGroup:=True;
      InjectJS:=GetInjectJSForRulesGroup(JobRulesGroup, isLastGroup);
      TFilesEngine.SaveTextToFile('InjectJS.js', InjectJS); // DEBUG
      FChromium.Browser.MainFrame.ExecuteJavaScript(InjectJS, 'about:blank', 0);
      Inc(i);
    end;
end;

procedure TPIAModel.ChromiumLoadEnd(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
begin
  if FChromium.Browser<>nil then
    if frame.Url = FCurrLink.Link then ProcessRules(frame);
end;

procedure TPIAModel.OnNoResult(aMessage: string; aRuleID, aCriticalType: Integer);
var
  msg: string;
begin
  if aCriticalType>0 then
    FDBService.AddJobMessage(FCurrLink.ID, aMessage, aRuleID, aCriticalType);

  case aCriticalType of
    1: begin
         msg:=Format('No Result on LinkID=%d, JobRuleID=%d. Critical Error. Thread Stopped.', [FCurrLink.ID, aRuleID]);
         raise Exception.Create('No Result on LinkID=%d, JobRuleID=%d.'+' Critical Error. Thread Stopped.');
       end;
  end;
end;

procedure TPIAModel.ChromiumInit;
begin
  FForm:=TForm.Create(nil);
  FChromium:=TChromium.Create(nil);
  FChromium.Parent:=FForm;
  FChromium.OnLoadEnd:=ChromiumLoadEnd;
  FChromium.OnProcessMessageReceived:=crmProcessMessageReceived;

  FForm.Height:=600;
  FForm.Width:=800;
  FChromium.Align:=alClient;
  FForm.Show;
end;

procedure TPIAModel.ProcessNextLink;
begin
  FDBService.SetLinkHandle(FCurrLink.Id, 2);
  FCurrLink:=FDBService.GetCurrLink;
  FDBService.SetLinkHandle(FCurrLink.Id, 1);

  FChromium.Load(FCurrLink.Link);
end;

constructor TPIAModel.Create(aJobID: Integer);
begin
  inherited Create;

  // подключаем БД
  FMySQLEngine:=TMySQLEngine.Create;
  FMySQLEngine.OpenConnection('MySQL.ini');

  // сущность задания
  FJob:=TJob.Create(aJobID, FMySQLEngine);

  // сервисы работы с БД
  FDBService:=TPIADBService.Create(aJobID, FMySQLEngine);

  // инициализация веббраузера
  //WebBrowserInit;
  ChromiumInit;

  // инициализация первого запуска парсера
  if FDBService.CheckFirstRun then FDBService.AddLink(FJob.ZeroLink, 0, 1);

  // JS скрипт для парсинга DOM
  FjsScript:=TFilesEngine.GetTextFromFile('D:\Git\Projects-Dev\ParseItAll\Web\js\DOMParser.js');
end;

procedure TPIAModel.StartJob;
begin
  ProcessNextLink;
end;

{ TCustomRenderProcessHandler }
procedure TCustomRenderProcessHandler.OnWebKitInitialized;
begin
{$IFDEF DELPHI14_UP}
  TCefRTTIExtension.Register('app', TJSExtension);
{$ENDIF}
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

end.
