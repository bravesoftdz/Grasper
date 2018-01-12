unit vRules;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, vBrowser, uCEFChromium, Vcl.StdCtrls,
  Vcl.ExtCtrls, uCEFWindowParent,
  eLevel;

type
  TViewRules = class(TViewBrowser)
    lbl1: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure AfterBrowserCreate(Sender: TObject);
    procedure InitView; override;
  public
    { Public declarations }
    procedure RenderJobLevels(aJobLevelList: TJobLevelList);
  end;

var
  ViewRules: TViewRules;

implementation

{$R *.dfm}

procedure TViewRules.AfterBrowserCreate(Sender: TObject);
begin
  chrmBrowser.LoadURL(lbl1.Caption);
end;

procedure TViewRules.RenderJobLevels(aJobLevelList: TJobLevelList);
begin
  lbl1.Caption := aJobLevelList.items[0].BaseLink;
end;

procedure TViewRules.FormCreate(Sender: TObject);
begin
  inherited;

  OnAfterBrowserCreate := AfterBrowserCreate;
end;

procedure TViewRules.InitView;
begin
  ViewRules := Self;
end;

end.
