program ParseItAll;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  API_Files in '..\..\..\Libraries\Delphi\API_Files.pas',
  API_DBases in '..\..\..\Libraries\Delphi\API_DBases.pas',
  Entities in 'Entities.pas',
  Model in 'Model.pas',
  DBService in 'DBService.pas',
  API_Parse in '..\..\..\Libraries\Delphi\API_Parse.pas',
  ceflib,
  main in '..\..\..\Vendors\Chromium-dcef3\demos\guiclient\main.pas' {MainForm},
  CustomHandles in 'CustomHandles.pas';

{$R *.res}

begin
  CefCache := 'cache';
  CefSingleProcess := False;
  if not CefLoadLibDefault then
    Exit;

  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
