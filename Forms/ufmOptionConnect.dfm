object fmSettingConnDB: TfmSettingConnDB
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '#1082' '#1041#1044
  ClientHeight = 133
  ClientWidth = 362
  Color = clBtnFace
  Constraints.MaxHeight = 172
  Constraints.MaxWidth = 378
  Constraints.MinHeight = 172
  Constraints.MinWidth = 378
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
  object pnlDirect: TPanel
    Left = 2
    Top = 2
    Width = 353
    Height = 89
    TabOrder = 0
    object lbl3: TLabel
      Left = 8
      Top = 48
      Width = 30
      Height = 13
      Caption = #1055#1086#1088#1090':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lbl4: TLabel
      Left = 179
      Top = 48
      Width = 41
      Height = 13
      Caption = #1057#1077#1088#1074#1080#1089':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lbl2: TLabel
      Left = 8
      Top = 10
      Width = 110
      Height = 13
      Caption = #1048#1084#1103' ('#1072#1076#1088#1077#1089') '#1089#1077#1088#1074#1077#1088#1072':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object edServerName: TEdit
      Left = 120
      Top = 8
      Width = 217
      Height = 23
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object edPort: TEdit
      Left = 40
      Top = 45
      Width = 121
      Height = 23
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
    object edServices: TEdit
      Left = 223
      Top = 45
      Width = 114
      Height = 23
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
  end
  object btnSave: TcxButton
    Left = 8
    Top = 97
    Width = 175
    Height = 26
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1080' '#1079#1072#1082#1088#1099#1090#1100
    OptionsImage.Glyph.SourceDPI = 96
    OptionsImage.Glyph.Data = {
      89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
      6100000020744558745469746C65005361766520416E6420436C6F73653B5361
      76653B436C6F73653B2A84087B0000024C49444154785E75D33F68144D18C7F1
      EFDEED269E202A0653596817780BC1888824A4B0502B0B3BA322DAAA85228816
      510441C142109B681304C1EA2DB4500362D02609A282A22068506372C9E52E77
      97FD33CFCCE3663CF48AF307BFDD811DD8CF2CCF86AA4AA7047980225000820E
      5B1C2021FF4E3879E2E478542C0EE01C6880AA0517E0D4918999D87D7F6C6FD8
      7A936F3B00E8269381AD07FB89976A445D116A0C49ADC19A52179F9EBD1F00C2
      10088E9FBD390EC150BD3C8F538BB30E6332E2F20CCDA9D76CBC7C9BD9EB2380
      D27B6E849F47F791544B00851028A832B473C77F3C7DF484D13B575055EAF53A
      9F0F1F43162B94AF5D64F3F9AB289AAF2F20CB0DD2150F0EBCC0398B18C18AC1
      3965AEB2C2F27293344E909AC5AC8FB14E5194B499601B0DB238FA23089CB518
      91BC06B18E4C2CBECD986CA949EFDD1BCC9D1AF6B29E5B637C1FECCB05A5BF02
      6B9D17888817187118EBC8E214A9ADF075D73650409519BF564C9C02F0479089
      60F30E1F398D558B988C3D5D6BF9315F44751D3E0A0AF4C44D9A9ABC04CC6F81
      08C6087DDBFB3DD3A134961679B361131FA2105451877FB6502933F9FCC116A0
      0A245E20AB82D4303FFB8D87F7AED229070E9DA1187553F4A7A6AAAA8DBF4710
      418CF10558A8256D6405F073512884586B010AB4E205620C66B55906782A0AB4
      2E280126CD08A3921FB2F6A96DFF067ED3A5FF3F224EB196D63DAF2A26331492
      18E7BC40DB0552AF565EBC9D9E1AEC8A42DE4D7F416C409619D244F2C6F888C1
      D6EB18934E00D22E485F8D8FED07224F7B3C8A4FE75F580103A4B4F20B144D85
      58E989FE470000000049454E44AE426082}
    TabOrder = 1
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    OnClick = btnSaveClick
  end
  object btnClose: TcxButton
    Left = 215
    Top = 97
    Width = 140
    Height = 26
    Caption = #1047#1072#1082#1088#1099#1090#1100
    OptionsImage.Glyph.SourceDPI = 96
    OptionsImage.Glyph.Data = {
      89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
      610000001974455874536F6674776172650041646F626520496D616765526561
      647971C9653C00000023744558745469746C650043616E63656C3B53746F703B
      457869743B426172733B526962626F6E3B4C9696B20000009449444154785E95
      93410A834010047D5C2027F3093F104C6461C5CD37F312C5D3641AD27810BAF1
      5030CC587510B68B88EE3BDCFAA46236F0FB190E66CA7B12C9125EFE24F1771E
      584C9009234626230FE514F1F21B2E8E22A2650654A42999011951320322A265
      E0FFF6411301219B88935F49511129F3A622567611C8B3905DA462794FD693EC
      231B5C2C19795E78CE131CCC3FD2409CCC2C3656140000000049454E44AE4260
      82}
    TabOrder = 2
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    OnClick = btnCloseClick
  end
end
