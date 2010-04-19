object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'rstedit'
  ClientHeight = 593
  ClientWidth = 902
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object xstMain: TSpTBXStatusBar
    Left = 0
    Top = 567
    Width = 902
    Height = 26
  end
  object pnlWrapper: TPanel
    Left = 0
    Top = 51
    Width = 902
    Height = 516
    Align = alClient
    BevelEdges = []
    BevelOuter = bvNone
    TabOrder = 1
    object synEditMain: TSynMemo
      Left = 0
      Top = 0
      Width = 469
      Height = 516
      Align = alLeft
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #65325#65331' '#12468#12471#12483#12463
      Font.Pitch = fpFixed
      Font.Style = []
      TabOrder = 2
      OnKeyPress = synEditMainKeyPress
      Gutter.Font.Charset = DEFAULT_CHARSET
      Gutter.Font.Color = clWindowText
      Gutter.Font.Height = -11
      Gutter.Font.Name = 'Courier New'
      Gutter.Font.Style = []
      Gutter.ShowLineNumbers = True
      Options = [eoAutoIndent, eoDragDropEditing, eoEnhanceEndKey, eoGroupUndo, eoShowScrollHint, eoSmartTabDelete, eoSmartTabs, eoTabIndent, eoTabsToSpaces]
      TabWidth = 2
      WantTabs = True
      OnChange = synEditMainChange
    end
    object xsplMain: TSpTBXSplitter
      Left = 469
      Top = 0
      Height = 516
      Cursor = crSizeWE
    end
    object pnlPreview: TPanel
      Left = 474
      Top = 0
      Width = 428
      Height = 516
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object wbPreview: TWebBrowser
        Left = 0
        Top = 0
        Width = 428
        Height = 516
        Align = alClient
        TabOrder = 0
        ExplicitLeft = 40
        ExplicitTop = 160
        ExplicitWidth = 300
        ExplicitHeight = 150
        ControlData = {
          4C0000003C2C0000553500000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E12620A000000000000004C0000000114020000000000C000000000000046
          8000000000000000000000000000000000000000000000000000000000000000
          00000000000000000100000000000000000000000000000000000000}
      end
    end
  end
  object mmMain: TActionMainMenuBar
    Left = 0
    Top = 0
    Width = 902
    Height = 22
    UseSystemFont = False
    ActionManager = amMain
    Caption = 'mmMain'
    ColorMap.HighlightColor = 15660791
    ColorMap.BtnSelectedColor = clBtnFace
    ColorMap.UnusedColor = 15660791
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS UI Gothic'
    Font.Style = []
    PersistentHotKeys = True
    Spacing = 0
  end
  object tbMain: TActionToolBar
    Left = 0
    Top = 22
    Width = 902
    Height = 29
    ActionManager = amMain
    Caption = 'tbMain'
    ColorMap.HighlightColor = 15660791
    ColorMap.BtnSelectedColor = clBtnFace
    ColorMap.UnusedColor = 15660791
    Spacing = 0
  end
  object pyeMain: TPythonEngine
    InitScript.Strings = (
      'import sys')
    IO = pyioMain
    OnAfterInit = pyeMainAfterInit
    Left = 104
    Top = 132
  end
  object pyioMain: TPythonInputOutput
    OnSendUniData = pyioMainSendUniData
    UnicodeIO = True
    RawOutput = True
    Left = 164
    Top = 132
  end
  object amMain: TActionManager
    ActionBars = <
      item
        Items = <
          item
            Items = <
              item
                Action = actExit
                ImageIndex = 43
              end>
            Caption = #12501#12449#12452#12523'(&F)'
          end
          item
            Items = <
              item
                Action = actCut
                ImageIndex = 0
                ShortCut = 16472
              end
              item
                Action = actCopy
                ImageIndex = 1
                ShortCut = 16451
              end
              item
                Action = actPaste
                ImageIndex = 2
                ShortCut = 16470
              end
              item
                Action = actSelectAll
                ShortCut = 16449
              end>
            Caption = #32232#38598'(&E)'
          end>
        ActionBar = mmMain
      end
      item
        Items = <
          item
            Action = actCopy
            ImageIndex = 1
            ShortCut = 16451
          end>
      end
      item
        ActionBar = tbMain
      end>
    Left = 220
    Top = 132
    StyleName = 'Platform Default'
    object actExit: TFileExit
      Category = #12501#12449#12452#12523
      Caption = #32066#20102'(&X)'
      Hint = #32066#20102'|'#12450#12503#12522#12465#12540#12471#12519#12531#12434#32066#20102#12377#12427
      ImageIndex = 43
    end
    object actCut: TEditCut
      Category = #32232#38598
      Caption = #20999#12426#21462#12426'(&T)'
      Hint = #20999#12426#21462#12426'|'#36984#25246#37096#20998#12434#20999#12426#21462#12426#12289#12463#12522#12483#12503#12508#12540#12489#12395#36865#12427
      ImageIndex = 0
      ShortCut = 16472
    end
    object actCopy: TEditCopy
      Category = #32232#38598
      Caption = #12467#12500#12540'(&C)'
      Hint = #12467#12500#12540'|'#36984#25246#31684#22258#12434#12463#12522#12483#12503#12508#12540#12489#12395#12467#12500#12540
      ImageIndex = 1
      ShortCut = 16451
    end
    object actPaste: TEditPaste
      Category = #32232#38598
      Caption = #36028#12426#20184#12369'(&P)'
      Hint = #36028#12426#20184#12369'|'#12463#12522#12483#12503#12508#12540#12489#12398#20869#23481#12434#36028#12426#20184#12369#12427
      ImageIndex = 2
      ShortCut = 16470
    end
    object actSelectAll: TEditSelectAll
      Category = #32232#38598
      Caption = #12377#12409#12390#12434#36984#25246'(&A)'
      Hint = #12377#12409#12390#12434#36984#25246'|'#12489#12461#12517#12513#12531#12488#20840#20307#12434#36984#25246#12377#12427
      ShortCut = 16449
    end
  end
  object timPreview: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = timPreviewTimer
    Left = 276
    Top = 132
  end
end
