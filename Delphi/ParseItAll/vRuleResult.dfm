object ViewRuleResult: TViewRuleResult
  Left = 0
  Top = 0
  Caption = 'Rule Parse Result'
  ClientHeight = 290
  ClientWidth = 554
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  DesignSize = (
    554
    290)
  PixelsPerInch = 96
  TextHeight = 13
  object btnClose: TBitBtn
    Left = 239
    Top = 257
    Width = 75
    Height = 25
    Anchors = [akBottom]
    Caption = 'btnClose'
    TabOrder = 0
    OnClick = btnCloseClick
  end
  object redtResults: TRichEdit
    Left = 0
    Top = 0
    Width = 554
    Height = 251
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
    Zoom = 100
  end
end
