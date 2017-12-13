program Grasper;

uses
  Vcl.Forms,
  API_MVC_VCL in '..\..\..\Libs\Delphi\API_MVC_VCL.pas' {ViewVCLBase},
  vMain in 'vMain.pas' {ViewMain},
  API_MVC in '..\..\..\Libs\Delphi\API_MVC.pas',
  Vcl.Themes,
  Vcl.Styles,
  cController in 'cController.pas',
  API_DB in '..\..\..\Libs\Delphi\API_DB.pas',
  API_DB_SQLite in '..\..\..\Libs\Delphi\API_DB_SQLite.pas',
  API_MVC_DB in '..\..\..\Libs\Delphi\API_MVC_DB.pas';

{$R *.res}

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF DEBUG}

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TViewMain, ViewMain);
  Application.Run;
end.
