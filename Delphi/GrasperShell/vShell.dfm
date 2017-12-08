inherited ViewShell: TViewShell
  BorderStyle = bsNone
  Caption = 'Grasper'
  ClientHeight = 77
  ClientWidth = 321
  ExplicitWidth = 321
  ExplicitHeight = 77
  PixelsPerInch = 96
  TextHeight = 13
  object lblStarting: TLabel
    Left = 8
    Top = 9
    Width = 100
    Height = 13
    Caption = 'Grasper is starting...'
  end
  object pbStarting: TProgressBar
    Left = 8
    Top = 30
    Width = 305
    Height = 17
    Style = pbstMarquee
    TabOrder = 0
  end
  object tmr1: TTimer
    Interval = 2500
    OnTimer = tmr1Timer
    Left = 120
    Top = 8
  end
end
