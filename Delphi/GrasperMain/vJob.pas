unit vJob;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  API_MVC_VCL, Vcl.ExtCtrls, uCEFWindowParent, uCEFChromiumWindow, Vcl.StdCtrls,
  Vcl.Buttons, System.Actions, Vcl.ActnList, Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnMan, System.ImageList, Vcl.ImgList, Vcl.ToolWin, Vcl.ActnCtrls, uCEFChromium,
  uCEFInterfaces, uCEFConstants;

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
    procedure chrmBrowserLoadStart(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; transitionType: Cardinal);
    procedure edtURLKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    procedure AfterBrowserCreate(var aMessage : TMessage); message CEF_AFTERCREATED;
    procedure InitView; override;
  public
    { Public declarations }
  end;

var
  ViewJob: TViewJob;

implementation

{$R *.dfm}

uses
  eCommon;

procedure TViewJob.AfterBrowserCreate(var aMessage : TMessage);
begin
  chrmBrowser.LoadURL(bcZeroLink.Text);
end;

procedure TViewJob.acBrowseExecute(Sender: TObject);
begin
  inherited;

  chrmBrowser.LoadURL(edtURL.Text);
end;

procedure TViewJob.chrmBrowserAfterCreated(Sender: TObject;
  const browser: ICefBrowser);
begin
  inherited;

  PostMessage(Handle, CEF_AFTERCREATED, 0, 0);
end;

procedure TViewJob.chrmBrowserLoadStart(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; transitionType: Cardinal);
begin
  inherited;

  if frame.IsMain and
     (frame.Url <> BLANK_PAGE)
  then
    begin
      edtURL.Text := frame.Url;
      bcZeroLink.Text := frame.Url;
    end;
end;

procedure TViewJob.edtURLKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;

  if Key = VK_RETURN then
    acBrowseExecute(nil);
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
