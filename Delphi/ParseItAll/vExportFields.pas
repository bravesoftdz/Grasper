unit vExportFields;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  API_ORM_Cntrls, Vcl.StdCtrls;

type
  TViewExportFields = class(TViewORM)
    lstRuleRecords: TListBox;
  private
    { Private declarations }
  protected
  // necessary overrides ///////////////////////////////////////////////////////
    procedure InitView; override;
  //////////////////////////////////////////////////////////////////////////////
  public
    { Public declarations }
  end;

var
  ViewExportFields: TViewExportFields;

implementation

{$R *.dfm}

procedure TViewExportFields.InitView;
begin
  ViewExportFields := Self;
end;

end.
