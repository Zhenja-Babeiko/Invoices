object fmAddDictProduct: TfmAddDictProduct
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #1057#1086#1079#1076#1072#1085#1080#1077' '#1087#1088#1086#1075#1088#1072#1084#1084#1085#1086#1075#1086' '#1087#1088#1086#1076#1091#1082#1090#1072
  ClientHeight = 220
  ClientWidth = 407
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
    Width = 269
    Height = 15
    Caption = #1055#1086#1083#1085#1086#1077' '#1085#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '#1087#1088#1086#1075#1088#1072#1084#1084#1085#1086#1075#1086' '#1087#1088#1086#1076#1091#1082#1090#1072':'
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
    Width = 184
    Height = 15
    Caption = #1050#1088#1072#1090#1082#1086#1077' '#1085#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '#1087#1088#1086#1076#1091#1082#1090#1072':'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 16
    Top = 127
    Width = 117
    Height = 15
    Caption = #1055#1091#1073#1083#1080#1095#1085#1099#1081' '#1076#1086#1075#1086#1074#1086#1088':'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 32
    Top = 148
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
  object Label5: TLabel
    Left = 168
    Top = 148
    Width = 28
    Height = 15
    Caption = #1044#1072#1090#1072':'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object edNAME_PROG_FULL: TDBEditEh
    Left = 32
    Top = 45
    Width = 353
    Height = 21
    DataField = 'name_prog_full'
    DataSource = dsProduct
    DynProps = <>
    EditButtons = <>
    MaxLength = 100
    TabOrder = 0
    Visible = True
    OnChange = ChangeData
  end
  object edNAME_PROG_SHORT: TDBEditEh
    Left = 32
    Top = 100
    Width = 353
    Height = 21
    DataField = 'name_prog_short'
    DataSource = dsProduct
    DynProps = <>
    EditButtons = <>
    MaxLength = 50
    TabOrder = 1
    Visible = True
    OnChange = ChangeData
  end
  object btnAdd: TBitBtn
    Left = 246
    Top = 183
    Width = 139
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 2
    OnClick = btnAddClick
  end
  object btnClose: TBitBtn
    Left = 16
    Top = 183
    Width = 169
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 3
  end
  object edNUM_DOC: TDBEditEh
    Left = 79
    Top = 146
    Width = 66
    Height = 21
    DataField = 'num_doc'
    DataSource = dsProduct
    DynProps = <>
    EditButtons = <>
    MaxLength = 50
    TabOrder = 4
    Visible = True
    OnChange = ChangeData
  end
  object edDATE_DOC: TDBDateTimeEditEh
    Left = 208
    Top = 146
    Width = 177
    Height = 21
    DataField = 'date_doc'
    DataSource = dsProduct
    DynProps = <>
    EditButtons = <>
    Kind = dtkDateEh
    TabOrder = 5
    Visible = True
  end
  object mtProduct: TEnMemTable
    Params = <>
    Left = 260
    Top = 53
  end
  object dsProduct: TDataSource
    DataSet = mtProduct
    Left = 316
    Top = 52
  end
end
