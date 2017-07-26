unit vJob;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,
  API_MVC,
  API_ORM_Cntrls, cefvcl, ceflib;

type
  TEntityPanel = class(TEntityPanelAbstract)
  end;

  TViewJob = class(TViewAbstract)
    pnlBrowser: TPanel;
    pnlURL: TPanel;
    edtURL: TEdit;
    lblURL: TLabel;
    btnNavigate: TBitBtn;
    pnlFieldsContainer: TPanel;
    btnCancel: TButton;
    btnApply: TButton;
    chrmBrowser: TChromium;
    procedure btnNavigateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure InitView; override;
    procedure ApplyChanges(Sender: TObject);
    procedure CancelChanges(Sender: TObject);
    procedure LoadStart(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame);
  public
    { Public declarations }
    EntityPanel: TEntityPanel;
    ZeroLinkEdit: TEdit;
    procedure SetBrowserLinks;
  end;

var
  ViewJob: TViewJob;

implementation

{$R *.dfm}

procedure TViewJob.LoadStart(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame);
begin
  edtURL.Text := frame.Url;
  if frame.Url <> 'about:blank' then ZeroLinkEdit.Text := frame.Url;
end;

procedure TViewJob.SetBrowserLinks;
begin
  chrmBrowser.OnLoadStart := LoadStart;
  ZeroLinkEdit := EntityPanel.FindComponent('cntrl' + 'ZERO_LINK') as TEdit;
  ZeroLinkEdit.Enabled := False;

  if ZeroLinkEdit.Text <> '' then
    chrmBrowser.Load(ZeroLinkEdit.Text);
end;

procedure TViewJob.ApplyChanges(Sender: TObject);
begin
  Self.SendMessage('StoreJob');
end;

procedure TViewJob.CancelChanges(Sender: TObject);
begin
  Close;
end;

procedure TViewJob.btnNavigateClick(Sender: TObject);
begin
  chrmBrowser.Load(edtURL.Text);
end;

procedure TViewJob.FormCreate(Sender: TObject);
begin
  EntityPanel := TEntityPanel.Create(Self.pnlFieldsContainer);
  btnApply.OnClick := ApplyChanges;
  btnCancel.OnClick := CancelChanges;
end;

procedure TViewJob.InitView;
begin
  ViewJob := Self;
end;

end.
