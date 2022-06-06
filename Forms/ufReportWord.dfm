object fmReportWord: TfmReportWord
  Left = 620
  Top = 484
  BorderIcons = []
  Caption = 'Report Word'
  ClientHeight = 102
  ClientWidth = 363
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  Visible = True
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object gProgressBar: TGauge
    Left = 0
    Top = 51
    Width = 363
    Height = 20
    Align = alBottom
    ForeColor = clBlue
    Progress = 0
    ExplicitTop = 56
    ExplicitWidth = 371
  end
  object Ole: TOleContainer
    Left = 0
    Top = 0
    Width = 363
    Height = 51
    Align = alClient
    Caption = 'Ole'
    TabOrder = 0
    Visible = False
  end
  object pCaption: TPanel
    Left = 0
    Top = 0
    Width = 363
    Height = 51
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      363
      51)
    object lCaption: TLabel
      Left = 8
      Top = 8
      Width = 354
      Height = 42
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = #1055#1086#1076#1075#1086#1090#1086#1074#1082#1072' '#1076#1072#1085#1085#1099#1093' '#1076#1083#1103' '#1087#1077#1095#1072#1090#1080
      WordWrap = True
    end
  end
  object pBottom: TPanel
    Left = 0
    Top = 71
    Width = 363
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
  end
  object sd: TSaveDialog
    DefaultExt = 'doc'
    Filter = #1044#1086#1082#1091#1084#1077#1085#1090' Microsoft Word (*.doc)|*.doc'
    Left = 32
    Top = 120
  end
end
