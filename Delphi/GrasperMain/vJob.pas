unit vJob;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  API_MVC_VCL;

type
  TViewJob = class(TViewVCLBase)
  private
    { Private declarations }
    procedure InitView; override;
  public
    { Public declarations }
  end;

var
  ViewJob: TViewJob;

implementation

{$R *.dfm}

procedure TViewJob.InitView;
begin
  ViewJob := Self;
end;

end.
