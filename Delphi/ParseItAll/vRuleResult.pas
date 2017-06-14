unit vRuleResult;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  API_MVC, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls;

type
  TViewRuleResult = class(TViewAbstract)
    btnClose: TBitBtn;
    redtResults: TRichEdit;
    procedure btnCloseClick(Sender: TObject);
  // overrides
  protected
    procedure InitView; override;
  ////////////////////
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ViewRuleResult: TViewRuleResult;

implementation

{$R *.dfm}

procedure TViewRuleResult.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TViewRuleResult.InitView;
begin
  ViewRuleResult := Self;
end;

end.
