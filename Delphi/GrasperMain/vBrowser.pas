unit vBrowser;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, API_MVC_VCL, uCEFWindowParent,
  uCEFChromium, Vcl.ExtCtrls, uCEFConstants, uCEFInterfaces, Vcl.StdCtrls;

type
  TViewBrowser = class(TViewVCLBase)
    cfWindowParent: TCEFWindowParent;
    chrmBrowser: TChromium;
    pnlControls: TPanel;
    splBrws2Cntrl: TSplitter;
    btnOk: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure chrmBrowserAfterCreated(Sender: TObject;
      const browser: ICefBrowser);
  private
    { Private declarations }
    FOnAfterBrowserCreate: TNotifyEvent;
    procedure AfterBrowserCreate(var aMessage : TMessage); message CEF_AFTERCREATED;
  public
    { Public declarations }
    property OnAfterBrowserCreate: TNotifyEvent read FOnAfterBrowserCreate write FOnAfterBrowserCreate;
  end;

const
  BLANK_PAGE = 'about:blank';

implementation

{$R *.dfm}

procedure TViewBrowser.AfterBrowserCreate(var aMessage : TMessage);
begin
  if Assigned(FOnAfterBrowserCreate) then
    FOnAfterBrowserCreate(Self);
end;

procedure TViewBrowser.chrmBrowserAfterCreated(Sender: TObject;
  const browser: ICefBrowser);
begin
  inherited;

  PostMessage(Handle, CEF_AFTERCREATED, 0, 0);
end;

procedure TViewBrowser.FormCreate(Sender: TObject);
begin
  inherited;

  chrmBrowser.CreateBrowser(cfWindowParent, '');
end;

end.
