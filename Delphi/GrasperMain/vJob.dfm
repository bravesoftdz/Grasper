inherited ViewJob: TViewJob
  Caption = 'ViewJob'
  ClientHeight = 434
  ClientWidth = 672
  OnCreate = FormCreate
  ExplicitWidth = 688
  ExplicitHeight = 472
  PixelsPerInch = 96
  TextHeight = 13
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 672
    Height = 41
    Align = alTop
    Caption = 'pnl1'
    TabOrder = 0
  end
  object pnlFields: TPanel
    Left = 448
    Top = 41
    Width = 224
    Height = 393
    Align = alRight
    Caption = 'pnlFields'
    ShowCaption = False
    TabOrder = 1
    DesignSize = (
      224
      393)
    object bcCaption: TLabeledEdit
      Left = 6
      Top = 24
      Width = 211
      Height = 21
      EditLabel.Width = 37
      EditLabel.Height = 13
      EditLabel.Caption = 'Caption'
      TabOrder = 0
    end
    object bcZeroLink: TLabeledEdit
      Left = 6
      Top = 64
      Width = 211
      Height = 21
      EditLabel.Width = 43
      EditLabel.Height = 13
      EditLabel.Caption = 'Zero Link'
      TabOrder = 1
    end
    object btnOk: TButton
      Left = 16
      Top = 360
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 2
    end
    object btnCancel: TButton
      Left = 136
      Top = 360
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 3
    end
  end
  object chrmwndw1: TChromiumWindow
    Left = 0
    Top = 41
    Width = 448
    Height = 393
    Align = alClient
    TabOrder = 2
    OnAfterCreated = chrmwndw1AfterCreated
    ExplicitWidth = 488
  end
end
