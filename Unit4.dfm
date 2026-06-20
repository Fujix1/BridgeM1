object Form4: TForm4
  Left = 449
  Top = 246
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Options'
  ClientHeight = 443
  ClientWidth = 434
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDefault
  SnapBuffer = 8
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    434
    443)
  TextHeight = 14
  object btnOK: TBitBtn
    Left = 274
    Top = 411
    Width = 72
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 1
    NumGlyphs = 2
    ParentFont = False
    TabOrder = 1
    OnClick = btnOKClick
    ExplicitLeft = 276
  end
  object BitBtn2: TBitBtn
    Left = 352
    Top = 411
    Width = 72
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 2
    NumGlyphs = 2
    ParentFont = False
    TabOrder = 2
    OnClick = BitBtn2Click
    ExplicitLeft = 354
  end
  object btnDefault: TButton
    Left = 9
    Top = 411
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Defaults'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = btnDefaultClick
  end
  object PageControl1: TPageControl
    Left = 5
    Top = 5
    Width = 425
    Height = 398
    ActivePage = TabSheet2
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Directories'
      object GroupBox1: TGroupBox
        Left = 9
        Top = 6
        Width = 400
        Height = 147
        Caption = 'ROM Directories'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object ListBox1: TListBox
          Left = 12
          Top = 20
          Width = 290
          Height = 111
          Hint = 'Drag '#39'n drop to change priority'
          Style = lbOwnerDrawVariable
          Color = clBtnHighlight
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemHeight = 12
          ParentFont = False
          ParentShowHint = False
          ShowHint = False
          TabOrder = 0
          OnClick = ListBox1Click
          OnDrawItem = ListBox1DrawItem
          OnMeasureItem = ListBox1MeasureItem
          OnMouseDown = ListBox1MouseDown
          OnMouseMove = ListBox1MouseMove
          OnMouseUp = ListBox1MouseUp
        end
        object btnAdd: TButton
          Left = 313
          Top = 20
          Width = 75
          Height = 25
          Caption = '&Add...'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = btnAddClick
        end
        object btnDelete: TButton
          Left = 313
          Top = 52
          Width = 75
          Height = 25
          Caption = '&Delete'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = btnDeleteClick
        end
        object BitBtn1: TBitBtn
          Left = 314
          Top = 86
          Width = 31
          Height = 22
          Glyph.Data = {
            42010000424D4201000000000000420000002800000010000000100000000100
            08000000000000010000120B0000120B00000300000003000000FFFFFF000000
            0000FFFFFF000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000100000000000000
            0000010000000000010100000000000000010100000000000001010000000000
            0101000000000000000001010000000101000000000000000000000101000101
            0000000000000000000000000101010000000000000000000000000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000}
          TabOrder = 3
          OnClick = BitBtn1Click
        end
        object BitBtn3: TBitBtn
          Left = 356
          Top = 86
          Width = 31
          Height = 22
          Glyph.Data = {
            42010000424D4201000000000000420000002800000010000000100000000100
            08000000000000010000120B0000120B00000300000003000000FFFFFF000000
            0000FFFFFF000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000001000000000000000000000000000001010100
            0000000000000000000000010100010100000000000000000000010100000001
            0100000000000000000101000000000001010000000000000101000000000000
            0001010000000000010000000000000000000100000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000}
          TabOrder = 4
          OnClick = BitBtn3Click
        end
      end
      object GroupBox2: TGroupBox
        Left = 9
        Top = 165
        Width = 400
        Height = 194
        Caption = 'WAV Output Directory and Options'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        DesignSize = (
          400
          194)
        object Label2: TLabel
          Left = 308
          Top = 81
          Width = 26
          Height = 13
          Caption = '.wav'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Edit1: TEdit
          Left = 12
          Top = 25
          Width = 290
          Height = 21
          Color = clHighlightText
          Ctl3D = True
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentCtl3D = False
          ParentFont = False
          ReadOnly = True
          TabOrder = 0
        end
        object Button3: TButton
          Left = 313
          Top = 23
          Width = 75
          Height = 25
          Anchors = [akTop, akRight]
          Caption = '&Browse...'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = Button3Click
        end
        object CheckBox9: TCheckBox
          Left = 13
          Top = 53
          Width = 316
          Height = 17
          Caption = 'Enable custom naming scheme (only when a list file exists)'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = CheckBox9Click
        end
        object Edit2: TEdit
          Left = 13
          Top = 78
          Width = 288
          Height = 21
          Color = clBtnFace
          Enabled = False
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          Text = '%ORDR %GDSC (%ZIP) [#%TNUM] %SDSC'
          OnEnter = Edit2Enter
          OnExit = Edit2Exit
        end
        object ListBox2: TListBox
          Left = 12
          Top = 110
          Width = 375
          Height = 69
          Color = clBtnFace
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          IntegralHeight = True
          ItemHeight = 13
          Items.Strings = (
            '%ZIP = ZIP file name'
            '%GDSC = Game description'
            '%TNUM = Track number'
            '%SDSC = Song description'
            '%ORDR = Song order in the list')
          ParentFont = False
          TabOrder = 4
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Misc.'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ImageIndex = 1
      ParentFont = False
      object Label1: TLabel
        Left = 126
        Top = 255
        Width = 111
        Height = 13
        Caption = 'for default track length'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object RadioGroup2: TRadioGroup
        Left = 294
        Top = 250
        Width = 115
        Height = 61
        Caption = 'Language'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        Items.Strings = (
          'Japanese'
          'English')
        ParentFont = False
        TabOrder = 0
      end
      object GroupBox3: TGroupBox
        Left = 9
        Top = 2
        Width = 400
        Height = 121
        Caption = 'Display Options'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        object Label7: TLabel
          Left = 16
          Top = 73
          Width = 65
          Height = 13
          Caption = 'Refresh rate:'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label8: TLabel
          Left = 350
          Top = 74
          Width = 30
          Height = 13
          Caption = '60 fps'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label9: TLabel
          Left = 350
          Top = 96
          Width = 22
          Height = 13
          Caption = '1.0x'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label10: TLabel
          Left = 16
          Top = 94
          Width = 85
          Height = 13
          Caption = 'Text scroll speed:'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object CheckBox3: TCheckBox
          Left = 14
          Top = 20
          Width = 262
          Height = 17
          Caption = '&Peaks in VU meter'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object CheckBox5: TCheckBox
          Left = 14
          Top = 43
          Width = 261
          Height = 17
          Caption = '&Hexadecimal song number'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
        object RadioGroup1: TRadioGroup
          Left = 279
          Top = 9
          Width = 110
          Height = 55
          Caption = 'Texts scroll'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          Items.Strings = (
            'Once'
            'Continuously')
          ParentFont = False
          TabOrder = 4
        end
        object TrackBar2: TTrackBar
          Left = 109
          Top = 73
          Width = 233
          Height = 17
          Ctl3D = True
          LineSize = 5
          Max = 2
          ParentCtl3D = False
          PageSize = 1
          Position = 2
          TabOrder = 2
          ThumbLength = 11
          OnChange = TrackBar2Change
        end
        object TrackBar3: TTrackBar
          Left = 109
          Top = 95
          Width = 233
          Height = 17
          Ctl3D = True
          LineSize = 5
          Max = 4
          ParentCtl3D = False
          PageSize = 1
          Position = 2
          TabOrder = 3
          ThumbLength = 11
          OnChange = TrackBar3Change
        end
      end
      object CheckBox4: TCheckBox
        Left = 22
        Top = 254
        Width = 39
        Height = 17
        Caption = '&Set'
        Checked = True
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        State = cbChecked
        TabOrder = 3
        OnClick = CheckBox4Click
      end
      object EditDateTime1: TDateTimePicker
        Left = 59
        Top = 253
        Width = 64
        Height = 21
        Date = 46192.000000000000000000
        Format = 'mm:ss'
        Time = 0.729394247682648700
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Pitch = fpFixed
        Font.Style = []
        Kind = dtkTime
        ParentFont = False
        TabOrder = 4
      end
      object CheckBox8: TCheckBox
        Left = 22
        Top = 296
        Width = 265
        Height = 17
        Caption = '&Minimize to system tray'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 6
      end
      object GroupBox4: TGroupBox
        Left = 8
        Top = 128
        Width = 401
        Height = 115
        Caption = 'Sound Options'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        object Label3: TLabel
          Left = 375
          Top = 20
          Width = 12
          Height = 13
          Caption = 'Hz'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label4: TLabel
          Left = 249
          Top = 20
          Width = 61
          Height = 13
          Caption = 'Sample rate:'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label5: TLabel
          Left = 16
          Top = 87
          Width = 55
          Height = 13
          Caption = 'Stereo mix:'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label6: TLabel
          Left = 360
          Top = 87
          Width = 17
          Height = 13
          Caption = '0%'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object CheckBox1: TCheckBox
          Left = 14
          Top = 20
          Width = 229
          Height = 17
          Caption = '&Normalize output volume'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object CheckBox6: TCheckBox
          Left = 14
          Top = 41
          Width = 367
          Height = 17
          Caption = '&Reset normalization state between songs'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
        object ComboBox1: TComboBox
          Left = 312
          Top = 16
          Width = 60
          Height = 21
          Style = csDropDownList
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = 0
          ParentFont = False
          TabOrder = 3
          Text = '48000'
          Items.Strings = (
            '48000'
            '44100'
            '32000'
            '24000'
            '22050'
            '16000'
            '11025'
            '8000')
        end
        object TrackBar1: TTrackBar
          Left = 75
          Top = 86
          Width = 273
          Height = 17
          Ctl3D = True
          LineSize = 5
          Max = 100
          ParentCtl3D = False
          Frequency = 10
          TabOrder = 4
          ThumbLength = 11
          OnChange = TrackBar1Change
        end
        object CheckBox11: TCheckBox
          Left = 14
          Top = 63
          Width = 366
          Height = 17
          Caption = 'Use fi&xed volume setting when specified in a .lst file'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
        end
      end
      object CheckBox10: TCheckBox
        Left = 22
        Top = 318
        Width = 266
        Height = 15
        Caption = '&Attach the main window on other windows'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 7
      end
      object CheckBox7: TCheckBox
        Left = 39
        Top = 276
        Width = 253
        Height = 17
        Caption = '&Fade out for                 seconds'
        Checked = True
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        State = cbChecked
        TabOrder = 5
      end
      object EditDateTime2: TDateTimePicker
        Left = 121
        Top = 274
        Width = 41
        Height = 21
        Date = 46192.000000000000000000
        Format = 'ss'
        Time = 0.729394421294273300
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Pitch = fpFixed
        Font.Style = []
        Kind = dtkTime
        ParentFont = False
        TabOrder = 9
      end
      object CheckBox12: TCheckBox
        Left = 22
        Top = 339
        Width = 266
        Height = 15
        Caption = 'Allow multiple instances'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 8
      end
    end
  end
end
