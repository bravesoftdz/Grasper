object ViewRules: TViewRules
  Left = 0
  Top = 0
  Caption = 'Parse It All! Rules'
  ClientHeight = 405
  ClientWidth = 691
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
    Top = 0
    Width = 441
    Height = 405
    Align = alLeft
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'pnlBrowser'
    TabOrder = 0
    object Splitter: TSplitter
      Left = 1
      Top = 221
      Width = 439
      Height = 2
      Cursor = crVSplit
      Align = alBottom
      Visible = False
      ExplicitTop = 213
    end
    object chrmBrowser: TChromium
      Left = 1
      Top = 1
      Width = 439
      Height = 220
      Align = alClient
      DefaultUrl = 'about:blank'
      TabOrder = 0
    end
    object chdtDevTools: TChromiumDevTools
      Left = 1
      Top = 223
      Width = 439
      Height = 181
      Align = alBottom
      Visible = False
    end
  end
  object pnlControls: TPanel
    Left = 441
    Top = 0
    Width = 250
    Height = 405
    Align = alClient
    TabOrder = 1
    object pnlLevel: TPanel
      Left = 1
      Top = 1
      Width = 248
      Height = 40
      Align = alTop
      TabOrder = 0
      object lbllevel: TLabel
        Left = 119
        Top = 12
        Width = 25
        Height = 13
        Caption = 'Level'
      end
      object cbbLevel: TComboBox
        Left = 152
        Top = 8
        Width = 81
        Height = 21
        Style = csDropDownList
        TabOrder = 0
      end
      object btnAddLevel: TBitBtn
        Left = 15
        Top = 6
        Width = 75
        Height = 25
        Caption = 'btnAddL'
        Enabled = False
        TabOrder = 1
        OnClick = btnAddLevelClick
      end
    end
    object pnlTree: TPanel
      Left = 1
      Top = 41
      Width = 248
      Height = 160
      Align = alTop
      Caption = 'pnlTree'
      TabOrder = 1
      object tvTree: TTreeView
        Left = 1
        Top = 38
        Width = 246
        Height = 121
        Align = alBottom
        Images = ilIcons
        Indent = 35
        ReadOnly = True
        TabOrder = 0
        OnChange = tvTreeChange
      end
      object btnAG: TBitBtn
        Left = 8
        Top = 4
        Width = 33
        Height = 25
        Caption = 'btnAG'
        TabOrder = 1
        OnClick = btnAGClick
      end
      object btnAL: TBitBtn
        Left = 88
        Top = 4
        Width = 33
        Height = 25
        Caption = 'btnAL'
        TabOrder = 2
        OnClick = btnALClick
      end
      object btnDG: TBitBtn
        Left = 44
        Top = 4
        Width = 33
        Height = 25
        Caption = 'btnDG'
        TabOrder = 3
        OnClick = btnDGClick
      end
      object btnDL: TBitBtn
        Left = 123
        Top = 4
        Width = 33
        Height = 25
        Caption = 'btnDL'
        TabOrder = 4
        OnClick = btnDLClick
      end
      object btnAR: TBitBtn
        Left = 167
        Top = 4
        Width = 33
        Height = 25
        Caption = 'btnAR'
        TabOrder = 5
        OnClick = btnARClick
      end
      object btnDR: TBitBtn
        Left = 202
        Top = 4
        Width = 33
        Height = 25
        Caption = 'btnDR'
        TabOrder = 6
        OnClick = btnDRClick
      end
    end
    object pnlFields: TPanel
      Left = 1
      Top = 265
      Width = 248
      Height = 98
      Align = alClient
      TabOrder = 2
    end
    object pnlXPath: TPanel
      Left = 1
      Top = 201
      Width = 248
      Height = 64
      Align = alTop
      Caption = 'pnlXPath'
      TabOrder = 3
      Visible = False
      object btnSelectHTML: TBitBtn
        Left = 15
        Top = 20
        Width = 75
        Height = 25
        Caption = 'btnSelectHTML'
        TabOrder = 0
        OnClick = btnSelectHTMLClick
      end
      object udContainerStep: TUpDown
        Left = 157
        Top = 10
        Width = 17
        Height = 43
        TabOrder = 1
        OnClick = udContainerStepClick
      end
    end
    object pnlButtons: TPanel
      Left = 1
      Top = 363
      Width = 248
      Height = 41
      Align = alBottom
      TabOrder = 4
      DesignSize = (
        248
        41)
      object btnCancel: TButton
        Left = 152
        Top = 9
        Width = 75
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = 'btnCancel'
        TabOrder = 0
        OnClick = btnCancelClick
      end
      object btnApply: TButton
        Left = 16
        Top = 9
        Width = 75
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = 'btnApply'
        TabOrder = 1
        OnClick = btnApplyClick
      end
    end
  end
  object ilIcons: TImageList
    ColorDepth = cd32Bit
    Left = 32
    Top = 32
    Bitmap = {
      494C010103005C00A40010001000FFFFFFFF2110FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000001000004180A00502D1500962B3315B8213D1EB826190596130900500100
      0004000000000000000000000000000000000000000000000000000000000000
      000000000000000000000109091E17B2D7F317B3DBF503121530000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000100040413000405150004
      0515000405150004051500040515000405150004051500040515000405150004
      051500040515000405150004041300000001000000000000000000000000190C
      0045532800DD5F2D00FF444A18FF00BB65FF00C66EFF137B3EFF452B08FF391C
      00DD100800450000000000000000000000000000000000000000000101080E59
      6B911285A0BF01090B1E0737436A18C4EFFD18C4EFFD094C5C7E010606161076
      8FB10D57698D0001010600000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000010748DAE18BAE1FC18BAE2FC18BA
      E2FC18BAE2FC18BAE2FC18BAE2FC18BAE2FC18BAE2FC18BAE2FC18BAE2FC18BA
      E2FC18BAE2FC18BAE2FC18BAE1FC10748FAE0000000000000000291300647539
      00FC783A00FF7A3B00FF446726FF00D681FF00DE8CFF00A656FF4B3408FF442E
      09FF442100FC190C006400000000000000000000000000000000031F274C19C4
      EDFD19C5F0FD18B1D4EB16A3C4D919C8F3FF1AC8F3FF17AACDE117A7CAE119C5
      F0FD19C4EDFD062C365C00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000019C4EFFD19C6F1FE19C7F2FF19C7
      F2FF19C7F2FF19C7F2FF19C7F2FF19C7F2FF19C7F2FF19C7F2FF19C7F2FF19C7
      F2FF19C7F2FF19C7F2FF19C6F1FE19C4EFFD00000000190C003D753900FB823F
      00FF894200FF75500DFF07B461FF00DD8AFF00DE8BFF01AF5DFF613F09FF5F2E
      00FF502600FF442100FB0F06003D0000000000000000000000000003030C1ABC
      E3F11BC9F3FF1BC9F3FF1BC9F3FF1BC9F3FF1BC9F3FF1BC9F3FF1BC9F3FF1BC9
      F3FF1AC3EBF90107091800000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000001BC8F2FE1BC8F2FE1BC9F4FF1BC9
      F4FF1BC9F4FF1BC9F4FF1BC9F4FF1BC9F4FF1BC9F4FF1BC9F4FF1BC9F4FF1BC9
      F4FF1BC9F4FF1BC9F4FF1BC8F2FE1BC8F2FE000000016F3700D18D4600FF8454
      11FF68631FFF1F994CFF00D47EFF00DF8BFF00DB87FF00BC65FF29632BFF6F36
      00FF602E00FF4F2600FF371A00D1000000010107091E082D3968082C366217A2
      C4D31CCAF4FF1CCAF4FF1CC8F1FD1CC7F0FD1CC7F0FD1CC8F1FD1CCAF4FF1CCA
      F4FF19AED3E1082F3A62082D38680007081C0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000001DCBF5FF1DCBF5FF1DCBF5FF1DCB
      F5FF1DCBF5FF1DCBF5FF1DCBF5FF1DCBF5FF1DCBF5FF1DCBF5FF1DCBF5FF1DCB
      F5FF1DCBF5FF1DCBF5FF1DCBF5FF1DCBF5FF1B0E003C9A4F03FF6B681EFF00A8
      58FF02C16CFF1FD78BFF34E4A0FF3EE3A2FF3ECE8FFF557E3FFF315725FF713F
      05FF6F3600FF592B00FF492300FF0E07003C0F5C6F8F1DC6F1FD1DC7F2FD1DCA
      F5FF1DCAF5FF1DC4EEF90C51617801080A1A00080A1C0B51627A1DC4EEF91DCA
      F5FF1DCAF5FF1DC7F2FD1DC6F1FD0E5B6F8D0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000001FCCF6FF1FCCF6FF1FCCF6FF1FCC
      F6FF1FCCF6FF1FCCF6FF1FCCF6FF1FCCF6FF1FCCF6FF1FCCF6FF1FCCF6FF1FCC
      F6FF1FCCF6FF1FCCF6FF1FCCF6FF1FCCF6FF4B27037CAD5E0AFF4C8432FF16D3
      84FF54E7ACFF5EE9B1FF5EE7B0FF5ED6A0FF7A9258FF6B9C71FF767B4FFF8E50
      13FF743B03FF5F2E00FF4D2701FF210F007C1277919F1FC8F3FD1FCBF6FF1FCC
      F6FF1FC9F3FD0B505F76000000000000000000000000000000000B51627A1FC9
      F3FD1FCCF6FF1FCBF6FF1FC8F3FD147F9BA70000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000020CCF6FE20CCF6FE20CDF7FF20CD
      F7FF20CDF7FF20CDF7FF20CDF7FF20CDF7FF20CDF7FF20CDF7FF20CDF7FF20CD
      F7FF20CDF7FF20CDF7FF20CDF7FF20CDF7FF6839079AC07011FF6F9141FF6EE3
      B1FF73E9B8FF73E7B6FF73E3B3FF73C699FF7ABA8EFF74BB8FFF82895DFF9360
      26FF895018FF484518FF353510FF2718049A000000020B4959701FC5EEF721CC
      F7FF20C9F2FD0108091A0000000000000000000000000000000000080A1C20C9
      F2FD21CCF7FF20CAF4FD0D586B7E000101060000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000021CBF5FD21CCF6FE22CEF8FF22CE
      F8FF22CEF8FF22CEF8FF22CEF8FF22CEF8FF22CEF8FF22CEF8FF22CEF8FF22CE
      F8FF22CEF8FF22CEF8FF22CEF8FF22CEF8FF6C3F0B96CE8017FFC79B3DFF87D5
      AFFF89DAB4FF9BC187FF9AB77CFF86B78BFF89D7B0FF8CB388FF89B896FF8C99
      70FF84956CFF5FB187FF2B4517FF151F0C96000000020B404D7020C4EDF722CD
      F7FF21CAF3FD0107081A000000000000000000000000000000000007091C21CA
      F3FD22CDF7FF21CAF4FD0E4E5D7E000101060000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000001DADDFEC23CCF7FE23CEF8FF23CE
      F8FF23CEF8FF23CEF8FF23CEF8FF23CEF8FF23CEF8FF24CFF9FF24CFF9FF24CF
      F9FF24CFF9FF24CFF9FF24CFF9FF24CFF9FF55330A70D78D20FFE8AE46FFBAAC
      65FFCABB68FFEBBE58FFB2A76CFFA3B07EFF9DE5C4FF9DE9C7FF9DEAC8FF9DE6
      C5FF9DE7C5FF9CE4C3FF265B2DFF03180B701570879F23CAF3FD23CEF8FF23CE
      F8FF23CBF5FD0D465676000000000000000000000000000000000D49587A23CB
      F5FD23CEF8FF23CEF8FF23CAF4FD167992A70000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000188CD5EB1B9AE8FE1B9CE9FF1B9C
      E9FF1B9CE9FF1B9DE9FF1FABEEFF24CAF7FF25CFF9FF26D0FAFF26D0FAFF26D0
      FAFF26D0FAFF26D0FAFF26D0FAFF26D0FAFF180E0426DA9225FEECB950FFB9B7
      81FFB6BF99FFBEBC7EFFACC5A6FFAEDCC3FFB2EFD4FFB2F2D6FFB2F2D6FFB2F2
      D6FFB2F2D6FFB2EED3FF1A804CFE0107032711657A8F24CCF5FD24CDF6FD24CF
      F9FF24CFF9FF23C5ECF90F4755780207071A0107081C0E47557A23C5EDF924CF
      F9FF24CFF9FF24CDF7FD24CCF5FD12657A8D0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000001D90D9E8209DEDFE219EEEFE219F
      EFFF219FEFFF219FEFFF219FEFFF23A9F2FF27D0FAFF27D1FAFF28D1FBFF28D1
      FBFF28D1FBFF28D1FBFF28D0FAFE28D0FAFE00000000976519B1EBB551FFDBBD
      60FFB0C9B2FFC6E9D8FFC6F0DCFFC6F3DEFFC6F4DFFFC6F5DFFFC6F5DFFFC6F5
      DFFFC6F4DFFFC2EEDAFF074C29B20000000001090B1E0A3A4568093641621EA8
      CAD326D0F9FF25D0F9FF25CCF6FD25C7EEFD25C7EEFD25CCF6FD25D0F9FF26D0
      F9FF22B5D9E10B3944620A39456801080A1C0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000001352798C269FECF927A1EFFC27A1
      EFFC27A1EFFC27A1EFFC27A1EFFC27A2EFFC28B9F4FD29CFF8FD29D1FAFE29D2
      FBFE29D3FCFF29D3FCFF29D1FAFE29D0F9FD00000000160D031ECF9738EBDAB4
      5FFFC6B36BFFC8DBC1FFD7F3E6FFD8F7E8FFD8F7E8FFD8F7E8FFD8F7E8FFD8F7
      E8FFD8F6E7FF8AB39EEC0008041F0000000000000000000000000003030C25C0
      E5F127D1FAFF27D1FBFF27D1FAFF27D1FAFF27D1FAFF27D1FAFF27D1FBFF27D1
      FAFF26C9F1F90106091800000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000100000002000001020000
      01020000010200000102000001020000010200000105166D819129C8EFF52ACE
      F6FC2ACEF6FC2ACEF6FC2ACEF6FC1D8BA5AE0000000000000000281C0834A28D
      59E9E4B868FFCCB377FFBFC29FFFE7F8F0FFE7FAF1FFE7FAF1FFE7FAF1FFE7F8
      F0FFC4D3CAE9121C1535000000000000000000000000000000000620274C28CD
      F6FD28CFF9FD25BFE6EB22B2D4D928D1FBFF28D1FBFF24B8DCE124B8DCE128CF
      F8FD28CDF7FD0A2F385C00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000001000202090106
      0614000506150005061500040613000000010000000000000000000000000F0A
      04196E6954A2C1A777FAC0B390FFD6D6C3FFEEF7F2FFF4FCF8FFE6EFEBFA7A86
      7FA3090D0A190000000000000000000000000000000000000000000202081669
      7E911E98B6BF010B0F1E0C404C6A29CFF8FD29D0F9FD1056677E010708161B8A
      A7B116697D8D0001010600000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000070706163D260E56573716784F4E4078323A3357070907160000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000010B0D1E29C8EEF32AC9F1F505151A30000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFF00FFC3F00000000E007C0030000
      0000C003C003000000008001C003000000000000000000000000000000000000
      0000000003C000000000000003C000000000000003C000000000000003C00000
      0000000000000000000080010000000000008001C00300000000C003C0030000
      FF80E007C0030000FFFFF81FFC3F000000000000000000000000000000000000
      000000000000}
  end
  object ActionList: TActionList
    Left = 88
    Top = 32
    object acDevToolsActivate: TAction
      Caption = 'acDevToolsActivate'
      ShortCut = 123
      OnExecute = DevToolsActivate
    end
  end
end
