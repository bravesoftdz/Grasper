unit vRules;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, vBrowser, uCEFChromium, Vcl.StdCtrls,
  Vcl.ExtCtrls, uCEFWindowParent;

type
  TViewRules = class(TViewBrowser)
  private
    { Private declarations }
    procedure InitView; override;
  public
    { Public declarations }
  end;

var
  ViewRules: TViewRules;

implementation

{$R *.dfm}

procedure TViewRules.InitView;
begin
  ViewRules := Self;
end;

end.
