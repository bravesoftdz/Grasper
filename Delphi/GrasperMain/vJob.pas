unit vJob;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  API_MVC_VCL, Vcl.ExtCtrls, uCEFWindowParent, uCEFChromiumWindow, Vcl.StdCtrls,
  Vcl.Buttons, System.Actions, Vcl.ActnList, Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnMan, System.ImageList, Vcl.ImgList, Vcl.ToolWin, Vcl.ActnCtrls, uCEFChromium,
  uCEFInterfaces;

type
  TViewJob = class(TViewVCLBase)
    pnlNav: TPanel;
    pnlFields: TPanel;
    bcCaption: TLabeledEdit;
    bcZeroLink: TLabeledEdit;
    btnOk: TButton;
    btnCancel: TButton;
    edtURL: TEdit;
    lblURL: TLabel;
    ActionManager: TActionManager;
    acBrowse: TAction;
    ilActionIcons: TImageList;
    acttb1: TActionToolBar;
    cfWindowParent: TCEFWindowParent;
    chrmBrowser: TChromium;
    procedure FormCreate(Sender: TObject);
    procedure acBrowseExecute(Sender: TObject);
    procedure chrmBrowserAfterCreated(Sender: TObject;
      const browser: ICefBrowser);
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

procedure TViewJob.acBrowseExecute(Sender: TObject);
begin
  inherited;
  chrmBrowser.LoadURL(edtURL.Text);
end;

procedure TViewJob.chrmBrowserAfterCreated(Sender: TObject;
  const browser: ICefBrowser);
begin
  inherited;
  chrmBrowser.LoadURL('https://www.briskbard.com/index.php?lang=en&pageid=cef');
  //browser.MainFrame.LoadURL(bcZeroLink.Text);
end;

procedure TViewJob.FormCreate(Sender: TObject);
begin
  inherited;
  chrmBrowser.CreateBrowser(cfWindowParent, '');
end;

procedure TViewJob.InitView;
begin
  ViewJob := Self;
end;

end.
