program ParseItAll;





uses
  Vcl.Forms,
  vMain in 'vMain.pas' {ViewMain},
  cController in 'cController.pas',
  vLogin in 'vLogin.pas' {ViewLogin},
  eEntities in 'eEntities.pas',
  vJob in 'vJob.pas' {ViewJob},
  ceflib,
  vRules in 'vRules.pas' {ViewRules},
  API_MVC in '..\..\..\Libraries\Delphi\API_MVC.pas',
  API_ORM_Bind in '..\..\..\Libraries\Delphi\API_ORM_Bind.pas',
  API_ORM in '..\..\..\Libraries\Delphi\API_ORM.pas',
  API_DB in '..\..\..\Libraries\Delphi\API_DB.pas',
  API_MVC_DB in '..\..\..\Libraries\Delphi\API_MVC_DB.pas',
  API_DB_MySQL in '..\..\..\Libraries\Delphi\API_DB_MySQL.pas',
  API_Files in '..\..\..\Libraries\Delphi\API_Files.pas',
  API_ORM_Cntrls in '..\..\..\Libraries\Delphi\API_ORM_Cntrls.pas',
  mParser in 'mParser.pas',
  vRuleResult in 'vRuleResult.pas' {ViewRuleResult},
  Vcl.Themes,
  Vcl.Styles,
  API_DB_SQLite in '..\..\..\Libraries\Delphi\API_DB_SQLite.pas',
  eJob in 'eJob.pas',
  eLevel in 'eLevel.pas',
  eRule in 'eRule.pas',
  eRuleLink in 'eRuleLink.pas',
  eRuleRecords in 'eRuleRecords.pas',
  eRuleCut in 'eRuleCut.pas',
  eRegExp in 'eRegExp.pas',
  eNodes in 'eNodes.pas';

{$R *.res}

begin
  CefCache := 'cache';
  CefSingleProcess := False;
  if not CefLoadLibDefault then
    Exit;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TViewMain, ViewMain);
  Application.Run;
end.
