program AdminManager;



uses
  Vcl.Forms,
  vMain in 'vMain.pas' {ViewMain},
  API_MVC in '..\..\..\..\Libraries\Delphi\API_MVC.pas',
  cController in 'cController.pas',
  API_MVC_DB in '..\..\..\..\Libraries\Delphi\API_MVC_DB.pas',
  API_DB in '..\..\..\..\Libraries\Delphi\API_DB.pas',
  API_DB_MySQL in '..\..\..\..\Libraries\Delphi\API_DB_MySQL.pas',
  API_Files in '..\..\..\..\Libraries\Delphi\API_Files.pas',
  vLogin in 'vLogin.pas' {ViewLogin},
  mLogin in 'mLogin.pas',
  eEntities in 'eEntities.pas',
  vJob in 'vJob.pas' {ViewJob},
  ceflib,
  API_ORM in '..\..\..\..\Libraries\Delphi\API_ORM.pas',
  mJobs in 'mJobs.pas',
  vRules in 'vRules.pas' {ViewRules},
  mRules in 'mRules.pas',
  API_ORM_Cntrls in '..\..\..\..\Libraries\Delphi\API_ORM_Cntrls.pas',
  API_MVC_Bind in '..\..\..\..\Libraries\Delphi\API_MVC_Bind.pas';

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
