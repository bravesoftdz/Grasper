unit vMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, API_MVC_VCL;

type
  TViewMain = class(TViewVCLBase)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ViewMain: TViewMain;

implementation

{$R *.dfm}

procedure TViewMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;

  Application.Terminate;
end;

end.
