inherited ViewBrowser: TViewBrowser
  Caption = 'ViewBrowser'
  ClientHeight = 434
  ClientWidth = 672
  OnCreate = FormCreate
  ExplicitWidth = 688
  ExplicitHeight = 472
  PixelsPerInch = 96
  TextHeight = 13
  object splBrws2Cntrl: TSplitter
    Left = 445
    Top = 0
    Height = 434
    Align = alRight
    Color = clHighlight
    ParentColor = False
    ExplicitLeft = 444
  end
  object cfWindowParent: TCEFWindowParent
    Left = 0
    Top = 0
    Width = 445
    Height = 434
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 273
  end
  object pnlControls: TPanel
    Left = 448
    Top = 0
    Width = 224
    Height = 434
    Align = alRight
    Caption = 'pnlControls'
    ShowCaption = False
    TabOrder = 1
    ExplicitLeft = 487
    DesignSize = (
      224
      434)
    object btnOk: TButton
      Left = 15
      Top = 400
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 135
      Top = 400
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object chrmBrowser: TChromium
    OnAfterCreated = chrmBrowserAfterCreated
    Left = 30
    Top = 15
  end
end
