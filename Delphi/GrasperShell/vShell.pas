unit vShell;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, API_MVC_VCL, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls;

type
  TViewShell = class(TViewVCLBase)
    pbStarting: TProgressBar;
    lblStarting: TLabel;
    tmr1: TTimer;
    procedure tmr1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ViewShell: TViewShell;

implementation

{$R *.dfm}

procedure StartGrasperLib; stdcall; external 'GrasperLib.dll';

procedure TViewShell.tmr1Timer(Sender: TObject);
begin
  inherited;

  pbStarting.StepIt;

  if pbStarting.Position >= pbStarting.Max then
    begin
      tmr1.Enabled := False;
      Self.Hide;
      StartGrasperLib;
    end;
end;

end.
