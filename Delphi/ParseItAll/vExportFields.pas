unit vExportFields;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  API_ORM_Cntrls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  eExportField,
  eRuleRecords;

type
  TEntityPanel = class(TEntityPanelAbstract)
  end;

  TViewExportFields = class(TViewORM)
    lstRuleRecords: TListBox;
    btnAddKey: TBitBtn;
    btnAddEmpty: TBitBtn;
    btnRemove: TBitBtn;
    lstFields: TListBox;
    pnlExportField: TPanel;
    btnApply: TBitBtn;
    btnCancel: TBitBtn;
    btnUp: TBitBtn;
    btnDown: TBitBtn;
    procedure btnCancelClick(Sender: TObject);
    procedure btnAddKeyClick(Sender: TObject);
    procedure lstFieldsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnAddEmptyClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
  private
    { Private declarations }
    FEntityPanel: TEntityPanel;
    function GetSelectedExportField: TExportField;
    function GetSelectedRuleRec: TJobRecord;
  protected
  // necessary overrides ///////////////////////////////////////////////////////
    procedure InitView; override;
  //////////////////////////////////////////////////////////////////////////////
  public
    { Public declarations }
    procedure InsertExportField(aExportField: TExportField);
    procedure RemoveExportField;
    procedure RenderExportFields(aExportFields: TExportFieldList);
    procedure RenderRuleRecKeys(aRecList: TJobRecordList);

    property SelectedExportField: TExportField read GetSelectedExportField;
    property SelectedRuleRec: TJobRecord read GetSelectedRuleRec;
  end;

var
  ViewExportFields: TViewExportFields;

implementation

{$R *.dfm}

uses
  API_ORM;

procedure TViewExportFields.RemoveExportField;
var
  i: Integer;
  ExportField: TExportField;
begin
  for i := lstFields.ItemIndex to lstFields.Count - 1 do
    begin
      ExportField := FBind.GetEntityByControl(lstFields, i) as TExportField;
      FBind.RemoveBind(lstFields, i);

      if i > lstFields.ItemIndex then
        begin
          ExportField.OrderNum := ExportField.OrderNum - 1;
          FBind.AddBind(lstFields, ExportField, i - 1);
        end;
    end;

  lstFields.DeleteSelected;
end;

procedure TViewExportFields.RenderExportFields(aExportFields: TExportFieldList);
var
  ExportField: TExportField;
  i: Integer;
begin
  if aExportFields.Count = 0 then Exit;
  i := 0;

  for ExportField in aExportFields do
    begin
      lstFields.Items.Add(ExportField.Title);
      FBind.AddBind(lstFields, ExportField, i);
      Inc(i);
    end;

  lstFields.ItemIndex := 0;
end;

function TViewExportFields.GetSelectedExportField: TExportField;
var
  Entity: TEntityAbstract;
begin
  Entity := FBind.GetEntityByControl(lstFields, lstFields.ItemIndex);

  if Entity is TExportField then
    Result := Entity as TExportField
  else
    Result := nil;
end;

procedure TViewExportFields.InsertExportField(aExportField: TExportField);
begin
  lstFields.Items.Add(aExportField.Title);
  FBind.AddBind(lstFields, aExportField, lstFields.Count - 1);
end;

procedure TViewExportFields.lstFieldsClick(Sender: TObject);
begin
  FEntityPanel.ClearControls;
  FEntityPanel.BuildControls(SelectedExportField);
end;

function TViewExportFields.GetSelectedRuleRec: TJobRecord;
var
  Entity: TEntityAbstract;
begin
  Entity := FBind.GetEntityByControl(lstRuleRecords, lstRuleRecords.ItemIndex);

  if Entity is TJobRecord then
    Result := Entity as TJobRecord
  else
    Result := nil;
end;

procedure TViewExportFields.RenderRuleRecKeys(aRecList: TJobRecordList);
var
  RuleRec: TJobRecord;
  i: Integer;
begin
  i := 0;

  for RuleRec in aRecList do
    begin
      lstRuleRecords.Items.Add(RuleRec.Key);
      FBind.AddBind(lstRuleRecords, RuleRec, i);
      Inc(i);
    end;

  lstRuleRecords.ItemIndex := 0;
  aRecList.Free;
end;

procedure TViewExportFields.btnAddEmptyClick(Sender: TObject);
begin
  SendMessage('AddExportFieldCustom');
end;

procedure TViewExportFields.btnAddKeyClick(Sender: TObject);
begin
  SendMessage('AddExportField');
end;

procedure TViewExportFields.btnApplyClick(Sender: TObject);
begin
  SendMessage('StoreExportFields');
  Close;
end;

procedure TViewExportFields.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TViewExportFields.btnDownClick(Sender: TObject);
var
  ExportField1, ExportField2: TExportField;
  TempOrderNum: Integer;
begin
  if lstFields.ItemIndex + 1 < lstFields.Count then
    begin
      ExportField1 := FBind.GetEntityByControl(lstFields, lstFields.ItemIndex) as TExportField;
      ExportField2 := FBind.GetEntityByControl(lstFields, lstFields.ItemIndex + 1) as TExportField;

      TempOrderNum := ExportField1.OrderNum;
      ExportField1.OrderNum := ExportField2.OrderNum;
      ExportField2.OrderNum := TempOrderNum;

      FBind.RemoveBind(lstFields, lstFields.ItemIndex);
      FBind.RemoveBind(lstFields, lstFields.ItemIndex + 1);

      FBind.AddBind(lstFields, ExportField1, lstFields.ItemIndex + 1);
      FBind.AddBind(lstFields, ExportField2, lstFields.ItemIndex);

      lstFields.Items.Exchange(lstFields.ItemIndex, lstFields.ItemIndex + 1);
    end;
end;

procedure TViewExportFields.btnRemoveClick(Sender: TObject);
begin
  SendMessage('RemoveExportField');
end;

procedure TViewExportFields.btnUpClick(Sender: TObject);
var
  ExportField1, ExportField2: TExportField;
  TempOrderNum: Integer;
begin
  if lstFields.ItemIndex - 1 >= 0 then
    begin
      ExportField1 := FBind.GetEntityByControl(lstFields, lstFields.ItemIndex) as TExportField;
      ExportField2 := FBind.GetEntityByControl(lstFields, lstFields.ItemIndex - 1) as TExportField;

      TempOrderNum := ExportField1.OrderNum;
      ExportField1.OrderNum := ExportField2.OrderNum;
      ExportField2.OrderNum := TempOrderNum;

      FBind.RemoveBind(lstFields, lstFields.ItemIndex);
      FBind.RemoveBind(lstFields, lstFields.ItemIndex - 1);

      FBind.AddBind(lstFields, ExportField1, lstFields.ItemIndex - 1);
      FBind.AddBind(lstFields, ExportField2, lstFields.ItemIndex);

      lstFields.Items.Exchange(lstFields.ItemIndex, lstFields.ItemIndex - 1);
    end;
end;

procedure TViewExportFields.FormCreate(Sender: TObject);
begin
  FEntityPanel := TEntityPanel.Create(pnlExportField);
end;

procedure TViewExportFields.InitView;
begin
  ViewExportFields := Self;
end;

end.
