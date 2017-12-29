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
  API_MVC_DB in '..\..\..\Libs\Delphi\API_MVC_DB.pas',
  API_ORM in '..\..\..\Libs\Delphi\API_ORM.pas',
  eJob in 'eJob.pas',
  eCommon in 'eCommon.pas',
  vJob in 'vJob.pas' {ViewJob},
  WinApi.Windows,
  uCEFApplication,
  API_Crypt in '..\..\..\Libs\Delphi\API_Crypt.pas',
  API_ORM_VCLBind in '..\..\..\Libs\Delphi\API_ORM_VCLBind.pas';

{$R *.res}

{$SetPEFlags IMAGE_FILE_LARGE_ADDRESS_AWARE}

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF DEBUG}

  GlobalCEFApp := TCefApplication.Create;

  //GlobalCEFApp.FrameworkDirPath     := 'cef';
  //GlobalCEFApp.ResourcesDirPath     := 'cef';
  //GlobalCEFApp.LocalesDirPath       := 'cef\locales';
  GlobalCEFApp.EnableGPU            := True;      // Enable hardware acceleration
  GlobalCEFApp.DisableGPUCache      := True;      // Disable the creation of a 'GPUCache' directory in the hard drive.
  GlobalCEFApp.cache                := 'cache';
  GlobalCEFApp.cookies              := 'cookies';
  GlobalCEFApp.UserDataPath         := 'UserData';

  if GlobalCEFApp.StartMainProcess then
    begin
      Application.Initialize;
      Application.MainFormOnTaskbar := True;
      Application.CreateForm(TViewMain, ViewMain);
  Application.Run;
    end;

  GlobalCEFApp.Free;
end.
