object frmVersion: TfrmVersion
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'rstedit '#12398#12496#12540#12472#12519#12531#24773#22577
  ClientHeight = 150
  ClientWidth = 335
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblVersionString: TLabel
    Left = 56
    Top = 32
    Width = 225
    Height = 17
    Alignment = taCenter
    AutoSize = False
    Transparent = True
  end
  object lblCopyright: TLabel
    Left = 56
    Top = 68
    Width = 225
    Height = 17
    Alignment = taCenter
    AutoSize = False
    Transparent = True
  end
  object btnOk: TButton
    Left = 127
    Top = 112
    Width = 83
    Height = 30
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
end
