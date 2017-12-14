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
    Header.AutoSizeIndex = -1
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoDrag, hoShowImages, hoShowSortGlyphs, hoVisible]
    TabOrder = 0
    Columns = <
      item
        CaptionAlignment = taCenter
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coUseCaptionAlignment, coEditable]
        Position = 0
        WideText = 'ID'
      end
      item
        CaptionAlignment = taCenter
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coUseCaptionAlignment, coEditable]
        Position = 1
        Width = 200
        WideText = 'Title'
      end
      item
        CaptionAlignment = taCenter
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coUseCaptionAlignment, coEditable]
        Position = 2
        Width = 300
        WideText = 'Zero Link'
      end>
  end
  object mmMenu: TMainMenu
    Left = 472
    Top = 8
  end
end
