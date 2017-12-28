inherited ViewMain: TViewMain
  Caption = 'Grasper'
  ClientHeight = 303
  OnCreate = FormCreate
  ExplicitHeight = 341
  PixelsPerInch = 96
  TextHeight = 13
  object vstJobs: TVirtualStringTree
    Left = 0
    Top = 26
    Width = 554
    Height = 277
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
  object ActionToolBar: TActionToolBar
    Left = 0
    Top = 0
    Width = 554
    Height = 26
    ActionManager = ActionManager
    Caption = 'ActionToolBar'
    Color = clWindow
    ColorMap = scmColorMap
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    HorzMargin = 10
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    Spacing = 0
  end
  object ActionManager: TActionManager
    ActionBars = <
      item
        Items.CaptionOptions = coNone
        Items = <
          item
            Action = acAddJob
            Caption = '&New Job'
            ImageIndex = 0
          end
          item
            Action = acEditJob
            Caption = '&Edit Job'
            ImageIndex = 1
          end
          item
            Action = acRemoveJob
            Caption = '&Remove Job'
            ImageIndex = 2
          end>
        ActionBar = ActionToolBar
      end>
    Images = ilActionIcons
    Left = 488
    Top = 80
    StyleName = 'Platform Default'
    object acAddJob: TAction
      Category = 'Jobs'
      Caption = 'New Job'
      Hint = 'New Job'
      ImageIndex = 0
      OnExecute = acAddJobExecute
    end
    object acEditJob: TAction
      Category = 'Jobs'
      Caption = 'Edit Job'
      Hint = 'Edit Job'
      ImageIndex = 1
      OnExecute = acEditJobExecute
    end
    object acRemoveJob: TAction
      Category = 'Jobs'
      Caption = 'Remove Job'
      Hint = 'Remove Job'
      ImageIndex = 2
      OnExecute = acRemoveJobExecute
    end
  end
  object ilActionIcons: TImageList
    Left = 488
    Top = 136
    Bitmap = {
      494C010103000800340010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      000000000000000000000000000000000000FFFFFF00FFFFFF00FEFEFE00FCFC
      FC00FBFBFB00FCFCFC00FEFEFE00FFFFFF00FFFFFF00C1C1C1006A6A6A004D4D
      4D0069696900C0C1C100FBFBFB00FCFCFC00FFFFFF00FFFFFF00F0F0F000A7A7
      A700A3A3A300A4A4A400A5A5A500DAD9D300F1ECDC00BDBDBD00A5A5A500A5A5
      A500AAAAAA00F2F2F200FBFBFB00FCFCFC00FFFFFF00FFFFFF00F4F4F4006464
      A500C9C9CF00FCFCFC00FEFEFE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00D0D0
      D6006767A700F2F2F200FBFBFB00FCFCFC000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00C9C9C900A6A6A600A5A5
      A500A2A2A200A2A2A200A2A2A200C6C6C600C1C1C1004D4D4D004D4D4D009F9F
      9F004D4D4D004D4D4D00BEBEBE00FBFBFB00FFFFFF00FFFFFF00A0A0A000F0F0
      F000F2F2F200F1F1F100F2F2F200FAFAF800BB9E4800DBCBA100F7F6F400F9F9
      F900EDEDED00A5A5A500F8F8F800FBFBFB00FFFFFF00F5F5F5005959A8002A2A
      BB003535B100C6C6CC00F8F8F800FEFEFE00FFFFFF00FFFFFF00D1D1D6003636
      B4002A2ABC005B5BA800EFEFEF00FBFBFB000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF0050505000A3A3A300A6A6
      A600A5A5A500A0A0A0009F9F9F00D1D1D100676767004D4D4D004D4D4D00FFFF
      FF004D4D4D004D4D4D0069696900FCFCFC00FFFFFF00FFFFFF009F9F9F00FFFF
      FF00FDFDFD00F5F5F500F3F4F400F5F5F500D8C99A00E0D4AE00CCB57700FFFF
      FF00FFFFFF009F9F9F00FEFEFE00FCFCFC00F5F5F5005A5AAB002C2CBF002C2C
      BF002C2CBE003636B100C3C4C900F5F5F500FDFDFD00D1D1D6003737B6002C2C
      BF002C2CBF002C2CBF005B5BAA00F2F2F2000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF004D4D4D00FFFFFF00FFFF
      FF00FFFFFF00FDFDFD00F5F5F500F3F4F4004C4D4D00A0A0A000FFFFFF00FFFF
      FF00FFFFFF009F9F9F004D4D4D00FEFEFE00FFFFFF00FFFFFF009F9F9F00F4F4
      F400A5A5A500A4A4A400A0A0A0009F9F9F00CDC19E00C9B27100B08E3000E3D7
      B300FFFFFF009F9F9F00FFFFFF00FEFEFE006868AB002F2FC2002F2FC2002F2F
      C2002F2FC2002F2FC1003838B400C3C4C900C9C9CE003B3BB7002F2FC2002F2F
      C2002F2FC2002F2FC2002F2FC2006767AA000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF004D4D4D00FFFFFF00A6A6
      A600A6A6A600A6A6A600A5A5A500D1D1D100656565004C4D4D004D4D4D00FFFF
      FF004D4D4D004D4D4D006A6A6A00FFFFFF00FFFFFF00FFFFFF009F9F9F00FEFE
      FE00F9F9F900F9F9F900F7F7F700EFEFEF00F1F2F100CDBC8B00D0BB8100B494
      3900F4F0E400A0A0A000FFFFFF00FFFFFF00CECED4003A3ABC003131C5003131
      C5003131C5003131C5003131C4003A3AB6003D3DB4003232BE003131C4003131
      C5003131C5003131C5003939BE00C8C8CE000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF004D4D4D00FFFFFF00AAAA
      AA00A8A8A800A8A8A800A8A8A800B1B1B100B8B9B9004C4C4C004C4D4D00A0A0
      A0004D4D4D004D4D4D00C1C1C100FFFFFF00FFFFFF00FEFEFE009F9F9F00F3F3
      F3009F9F9F009F9F9F009F9F9F009E9E9E009A9A9A00D2CFC700CFBF9000BDA1
      5300C3A85E00E0E0DF00FFFFFF00FFFFFF00FFFFFF00CDCDD3003C3CC0003333
      C8003333C8003333C8003333C8003333C7003434C1003434C0003434C1003333
      C7003333C8003B3BC100C8C8CE00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF004D4D4D00FEFEFE00A6A6
      A600A6A6A600A6A6A600A6A6A600A6A6A600BBBBBB00B9B9B900656565004C4D
      4D0067676700C1C1C100FFFFFF00FFFFFF00FFFFFF00FCFCFC009E9E9E00F3F3
      F3009F9F9F009F9F9F009F9F9F009F9F9F009E9E9E009A9A9A00CAC1A600D4C6
      9B00B1903500D8C79700FFFFFF00FFFFFF00FFFFFF00FCFCFC00CBCBD2003F3F
      C3003636CB003636CB003636CB003636CB003636CA003737C4003737C3003737
      C4003D3DC300C8C8CE00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF004D4D4D00F8F8F800A6A6
      A600A6A6A600A6A6A600A6A6A600A6A6A600A6A6A600A6A6A600F5F5F500C9C9
      C900F5F5F500FDFDFD00FFFFFF00FFFFFF00FFFFFF00FBFBFB009B9B9B00FBFB
      FB00F2F2F200F2F2F200F2F2F200F2F2F200F2F2F200F0F0F000E9E9E900CEBF
      9100CCBB8A00B8974200F9F8F300FFFFFF00FFFFFF00FBFBFB00F8F8F800CBCB
      D2004141C5003838CE003838CE003838CE003838CE003838CD003839C7003F3F
      BF00C1C1C900FDFDFD00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF004D4D4D00F7F7F700A1A1
      A100A5A5A500A6A6A600A6A6A600A6A6A600A6A6A600A6A6A600FDFDFD004C4D
      4D00F3F4F400F5F5F500FEFEFE00FFFFFF00FFFFFF00FCFCFC009B9B9B00EBEB
      EB00ABABAB00ACACAC00ACACAC00ACACAC00ACACAC00ACACAC00ABABAB00D9D9
      D500C8B68100D3C49B00BEA45500FEFEFD00FFFFFF00FCFCFC00F7F7F700C9C9
      CF004444C5003B3BD2003B3BD2003B3BD2003B3BD2003B3BD2003B3BD1004344
      C100C3C4CA00F5F5F500FEFEFE00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF004D4D4D00F8F8F800A0A0
      A000A0A0A000A5A5A500A6A6A600A6A6A600A6A6A600A6A6A600FFFFFF004D4D
      4D00F5F5F500F3F4F400F8F8F800FEFEFE00FFFFFF00FEFEFE009B9B9B00E8E8
      E8009A9A9A009E9E9E009F9F9F009F9F9F009F9F9F009F9F9F009F9F9F009E9E
      9E00E5E0D300AC8F3800D5C79C00FEFEFE00FFFFFF00FEFEFE00CCCCD2004647
      C1003D3DCD003D3DD4003D3DD5003D3DD5003D3DD5003D3DD5003D3DD5003D3D
      D4004445C300C4C5CA00F8F8F800FEFEFE000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF004D4D4D00FEFEFE00F5F5
      F500F3F4F400F5F5F500FDFDFD00FFFFFF00FFFFFF00FFFFFF00FFFFFF004D4D
      4D00FDFDFD00F5F5F500F7F7F700FCFCFC00FFFFFF00FFFFFF009E9E9E00F5F5
      F500F3F4F400F5F5F500FDFDFD00D2D2D200CCCCCC00CCCCCC00CCCCCC00CCCC
      CC00FAFAFA00C8C7C400F7F7F700FCFCFC00FFFFFF00D1D1D7004949CC004040
      D0004040CF004040D0004040D7004040D8004040D8004040D8004040D8004040
      D8004040D7004646C600C6C6CD00FCFCFC000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF004D4D4D00FFFFFF00FDFD
      FD00F5F5F500F3F4F400F5F5F500FDFDFD00FFFFFF00FFFFFF00FFFFFF004D4D
      4D00FFFFFF00FDFDFD00F8F8F800FBFBFB00FFFFFF00FFFFFF009C9C9C00C4C4
      C400BEBEBE00CECECE00F5F5F500D7D7D700D2D2D200D2D2D200D2D2D200D2D2
      D200FCFCFC009E9E9E00F8F8F800FBFBFB00D1D1D7004B4BCF004242DB004242
      DA004242D3004242D2004242D3004949D0004949CF004242DB004242DB004242
      DB004242DB004242DA004949CD00C8C8CF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00656565004D4D4D004F4F
      4F00C9C9C900F5F5F500A0A0A000A0A0A000A5A5A500D4D4D400FFFFFF004D4D
      4D00FFFFFF00FFFFFF00FEFEFE00FCFCFC00FFFFFF00FFFFFF00D9D9D9004141
      41003333330034343400D9D9D900A5A5A5009E9E9E009F9F9F009F9F9F009F9F
      9F00F9F9F9009F9F9F00FEFEFE00FCFCFC007070B7004545DE004545DE004545
      DE004545DD004545D6004A4ACB00C3C3CB00CFCFD5004D4DD1004545DE004545
      DE004545DE004545DE004545DD006F70B6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00E7E7E700626262004D4D
      4D00A6A6A600FEFEFE00F8F8F800F7F7F700F8F8F800FEFEFE00FFFFFF004D4D
      4D00FFFFFF00FFFFFF00FFFFFF00FEFEFE00FFFFFF00FFFFFF00FFFFFF00D6D6
      D6004141410033333300D4D4D400F7F7F700F8F8F800FEFEFE00FFFFFF00FFFF
      FF00FFFFFF009F9F9F00FFFFFF00FEFEFE00F3F3F4006767BE004747E1004747
      E1004747E1004D4DD600C5C5CC00F7F7F700F8F8F800CFCFD5004F4FD4004747
      E1004747E1004747E1006868BD00F3F3F3000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00E7E7E7006262
      620079797900A6A6A600A6A6A600A4A4A400A3A3A300A4A4A400A3A3A3005050
      5000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00D6D6D60041414100D3D3D300F6F6F600F5F5F500F6F6F600F8F8F800F9F9
      F900F1F1F100A2A2A200FFFFFF00FFFFFF00FFFFFF00F3F3F4006868C1004949
      E4004E4EDA00CACAD100FEFEFE00FCFCFC00FBFBFB00FCFCFC00D0D0D5005050
      D7004949E4006969BF00F4F4F400FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00E9E9
      E900A8A8A800A6A6A600A6A6A600A6A6A600A6A6A600A6A6A600A6A6A600C9C9
      C900FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00DDDDDD00A6A6A600A5A5A500A5A5A500A5A5A500A5A5A500A5A5
      A500A8A8A800F1F1F100FFFFFF00FFFFFF00FFFFFF00FFFFFF00F3F3F4007171
      BD00C9C9D100FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00D0D0
      D5007575BC00F4F4F400FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
  object scmColorMap: TStandardColorMap
    HighlightColor = clWhite
    UnusedColor = clWhite
    Color = clWindow
    MenuColor = clMenu
    Left = 408
    Top = 80
  end
end
