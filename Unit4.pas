unit Unit4;

interface

uses
  System.Types,
  Windows, SysUtils, Classes, Controls, Forms, Graphics,
  StdCtrls, Buttons, Common,
  DateUtils, FileCtrl, ExtCtrls, ComCtrls, M1;

type
  TForm4 = class(TForm)
    btnOK: TBitBtn;
    BitBtn2: TBitBtn;
    btnDefault: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    GroupBox1: TGroupBox;
    ListBox1: TListBox;
    btnAdd: TButton;
    btnDelete: TButton;
    BitBtn1: TBitBtn;
    BitBtn3: TBitBtn;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    Edit1: TEdit;
    Button3: TButton;
    CheckBox9: TCheckBox;
    Edit2: TEdit;
    ListBox2: TListBox;
    Label1: TLabel;
    RadioGroup2: TRadioGroup;
    GroupBox3: TGroupBox;
    CheckBox3: TCheckBox;
    CheckBox5: TCheckBox;
    RadioGroup1: TRadioGroup;
    CheckBox4: TCheckBox;
    EditDateTime1: TDateTimePicker;
    CheckBox8: TCheckBox;
    GroupBox4: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox6: TCheckBox;
    ComboBox1: TComboBox;
    Label3: TLabel;
    Label4: TLabel;
    TrackBar1: TTrackBar;
    Label5: TLabel;
    Label6: TLabel;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox7: TCheckBox;
    EditDateTime2: TDateTimePicker;
    Label7: TLabel;
    TrackBar2: TTrackBar;
    Label8: TLabel;
    TrackBar3: TTrackBar;
    Label9: TLabel;
    Label10: TLabel;
    CheckBox12: TCheckBox;

    procedure FormShow(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btnDefaultClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListBox1MeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure BitBtn2Click(Sender: TObject);
    procedure CheckBox9Click(Sender: TObject);
    procedure Edit2Exit(Sender: TObject);
    procedure Edit2Enter(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TrackBar1Change(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    
  private
    { Private 宣言 }
    Dragging: Boolean;
    OldIndex: Integer;
    TempStr: String;
    Save_Cursor : TCursor;

    function Scale96(Value: Integer): Integer;
    procedure ListBoxCheckHScroll();

  public
    { Public 宣言 }
    procedure CreateParams(var Params: TCreateParams); override;
  end;

var
  Form4: TForm4;
  Path_Changed : Boolean;
  TempST : String;
  SR_beforechanged : Integer;
  MultiInstancebefore: boolean;

implementation
uses Unit1,Unit3;

{$R *.dfm}

function TForm4.Scale96(Value: Integer): Integer;
begin
  Result := MulDiv(Value, CurrentPPI, 96);
end;

procedure TForm4.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := Form1.Handle;

end;


procedure TForm4.FormShow(Sender: TObject);
var
  i       :Integer;
  Monitor :TMonitor;
  mm      :Integer;
begin

  /// マルチモニタのための処理
  if Application.MainForm <> nil then
    Monitor := Application.MainForm.Monitor
  else
    Monitor := Screen.Monitors[0];

  // メインフォームのモニタが違っていたら移動
  if Monitor <> Form4.Monitor then
  begin
    Form4.Top  := Monitor.Top + (Monitor.WorkareaRect.Bottom -
                  Monitor.WorkareaRect.Top - Form4.Height) div 2;
    Form4.Left := Monitor.Left+ (Monitor.Width  - Form4.Width ) div 2;
  end;

  
  // ROMパス表示
  ListBox1.Items.Clear;
  for i:=0 to Length(rom_path)-1 do
  begin
    ListBox1.Items.Add(rom_path[i]);
  end;
  ListBoxCheckHScroll;

  // Wavパス表示
  Edit1.Text:=wav_path;

  // Wavユーザ定義ファイル名
  Edit2.Text:=Wav_Format;
  CheckBox9.Checked:=UserWavFileName;

  // Sample Rate
  for i:=0 to ComboBox1.Items.Count-1 do
  begin
    if InttoStr(Sample_Rate)=ComboBox1.Items[i] then
      ComboBox1.ItemIndex:=i;
  end;
  SR_beforechanged := Sample_Rate;
  MultiInstancebefore := MultiInstance;

  // Stereo Mix
  TrackBar1.Position:=Stereo_Mix;

  // Normalize設定
  CheckBox1.Checked:=UseNormalize;

  // Use_FixedVolume設定
  CheckBox11.Checked:=UseFixedVolume;

  // Reset Normalization
  CheckBox6.Checked:=Reset_Normalize;

  // ピーク表示設定
  CheckBox3.Checked := Display_Peaks;

  // 16進数表示
  CheckBox5.Checked := Hexadecimal;

  // デフォルト演奏時間
  mm := DefaultPlayTime div 60000;
  EditDateTime1.Time := StrToTime(
    Format('23:%d:%d',[mm,(DefaultPlayTime - mm * 60000) div 1000]));

  CheckBox4.Checked := UseDefaultTime;

  // Fade Out
  CheckBox7.Checked := DefaultFadeout;
  EditDateTime2.Time := StrToTime(
    Format('23:59:%d',[DefaultFOLength div 1000]));

  // スクロール
  if Keep_Scrolling then
    RadioGroup1.ItemIndex := 1
  else
    RadioGroup1.ItemIndex := 0;

  // System Tray
  CheckBox8.Checked := SystemTray;

  // 言語
  Case NewLang of
    LANG_JP : RadioGroup2.ItemIndex := 0;
    LANG_EN : RadioGroup2.ItemIndex := 1;
    //LANG_CN : RadioGroup2.ItemIndex := 2;
  end;

  // パス変更フラグ
  Path_Changed:=False;

  // アタッチ
  CheckBox10.Checked:=Attachable;

  // リフレッシュレート
  TrackBar2.Position:=RefreshRate;

  // スクロール速度
  TrackBar3.Position:=ScrollSpeed;

  // マルチインスタンス
  CheckBox12.Checked:=MultiInstance;


  // ウィンドウを最前面に
  
  // メインフォームだけ他アプリの背面に入るので手前に出す
  if AlwaysOnTop then
    SetWindowPos( Form1.Handle, HWND_TOPMOST,
                  0, 0, 0, 0,
                  SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);

                
  SetWindowPos( Form4.Handle, HWND_TOP,
                0, 0, 0, 0,
                SWP_NOMOVE or SWP_NOSIZE);
                  
end;

procedure TForm4.btnAddClick(Sender: TObject);
var
  dir: string;
begin

  dir:=ExtractFileDir(Application.ExeName);
  if SelectDirectory('Please choose ROM directory to add.', '', dir) then
  begin
    ListBox1.Items.Add(dir);
    ListBoxCheckHScroll;
    Path_Changed:=True;
  end;
  
end;


procedure TForm4.ListBox1Click(Sender: TObject);
begin

  btnDelete.Enabled:= (ListBox1.Items.Count>1);

end;

procedure TForm4.btnDeleteClick(Sender: TObject);
begin

  Path_Changed:=True;
  ListBox1.Items.Delete(ListBox1.ItemIndex);
  ListBoxCheckHScroll;
  btnDelete.Enabled:= (ListBox1.Items.Count>1);

end;

procedure TForm4.Button3Click(Sender: TObject);
var
  Dir: string;
begin
  Dir := ExtractFileDir(Application.ExeName);
  if SelectDirectory('Please select WAV file output directory.', '', Dir) then
    Edit1.Text := Dir;
    
end;

// -----------------------------------------------------------------------------
// Restoring default settings
procedure TForm4.btnDefaultClick(Sender: TObject);
begin

  if PageControl1.TabIndex=0 then
  begin
    Path_Changed:=True;
    ListBox1.Items.Clear;
    ListBox1.Items.Add('roms');
    ListBoxCheckHScroll;
    btnDelete.Enabled:=False;
    Edit1.Text:='waves';

    Edit2.Text:='%ORDR %GDSC (%ZIP) [#%TNUM] %SDSC';
    CheckBox9.Checked:=False;
  end
  else
  begin

    CheckBox3.Checked     := True;  // Peaks in VU meter
    CheckBox5.Checked     := False; // Hex song number

    CheckBox1.Checked     := True;  // Normalization
    CheckBox6.Checked     := False; // Reset Normalize
    CheckBox11.Checked    := False; // Use fixed volume than normalization
    CheckBox4.Checked     := True;  // Default play time
    CheckBox7.Checked     := True;  // Fade out
    EditDateTime2.Time    := StrToTime('23:59:10'); // 10 seconds

    CheckBox8.Checked     := True;  // Minimize to system tray
    CheckBox10.Checked    := True;  // Attachable

    EditDateTime1.Time    := StrToTime('23:01:45');
    RadioGroup1.ItemIndex := 1;     // Continuous song title scroling
    TrackBar1.Position    := 0;     // Stereo Mix
    TrackBar2.Position    := 2;     // Refresh Rate
    TrackBar3.Position    := 2;     // Text scroll speed
    CheckBox12.Checked    := False; // Multiple instances

  end;
end;

procedure TForm4.btnOKClick(Sender: TObject);
var
  i,j:Integer;
  st :String;

begin

  // ROMパスの再設定
  j:=ListBox1.Items.Count;
  SetLength(rom_path,j);
  for i:=0 to j-1 do
  begin
    rom_path[i]:=ListBox1.Items[i];
  end;

  // waveパスの再設定
  wav_path:=Edit1.Text;

  // ユーザー定義waveファイル名関係
  Wav_Format:=Edit2.Text;
  UserWavFileName:=CheckBox9.Checked;

  // Sample Rate
  Sample_Rate:=StrtoInt(ComboBox1.Text);

  // Stereo Mix
  Stereo_Mix:=TrackBar1.Position;
  m1snd_setoption(M1_OPT_STEREOMIX, Stereo_Mix);

  // Normalizeの設定, Use_FixedVolume設定
  if (UseNormalize <> CheckBox1.Checked) then
  begin
    UseNormalize  := CheckBox1.Checked;
    Set_Normalize(UseNormalize);
  end;

  if (UseFixedVolume <> CheckBox11.Checked) then
  begin
    UseFixedVolume:= CheckBox11.Checked;
    if UseFixedVolume and (FixedVolume<>-1) then
    begin
      Set_Normalize(False);
    end;
  end;


  // 曲間Normalizeリセットの設定
  Reset_Normalize:= CheckBox6.Checked;
  if Reset_Normalize then
    m1snd_setoption(M1_OPT_RESETNORMALIZE, 0)   // 0.7.5コアで逆転
  else
    m1snd_setoption(M1_OPT_RESETNORMALIZE, 1);  // 0.7.6で元通り

  // ピークレベル表示の設定
  display_peaks := CheckBox3.Checked;

  // 16進数表示設定
  if Hexadecimal<>CheckBox5.Checked then
  begin
    Unit1.Set_Hexadecimal(CheckBox5.Checked);
  end;

  // デフォルト演奏時間の設定
  UseDefaultTime := CheckBox4.Checked;
  DefaultPlayTime := MinuteOf(EditDateTime1.Time)* 60000 +
                       SecondOf(EditDateTime1.Time)* 1000;

  // Fade Out
  DefaultFadeout := CheckBox7.Checked;
  DefaultFOLength := SecondOf(EditDateTime2.Time)*1000;

  // スクロール設定
  // 一回に変更があった場合はスクロールのステータスを初期化
  if (Keep_Scrolling=True) and (RadioGroup1.ItemIndex=0) then
  begin
    ScrollX:=0;
    ScrollWaitCount:=0;
    Scrolled:=True; // 一回スクロール完了

    ScrollX2:=0;
    ScrollWaitCount2:=0;
    Scrolled2:=True; // 一回スクロール完了
  end;
  
  Keep_Scrolling := (RadioGroup1.ItemIndex=1);

  // System Tray
  SystemTray := CheckBox8.Checked;

  // Lang
  Case RadioGroup2.ItemIndex of
    0: NewLang := LANG_JP;
    1: NewLang := LANG_EN;
  end;

  // Multi Instances
  MultiInstance := CheckBox12.Checked;

  //
  st:='';

  if (SR_beforechanged<>Sample_Rate) then
    st:=st+'- Sample rate'+#13#10;

  if (DispLang<>NewLang) then
    st:=st+'- Language'+#13#10;

  if (MultiInstancebefore<>MultiInstance) then
    st:=st+'- Multiple instances'+#13#10;


  if st<>'' then
  begin
    st:='New setting below takes effect after restarting Bridge.    '+#13#10#13#10+trim(st);
    
    Windows.MessageBox(Form4.Handle,PChar(St),'Option changed', MB_OK or MB_ICONINFORMATION);
  end;

  // System Tray Icon表示時の処理
  if Tray_Icon then
  begin
    if not SystemTray then
    begin
      Form1.DeleteTrayIcon();
      ShowWindow(Application.Handle, SW_SHOW);
    end;
  end;

  // アタッチ
  Attachable:=CheckBox10.Checked;

  // リフレッシュレート
  RefreshRate:=TrackBar2.Position;
  Case RefreshRate of
    0: Form1.Timer1.Interval := TIMER_20FPS;
    1: Form1.Timer1.Interval := TIMER_30FPS;
    2: Form1.Timer1.Interval := TIMER_60FPS;
  end;

  // スクロール速度
  ScrollSpeed:=TrackBar3.Position;
  Case ScrollSpeed of
    0: SongScrollSpeed := SCROLL_SPEED0;
    1: SongScrollSpeed := SCROLL_SPEED1;
    2: SongScrollSpeed := SCROLL_SPEED2;
    3: SongScrollSpeed := SCROLL_SPEED3;
    4: SongScrollSpeed := SCROLL_SPEED4;
  end;

  DescScrollSpeed := SongScrollSpeed * 0.65;

  ModalResult := mrOK;

end;


procedure TForm4.FormCreate(Sender: TObject);
begin

  Form4.Top  := (Monitor.Height-Form4.Height) div 2 - Scale96(14);
  Form4.Left := (Monitor.Width-Form4.Width) div 2;

  if (OptionTabIndex>=0) and (OptionTabIndex<=1) then
    PageControl1.TabIndex:=OptionTabIndex;

  // 言語別のフォント設定
  Case DispLang of

    LANG_JP : // 日本語
    begin
      ListBox1.Font.Charset:=SHIFTJIS_CHARSET;
      //ListBox1.Font.Name:='MS Sans Serif';
      Edit1.Font.Charset:=SHIFTJIS_CHARSET;
      Edit2.Font.Charset:=SHIFTJIS_CHARSET;
      //Edit1.Font.Name:='MS Sans Serif';
    end;

    LANG_EN : // 英語
    begin
      ListBox1.Font.Charset:=ANSI_CHARSET;
      //ListBox1.Font.Name:='MS Sans Serif';
      Edit1.Font.Charset:=ANSI_CHARSET;
      Edit2.Font.Charset:=ANSI_CHARSET;
      //Edit1.Font.Name:='MS Sans Serif';
    end;
    {
    LANG_CN : // 簡体字中文
    begin
      ListBox1.Font.Charset:=GB2312_CHARSET;
      //ListBox1.Font.Name:='SimSun';
      Edit1.Font.Charset:=GB2312_CHARSET;
      //Edit1.Font.Name:='SimSun';
      Edit2.Font.Charset:=GB2312_CHARSET;
      //Edit2.Font.Name:='SimSun';
    end;
    }
  end;

end;

//------------------------------------------------------------------------
procedure TForm4.ListBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var Index: integer;

begin

  if Dragging then
  begin
    Index := ListBox1.ItemAtPos(point(x, y), true);
    if (Index > -1) and (OldIndex<>Index) then
    // ドラッグ可能な位置にある場合
    // ドラッグ前と別なIndexならば
    begin
      ListBox1.Items.Delete(OldIndex);
      ListBox1.Items.Insert(Index, TempStr);
      ListBox1.ItemIndex := Index;
      OldIndex:=Index;
    end;
    Screen.Cursor := Save_Cursor;  // Always restore to normal
  end;
  Dragging := false;
end;

procedure TForm4.ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var 
  Index: integer;
begin

  Index := ListBox1.ItemAtPos(point(x, y), true);
  if Index > -1 then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crNoDrop;    // Show Dragging Cursor
    TempStr := ListBox1.Items[Index];
    OldIndex := Index;
    Dragging := true;
  end;

end;

procedure TForm4.ListBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var Index: integer;
begin

  if Dragging then
  begin
    Index := ListBox1.ItemAtPos(point(x, y), true);
    if (Index > -1) and (OldIndex<>Index) then
    // ドラッグ可能な位置にある場合
    // ドラッグ元と別なIndexならば
      Screen.Cursor := crDrag
    else
      Screen.Cursor := crNoDrop;

  end;
    
end;

//------------------------------------------------------------------------
procedure TForm4.BitBtn1Click(Sender: TObject);
var
  Idx : Integer;
  St  : String;
begin

  with ListBox1 do
  begin

    if (ItemIndex=-1) or (ItemIndex=0) then exit;
    Idx := ItemIndex;
    St:=ListBox1.Items[Idx];
    ListBox1.Items.Delete(Idx);
    ListBox1.Items.Insert(Idx-1, St);

    ItemIndex := Idx-1;
  end;
  
end;

procedure TForm4.BitBtn3Click(Sender: TObject);
var
  Idx : Integer;
  St  : String;
  
begin

  with ListBox1 do
  begin

    if (ItemIndex=-1) or (ItemIndex=Items.Count-1) then exit;
    Idx := ItemIndex;
    St:=ListBox1.Items[Idx];
    ListBox1.Items.Delete(Idx);
    ListBox1.Items.Insert(Idx+1, St);

    ItemIndex := Idx+1;
  end;
end;

procedure TForm4.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  St  :String;
  Rct :TRect;
  uFormat : Integer;

begin

  uFormat:= DT_LEFT or DT_SINGLELINE or DT_NOPREFIX or DT_VCENTER;

  with (Control as TListBox).Canvas do
  begin
      

    // ドラッグ中
    if Dragging then
    begin
      // ドラッグ元の行を選択色にする
      if OldIndex=Index then
      begin
        Brush.Color:=clHighLight;
        Font.Color:=clHighLightText;
      end
      else
      begin
        Brush.Color:=clBtnHighlight;
        Font.Color:=clWindowText;
      end;
    end
    else
    begin
      // 選択行
      if (odSelected in State) then
      begin
        Brush.Color:=clHighLight;
        Font.Color:=clHighLightText;
      end;
    end;

    FillRect(Rect);
    Rct:=Rect;
    Inc(Rct.Left, Scale96(2));
    ST:=ListBox1.Items[Index];
    DrawText(Handle, PChar(ST), Length(ST), Rct, uFormat);

  end;
  
end;

// ListBox1の横スクロールチェック [0.5.0]
procedure TForm4.ListBoxCheckHScroll();
var i,maxw: integer;
begin

  maxw:=ListBox1.ClientWidth;

  for i:=0 to ListBox1.Items.Count-1 do
  begin
    if ListBox1.Canvas.TextWidth(ListBox1.Items[i])>maxw then
      maxw:=ListBox1.Canvas.TextWidth(ListBox1.Items[i])+Scale96(6);
  end;

  ListBox1.ScrollWidth:=maxw;

end;


procedure TForm4.ListBox1MeasureItem(Control: TWinControl; Index: Integer;
  var Height: Integer);
begin
  Height := Abs(TListBox(Control).Font.Height) + Scale96(1);
end;

procedure TForm4.BitBtn2Click(Sender: TObject);
begin
  Form4.Close;
end;

procedure TForm4.CheckBox9Click(Sender: TObject);
begin

  Edit2.Enabled:=CheckBox9.Checked;
  
  if CheckBox9.Checked then
    Edit2.Color:=clWindow
  else
    Edit2.Color:=clBtnFace;

end;

procedure TForm4.Edit2Exit(Sender: TObject);
begin

  if (pos('%ZIP',Edit2.Text)=0) and
     (pos('%GDSC',Edit2.Text)=0) and
     (pos('%TNUM',Edit2.Text)=0) and
     (pos('%SDSC',Edit2.Text)=0) and
     (pos('%ORDR',Edit2.Text)=0) then
  begin

    Windows.MessageBox(Form4.Handle, 'Invalid wave file name syntax.  ','Syntax Error',MB_OK or MB_ICONWARNING);
    Edit2.Text:=TempSt;
    if Edit2.Enabled then Edit2.SetFocus;
  end;
end;

procedure TForm4.Edit2Enter(Sender: TObject);
begin
  TempSt:=Edit2.Text;
end;

procedure TForm4.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  OptionTabIndex:=PageControl1.TabIndex;

end;

procedure TForm4.TrackBar1Change(Sender: TObject);
begin
  Label6.Caption:=InttoStr(TrackBar1.Position)+'%';
end;

procedure TForm4.CheckBox4Click(Sender: TObject);
begin

  CheckBox7.Enabled:=CheckBox4.Checked;
  EditDateTime2.Enabled:=CheckBox4.Checked;

end;

procedure TForm4.TrackBar2Change(Sender: TObject);
begin

  Case TrackBar2.Position of
    0: Label8.Caption:='20 fps';
    1: Label8.Caption:='30 fps';
    2: Label8.Caption:='60 fps';
  end;

end;

procedure TForm4.TrackBar3Change(Sender: TObject);
begin
  Case TrackBar3.Position of
    0: Label9.Caption:='0.6x';
    1: Label9.Caption:='0.8x';
    2: Label9.Caption:='1.0x';
    3: Label9.Caption:='1.2x';
    4: Label9.Caption:='1.4x';
  end;

end;

end.
