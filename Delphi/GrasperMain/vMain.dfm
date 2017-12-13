inherited ViewMain: TViewMain
  Caption = 'Grasper'
  Menu = mmMenu
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object vstJobs: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 554
    Height = 290
    Align = alClient
    BorderStyle = bsNone
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.MainColumn = -1
    TabOrder = 0
    Columns = <>
  end
  object mmMenu: TMainMenu
    Left = 472
    Top = 8
  end
end
