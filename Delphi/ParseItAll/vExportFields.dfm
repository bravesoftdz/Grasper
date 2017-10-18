object ViewExportFields: TViewExportFields
  Left = 0
  Top = 0
  Caption = 'ViewExportFields'
  ClientHeight = 383
  ClientWidth = 540
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lstRuleRecords: TListBox
    Left = 8
    Top = 8
    Width = 185
    Height = 367
    ItemHeight = 13
    TabOrder = 0
  end
  object btnAddKey: TBitBtn
    Left = 216
    Top = 32
    Width = 75
    Height = 25
    Caption = 'btnAddKey'
    TabOrder = 1
    OnClick = btnAddKeyClick
  end
  object btnAddEmpty: TBitBtn
    Left = 216
    Top = 63
    Width = 75
    Height = 25
    Caption = 'btnAddEmpty'
    TabOrder = 2
    OnClick = btnAddEmptyClick
  end
  object btnRemove: TBitBtn
    Left = 216
    Top = 128
    Width = 75
    Height = 25
    Caption = 'btnRemove'
    TabOrder = 3
    OnClick = btnRemoveClick
  end
  object lstFields: TListBox
    Left = 312
    Top = 8
    Width = 212
    Height = 225
    ItemHeight = 13
    TabOrder = 4
    OnClick = lstFieldsClick
  end
  object pnlExportField: TPanel
    Left = 312
    Top = 239
    Width = 212
    Height = 98
    Caption = 'pnlExportField'
    ShowCaption = False
    TabOrder = 5
  end
  object btnApply: TBitBtn
    Left = 312
    Top = 350
    Width = 75
    Height = 25
    Caption = 'btnApply'
    TabOrder = 6
    OnClick = btnApplyClick
  end
  object btnCancel: TBitBtn
    Left = 449
    Top = 350
    Width = 75
    Height = 25
    Caption = 'btnCancel'
    TabOrder = 7
    OnClick = btnCancelClick
  end
  object btnUp: TBitBtn
    Left = 216
    Top = 192
    Width = 75
    Height = 25
    Caption = 'btnUp'
    TabOrder = 8
    OnClick = btnUpClick
  end
  object btnDown: TBitBtn
    Left = 216
    Top = 223
    Width = 75
    Height = 25
    Caption = 'btnDown'
    TabOrder = 9
    OnClick = btnDownClick
  end
end
