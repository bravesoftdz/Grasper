object ViewJob: TViewJob
  Left = 0
  Top = 0
  Caption = 'Parse It All! Project'
  ClientHeight = 300
  ClientWidth = 554
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBrowser: TPanel
    Left = 0
    Top = 33
    Width = 377
    Height = 267
    Align = alLeft
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object chrmBrowser: TChromium
      Left = 1
      Top = 1
      Width = 375
      Height = 265
      Align = alClient
      DefaultUrl = 'about:blank'
      TabOrder = 0
    end
  end
  object pnlURL: TPanel
    Left = 0
    Top = 0
    Width = 554
    Height = 33
    Align = alTop
    TabOrder = 1
    object lblURL: TLabel
      Left = 45
      Top = 9
      Width = 16
      Height = 13
      Caption = 'url:'
    end
    object edtURL: TEdit
      Left = 67
      Top = 6
      Width = 422
      Height = 21
      TabOrder = 0
    end
    object btnNavigate: TBitBtn
      Left = 492
      Top = 4
      Width = 25
      Height = 25
      Caption = 'go'
      TabOrder = 1
      OnClick = btnNavigateClick
    end
  end
  object pnlFieldsContainer: TPanel
    Left = 377
    Top = 33
    Width = 177
    Height = 228
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 471
    Top = 267
    Width = 75
    Height = 25
    Caption = 'btnCancel'
    TabOrder = 3
  end
  object btnApply: TButton
    Left = 390
    Top = 267
    Width = 75
    Height = 25
    Caption = 'btnApply'
    TabOrder = 4
  end
end
