object Form5: TForm5
  Left = 444
  Top = 526
  AlphaBlendValue = 200
  BorderStyle = bsDialog
  Caption = 'ROM Information'
  ClientHeight = 307
  ClientWidth = 439
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    439
    307)
  PixelsPerInch = 96
  TextHeight = 13
  object lblWarn: TLabel
    Left = 14
    Top = 281
    Width = 217
    Height = 13
    AutoSize = False
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object BitBtn1: TBitBtn
    Left = 356
    Top = 274
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'OK'
    Default = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = BitBtn1Click
  end
  object ListView1: TListView
    Left = 9
    Top = 109
    Width = 424
    Height = 156
    Anchors = [akLeft, akTop, akRight]
    Columns = <
      item
        Caption = 'Name'
        Width = 80
      end
      item
        Alignment = taRightJustify
        Caption = 'Size (Bytes)'
        Width = 75
      end
      item
        Alignment = taRightJustify
        Caption = 'CRC32'
        Width = 75
      end
      item
        Caption = 'Status'
        Width = 175
      end>
    ColumnClick = False
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ReadOnly = True
    RowSelect = True
    ParentFont = False
    PopupMenu = PopupMenu1
    TabOrder = 1
    ViewStyle = vsReport
    OnAdvancedCustomDrawItem = ListView1AdvancedCustomDrawItem
  end
  object btnRescan: TButton
    Left = 267
    Top = 274
    Width = 75
    Height = 25
    Caption = '&Rescan'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = btnRescanClick
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 7
    Width = 425
    Height = 42
    Caption = 'Main ROM'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    object lblFileName: TLabel
      Left = 9
      Top = 18
      Width = 64
      Height = 13
      AutoSize = False
    end
    object Edit1: TEdit
      Left = 88
      Top = 18
      Width = 333
      Height = 20
      BevelInner = bvNone
      BorderStyle = bsNone
      Color = clBtnFace
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
  end
  object GroupBox2: TGroupBox
    Left = 9
    Top = 56
    Width = 424
    Height = 42
    Caption = 'Parent'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    object lblParentName: TLabel
      Left = 9
      Top = 18
      Width = 64
      Height = 13
      AutoSize = False
    end
    object Edit2: TEdit
      Left = 88
      Top = 18
      Width = 333
      Height = 20
      BevelInner = bvNone
      BorderStyle = bsNone
      Color = clBtnFace
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
  end
  object PopupMenu1: TPopupMenu
    Left = 187
    Top = 273
    object Copytoclipboard1: TMenuItem
      Caption = 'Copy result to clipboard'
      OnClick = Copytoclipboard1Click
    end
  end
end
