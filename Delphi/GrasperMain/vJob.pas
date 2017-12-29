unit vJob;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  API_MVC_VCL, Vcl.ExtCtrls, uCEFWindowParent, uCEFChromiumWindow, Vcl.StdCtrls;

type
  TViewJob = class(TViewVCLBase)
    pnl1: TPanel;
    pnlFields: TPanel;
    chrmwndw1: TChromiumWindow;
    bcCaption: TLabeledEdit;
    bcZeroLink: TLabeledEdit;
    btnOk: TButton;
    btnCancel: TButton;
    procedure chrmwndw1AfterCreated(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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

procedure TViewJob.chrmwndw1AfterCreated(Sender: TObject);
begin
  inherited;
  chrmwndw1.LoadURL('https://www.briskbard.com/index.php?lang=en&pageid=cef');
end;

procedure TViewJob.FormCreate(Sender: TObject);
begin
  inherited;
  chrmwndw1.CreateBrowser;
end;

procedure TViewJob.InitView;
begin
  ViewJob := Self;
end;

end.
