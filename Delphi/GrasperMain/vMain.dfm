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
    Header.Options = [hoColumnResize, hoDrag, hoShowImages, hoShowSortGlyphs, hoVisible, hoAutoSpring]
    LineMode = lmBands
    LineStyle = lsSolid
    TabOrder = 0
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnGetText = vstJobsGetText
    Columns = <
      item
        CaptionAlignment = taCenter
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAutoSpring, coAllowFocus, coUseCaptionAlignment, coEditable]
        Position = 0
        Width = 201
        WideText = 'Job'
      end
      item
        CaptionAlignment = taCenter
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAutoSpring, coAllowFocus, coUseCaptionAlignment, coEditable]
        Position = 1
        Width = 347
        WideText = 'Zero Link'
      end>
  end
  object mmMenu: TMainMenu
    Left = 472
    Top = 8
  end
end
