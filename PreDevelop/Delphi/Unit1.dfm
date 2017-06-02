object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Parse It All!'
  ClientHeight = 500
  ClientWidth = 721
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblJobs: TLabel
    Left = 8
    Top = 2
    Width = 22
    Height = 13
    Caption = 'Jobs'
  end
  object lblZeroLink: TLabel
    Left = 287
    Top = 2
    Width = 43
    Height = 13
    Caption = 'Zero Link'
  end
  object lbl1: TLabel
    Left = 616
    Top = 2
    Width = 30
    Height = 13
    Caption = 'Levels'
  end
  object lblRules: TLabel
    Left = 112
    Top = 109
    Width = 26
    Height = 13
    Caption = 'Rules'
  end
  object bvl1: TBevel
    Left = 8
    Top = 105
    Width = 705
    Height = 1
    Style = bsRaised
  end
  object lblNodes: TLabel
    Left = 11
    Top = 280
    Width = 30
    Height = 13
    Caption = 'Nodes'
  end
  object lblGroups: TLabel
    Left = 11
    Top = 109
    Width = 34
    Height = 13
    Caption = 'Groups'
  end
  object btnStartJob: TButton
    Left = 8
    Top = 472
    Width = 75
    Height = 25
    Caption = 'btnStartJob'
    TabOrder = 0
    OnClick = btnStartJobClick
  end
  object dbgrdJobs: TDBGrid
    Left = 8
    Top = 18
    Width = 273
    Height = 81
    DataSource = dsJobs
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'caption'
        Title.Alignment = taCenter
        Width = 230
        Visible = True
      end>
  end
  object dbgrdLevels: TDBGrid
    Left = 616
    Top = 18
    Width = 97
    Height = 81
    DataSource = dsLevels
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'level'
        Title.Alignment = taCenter
        Width = 60
        Visible = True
      end>
  end
  object dbgrdNodes: TDBGrid
    Left = 8
    Top = 295
    Width = 432
    Height = 171
    DataSource = dsNodes
    TabOrder = 3
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'tag'
        Title.Alignment = taCenter
        Width = 60
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'index'
        Title.Alignment = taCenter
        Width = 50
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'tag_id'
        Title.Alignment = taCenter
        Width = 100
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'class'
        Title.Alignment = taCenter
        Width = 100
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'name'
        Title.Alignment = taCenter
        Width = 80
        Visible = True
      end>
  end
  object dbmmoZeroLink: TDBMemo
    Left = 287
    Top = 18
    Width = 323
    Height = 81
    DataField = 'zero_link'
    DataSource = dsJobs
    TabOrder = 4
  end
  object dbgrdRules: TDBGrid
    Left = 111
    Top = 124
    Width = 300
    Height = 151
    DataSource = dsRules
    TabOrder = 5
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'description'
        Title.Alignment = taCenter
        Width = 160
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'container_offset'
        Title.Alignment = taCenter
        Width = 100
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'critical_type'
        Title.Alignment = taCenter
        Width = 100
        Visible = True
      end>
  end
  object mmo1: TMemo
    Left = 450
    Top = 295
    Width = 260
    Height = 171
    TabOrder = 6
  end
  object btnParseNodes: TButton
    Left = 537
    Top = 472
    Width = 94
    Height = 25
    Caption = 'btnParseNodes'
    TabOrder = 7
    OnClick = btnParseNodesClick
  end
  object pgcRulesSlaves: TPageControl
    Left = 416
    Top = 108
    Width = 297
    Height = 167
    ActivePage = tsRegExp
    TabOrder = 8
    object tsLink: TTabSheet
      Caption = 'tsLink'
      object dbgrdLinks: TDBGrid
        Left = 32
        Top = 8
        Width = 127
        Height = 120
        DataSource = dslink
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'level'
            Title.Alignment = taCenter
            Width = 70
            Visible = True
          end>
      end
    end
    object tsRecord: TTabSheet
      Caption = 'tsRecord'
      ImageIndex = 1
      object dbgrdRecords: TDBGrid
        Left = 30
        Top = 8
        Width = 154
        Height = 120
        DataSource = dsRecord
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'key'
            Title.Alignment = taCenter
            Width = 110
            Visible = True
          end>
      end
    end
    object tsRegExp: TTabSheet
      Caption = 'tsRegExp'
      ImageIndex = 2
      object dbgrdRegExps: TDBGrid
        Left = 14
        Top = 10
        Width = 263
        Height = 120
        DataSource = dsRegExps
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'regexp'
            Title.Alignment = taCenter
            Width = 150
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'type_refid'
            Title.Alignment = taCenter
            Visible = True
          end>
      end
    end
  end
  object dbgrd1: TDBGrid
    Left = 8
    Top = 124
    Width = 97
    Height = 151
    DataSource = dsGroups
    TabOrder = 9
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'notes'
        Title.Alignment = taCenter
        Width = 66
        Visible = True
      end>
  end
  object btnTest: TButton
    Left = 112
    Top = 472
    Width = 75
    Height = 25
    Caption = 'btnTest'
    TabOrder = 10
    OnClick = btnTestClick
  end
  object fdtblJobs: TFDTable
    UpdateOptions.UpdateTableName = 'jobs'
    TableName = 'jobs'
    Left = 184
    Top = 48
  end
  object dsJobs: TDataSource
    DataSet = fdtblJobs
    Left = 128
    Top = 48
  end
  object fdtblLevels: TFDTable
    IndexName = 'job_id'
    MasterSource = dsJobs
    MasterFields = 'id'
    Left = 672
    Top = 48
  end
  object dsLevels: TDataSource
    DataSet = fdtblLevels
    Left = 624
    Top = 48
  end
  object fdtblRules: TFDTable
    IndexName = 'group_id'
    MasterSource = dsGroups
    MasterFields = 'id'
    Left = 240
    Top = 176
  end
  object dsRules: TDataSource
    DataSet = fdtblRules
    Left = 184
    Top = 176
  end
  object fdtblLink: TFDTable
    IndexName = 'job_rule_id'
    MasterSource = dsRules
    MasterFields = 'id'
    Left = 552
    Top = 120
  end
  object dslink: TDataSource
    DataSet = fdtblLink
    Left = 552
    Top = 176
  end
  object fdtblRecord: TFDTable
    IndexName = 'job_rule_id'
    MasterSource = dsRules
    MasterFields = 'id'
    Left = 608
    Top = 120
  end
  object dsRecord: TDataSource
    DataSet = fdtblRecord
    Left = 608
    Top = 176
  end
  object dsNodes: TDataSource
    DataSet = fdtblNodes
    Left = 40
    Top = 368
  end
  object fdtblNodes: TFDTable
    IndexName = 'job_rule_id'
    MasterSource = dsRules
    MasterFields = 'id'
    Left = 96
    Top = 368
  end
  object dsRegExps: TDataSource
    DataSet = fdtblRegExps
    Left = 672
    Top = 176
  end
  object fdtblRegExps: TFDTable
    IndexName = 'job_rule_id'
    MasterSource = dsRules
    MasterFields = 'id'
    Left = 672
    Top = 120
  end
  object fdtblGroups: TFDTable
    IndexName = 'job_level_id'
    MasterSource = dsLevels
    MasterFields = 'id'
    Left = 40
    Top = 168
  end
  object dsGroups: TDataSource
    DataSet = fdtblGroups
    Left = 40
    Top = 224
  end
end
