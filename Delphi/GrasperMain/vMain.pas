unit vMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, API_MVC_VCL, Vcl.Menus, VirtualTrees;

type
  TViewMain = class(TViewVCLBase)
    mmMenu: TMainMenu;
    vstJobs: TVirtualStringTree;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure InitView; override;
  public
    { Public declarations }
  end;

var
  ViewMain: TViewMain;

implementation

{$R *.dfm}

uses
  cController;

procedure TViewMain.FormCreate(Sender: TObject);
begin
  inherited;

  SendMessage('Test');
end;

procedure TViewMain.InitView;
begin
  FControllerClass := TController;
  ViewMain := Self;
end;

end.
