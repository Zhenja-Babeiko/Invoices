object fmAddDictCost: TfmAddDictCost
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #1044#1086#1073#1072#1074#1083#1077#1085#1080#1077' '#1079#1072#1087#1080#1089#1080' '#1074' '#1089#1087#1088#1072#1074#1086#1095#1085#1080#1082' '#1091#1089#1083#1091#1075
  ClientHeight = 265
  ClientWidth = 398
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnActivate = FormActivate
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 16
    Top = 24
    Width = 126
    Height = 15
    Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '#1091#1089#1083#1091#1075#1080':'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label1: TLabel
    Left = 16
    Top = 79
    Width = 112
    Height = 15
    Caption = #1045#1076#1080#1085#1080#1094#1072' '#1080#1079#1084#1077#1088#1077#1085#1080#1103':'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 16
    Top = 106
    Width = 180
    Height = 15
    Caption = #1057#1090#1086#1080#1084#1086#1089#1090#1100' '#1077#1076#1077#1085#1080#1094#1099' '#1091#1089#1083#1091#1075#1080', '#1088#1091#1073':'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 16
    Top = 193
    Width = 75
    Height = 15
    Caption = #1044#1072#1090#1072' '#1087#1088#1080#1082#1072#1079#1072':'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label5: TLabel
    Left = 16
    Top = 138
    Width = 132
    Height = 15
    Caption = #1055#1088#1086#1075#1088#1072#1084#1084#1085#1099#1081' '#1087#1088#1086#1076#1091#1082#1090':'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label6: TLabel
    Left = 16
    Top = 166
    Width = 120
    Height = 15
    Caption = #1053#1086#1084#1077#1088' '#1087#1088#1077#1081#1089#1082#1091#1088#1072#1085#1090#1072':'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label7: TLabel
    Left = 254
    Top = 193
    Width = 41
    Height = 15
    Caption = #1053#1086#1084#1077#1088':'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object edNAME_PROG_POINT: TDBEditEh
    Left = 32
    Top = 45
    Width = 353
    Height = 21
    DataField = 'name_prog_point'
    DataSource = dsCost
    DynProps = <>
    EditButtons = <>
    MaxLength = 200
    TabOrder = 0
    Visible = True
    OnChange = ChangeData
  end
  object edNAME_UNIT: TDBEditEh
    Left = 133
    Top = 77
    Width = 124
    Height = 21
    DataField = 'name_unit'
    DataSource = dsCost
    DynProps = <>
    EditButtons = <>
    MaxLength = 50
    TabOrder = 1
    Visible = True
    OnChange = ChangeData
  end
  object edCOST_ONE: TDBEditEh
    Left = 202
    Top = 104
    Width = 103
    Height = 21
    DataField = 'cost_one'
    DataSource = dsCost
    DynProps = <>
    EditButtons = <>
    MaxLength = 8
    TabOrder = 2
    Visible = True
    OnChange = ChangeData
  end
  object eCODE_PROG: TEnComboBox
    Left = 154
    Top = 136
    Width = 231
    Height = 21
    DynProps = <>
    DataField = 'code_prog'
    DataSource = dsCost
    DropDownBox.Sizable = True
    EditButtons = <>
    KeyField = 'code_prog'
    ListField = 'name_prog_full'
    TabOrder = 3
    Visible = True
    OnChange = ChangeData
  end
  object btnAdd: TBitBtn
    Left = 246
    Top = 232
    Width = 139
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 4
    OnClick = btnAddClick
  end
  object btnClose: TBitBtn
    Left = 16
    Top = 232
    Width = 169
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 5
  end
  object edDATE_START: TcxDBDateEdit
    Left = 97
    Top = 191
    DataBinding.DataField = 'date_start'
    DataBinding.DataSource = dsCost
    TabOrder = 6
    Width = 151
  end
  object edNUM_PRICE: TDBEditEh
    Left = 144
    Top = 164
    Width = 103
    Height = 21
    DataField = 'num_price'
    DataSource = dsCost
    DynProps = <>
    EditButtons = <>
    MaxLength = 8
    TabOrder = 7
    Visible = True
    OnChange = ChangeData
  end
  object edNUM_ORDER: TDBEditEh
    Left = 301
    Top = 191
    Width = 65
    Height = 21
    DataField = 'num_order'
    DataSource = dsCost
    DynProps = <>
    EditButtons = <>
    MaxLength = 8
    TabOrder = 8
    Visible = True
    OnChange = ChangeData
  end
  object dsCost: TDataSource
    DataSet = mtCost
    Left = 300
    Top = 20
  end
  object mtCost: TEnMemTable
    Params = <>
    Left = 244
    Top = 21
  end
end
