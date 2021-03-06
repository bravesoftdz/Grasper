program Grasper;

uses
  Vcl.Forms,
  API_MVC in '..\..\..\Libs\Delphi\API_MVC.pas',
  API_MVC_VCL in '..\..\..\Libs\Delphi\API_MVC_VCL.pas' {ViewVCLBase},
  vShell in 'vShell.pas' {ViewShell};

{$R *.res}

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF DEBUG}

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TViewShell, ViewShell);
  Application.Run;
end.
