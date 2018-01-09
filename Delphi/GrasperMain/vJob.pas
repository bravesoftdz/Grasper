unit vJob;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, vBrowser, uCEFChromium, Vcl.StdCtrls,
  Vcl.ExtCtrls, uCEFWindowParent, uCEFInterfaces, Vcl.ToolWin, Vcl.ActnMan,
  Vcl.ActnCtrls, System.Actions, Vcl.ActnList,
  Vcl.PlatformDefaultStyleActnCtrls, System.ImageList, Vcl.ImgList;

type
  TViewJob = class(TViewBrowser)
    bcCaption: TLabeledEdit;
    bcZeroLink: TLabeledEdit;
    pnlNav: TPanel;
    lblURL: TLabel;
    edtURL: TEdit;
    acttb1: TActionToolBar;
    ilActionIcons: TImageList;
    ActionManager: TActionManager;
    acBrowser: TAction;
    procedure chrmBrowserLoadStart(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; transitionType: Cardinal);
    procedure edtURLKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure acBrowserExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure AfterBrowserCreate(Sender: TObject);
    procedure InitView; override;
  public
    { Public declarations }
  end;

var
  ViewJob: TViewJob;

implementation

{$R *.dfm}

procedure TViewJob.AfterBrowserCreate(Sender: TObject);
begin
  chrmBrowser.LoadURL(bcZeroLink.Text);
end;

procedure TViewJob.acBrowserExecute(Sender: TObject);
begin
  inherited;

  chrmBrowser.LoadURL(edtURL.Text);
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
    acBrowserExecute(nil);
end;

procedure TViewJob.FormCreate(Sender: TObject);
begin
  inherited;

  OnAfterBrowserCreate := AfterBrowserCreate;
end;

procedure TViewJob.InitView;
begin
  ViewJob := Self;
end;

end.
