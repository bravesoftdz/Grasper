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
  object pnl2: TPanel
    Left = 488
    Top = 41
    Width = 184
    Height = 393
    Align = alRight
    Caption = 'pnl2'
    TabOrder = 1
  end
  object chrmwndw1: TChromiumWindow
    Left = 0
    Top = 41
    Width = 488
    Height = 393
    Align = alClient
    TabOrder = 2
    OnAfterCreated = chrmwndw1AfterCreated
  end
end
