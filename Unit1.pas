unit Unit1;

interface

uses
  System.Types,
  Windows, Messages, ExtCtrls, ImgList, Controls, Menus, Graphics,
  Classes, Buttons, Math, SysUtils, Forms, Dialogs, StdCtrls, ComCtrls, Common,
  StrUtils, ShellApi, Unit2, Unit3, Unit6, M1, MT, MMSystem, WSDLIntf,
  WideStrings, AppEvnts, Fastcode,
  ActnList, XPStyleActnCtrls, ActnMan, System.Actions, System.ImageList,
  ImageScaling;

const
  UDM_NotifyTasktray = WM_USER + 100;
  THEME_DESIGN_WIDTH = 376;
  THEME_DESIGN_HEIGHT = 159;
  MAIN_SPEEDBUTTON_COUNT = 10;

type                                
  TForm1 = class(TForm)

    popPrevious:    TMenuItem;
    popPlay:        TMenuItem;
    popPause:       TMenuItem;
    popStop:        TMenuItem;
    popNext:        TMenuItem;
    N3:             TMenuItem;
    popOptions:     TMenuItem;
    popLoad:        TMenuItem;
    popExit:        TMenuItem;
    N4:             TMenuItem;
    ImageList1:     TImageList;
    Timer1:         TTimer;
    FontDialog1:    TFontDialog;
    PopupMenu1:     TPopupMenu;
    PopupMenu2:     TPopupMenu;
    popTheme:       TMenuItem;
    Options1:       TMenuItem;
    N1:             TMenuItem;
    N2:             TMenuItem;
    N5:             TMenuItem;
    popNormalize:   TMenuItem;
    popListMode:    TMenuItem;
    popAutoMove:    TMenuItem;
    popHexNumber:   TMenuItem;
    Alwaysontop1:   TMenuItem;
    rackListFont1:  TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    Shape1: TShape;
    PaintBox1: TPaintBox;
    btnRec: TSpeedButton;
    btnPrev: TSpeedButton;
    btnPlay: TSpeedButton;
    btnPause: TSpeedButton;
    btnStop: TSpeedButton;
    btnNext: TSpeedButton;
    btnLoad: TSpeedButton;
    btnRepeat: TSpeedButton;
    btnList: TSpeedButton;
    btnMixer: TSpeedButton;
    pbVolume: TPaintBox;
    Image10: TImage;
    Bevel1: TBevel;
    ActionManager1: TActionManager;
    actAlwaysTop: TAction;
    actHexNumber: TAction;

    
    function LoadGameNames: Boolean; // updated in 0.4.4
    procedure ShowSongName(Song_No: Integer);
    procedure Theme(ThemeName : String);
    procedure PopupThemeClick(Sender: TObject); // 0.5.3

    //---------------------------------------
    procedure FormDestroy(Sender: TObject);
    procedure btnPlayClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnPauseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnListClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure btnRecClick(Sender: TObject);
    procedure popLoadClick(Sender: TObject);
    procedure PopupMenu2Popup(Sender: TObject);
    procedure popOptionsClick(Sender: TObject);
    procedure popPreviousClick(Sender: TObject);
    procedure popPlayClick(Sender: TObject);
    procedure popPauseClick(Sender: TObject);
    procedure popStopClick(Sender: TObject);
    procedure popNextClick(Sender: TObject);
    procedure popExitClick(Sender: TObject);
    procedure pbVolumeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbVolumeMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pbVolumePaint(Sender: TObject);
//    procedure btnMuteClick(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnRepeatClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
    procedure popAutoMoveClick(Sender: TObject);
    procedure btnMixerClick(Sender: TObject);
    procedure rackListFont1Click(Sender: TObject);
    procedure ApplicationEvents1Minimize(Sender: TObject);
    procedure ApplicationEvents1Restore(Sender: TObject);
    procedure popNormalizeClick(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure popListModeClick(Sender: TObject);
    procedure actAlwaysTopExecute(Sender: TObject);
    procedure actAlwaysTopUpdate(Sender: TObject);
    procedure actHexNumberExecute(Sender: TObject);
    procedure actHexNumberUpdate(Sender: TObject);
    procedure ApplicationEvents1Activate(Sender: TObject);
    procedure FormActivate(Sender: TObject);

  private
    { Private 宣言 }

    IdleThread : TIdleThread;     // IDLE送信用スレッド
    Thread_on : Boolean;          // IDLE送信スレッドが生きているか

    FpntMoveOrg, FpntMoveFit : TPoint;

    MainThread : THandle; // メインスレッドのハンドル

    VolPoint : TPoint;   // 音量調節用
    VolRect  : TRect;
    KnobRect : TRect;
    FKnobWidth: Integer;
    FKnobHeight: Integer;
    FMainButtonGlyphs: array [0..MAIN_SPEEDBUTTON_COUNT - 1] of TBitmap;
    FMainButtonImages: array [0..MAIN_SPEEDBUTTON_COUNT - 1] of TImageList;
    FMainButtonStateCounts: array [0..MAIN_SPEEDBUTTON_COUNT - 1] of Integer;

    oldForm1 : TPoint;   // フォーム移動前の位置
    

    procedure IdleThreadDone(Sender: TObject);
    procedure WMEnterSizeMove(var MSG: Tmessage); message WM_ENTERSIZEMOVE;
    procedure WMMoving(var MSG: Tmessage); message WM_MOVING;
    procedure WMMove(var msg:TMessage); message WM_MOVE;

    procedure DrawVolume;
    procedure GetVolume;
    procedure SetVolume(Value: Integer);
    procedure UpdateVolumeRect;
    function Scale96(Value: Integer): Integer;
    function DesignPixels(Value: Integer): Integer;
    function VolumeKnobWidth: Integer;
    function MainSpeedButton(Index: Integer): TSpeedButton;
    procedure InitializeMainButtonImages;
    procedure BuildMainButtonImages;
    procedure DrawMainWindow(timer: Boolean);
    procedure PresentMainWindow;

    procedure SetFadeOut( CurrentTime: Integer; EndTime: Integer; FOLength: Integer);  

  protected
    procedure ChangeScale(M, D: Integer; IsDpiChange: Boolean); override;

  public
    { Public 宣言 }

    NotifyIcon  : TNotifyIconData; // System Tray Icon
    procedure MakeTrayIcon;        //
    procedure DeleteTrayIcon;      //
    procedure ModifyTrayIcon(st:String);
    procedure SystemTrayEvent(var Msg : TMsg);
    message   WM_USER + 100;       //

end;

  TDllVersionInfo	= packed record
    cbSize		:DWORD;
    dwMajorVersion	:DWORD;
    dwMinorVersion	:DWORD;
    dwBuildNumber	:DWORD;
    dwPlatformID	:DWORD;
  end;
  
  
var

  Form1: TForm1;
  
  TempStream: TMemoryStream;
  Last_Rom_Path : String;
  peaks_L,peaks_R: array [0..59] of Integer; // ピークレベルのバッファ
  current_peak   : Integer;

  stmm,stss : String;       // タイマーに表示する文字列
  Indicator : Integer;      // タイマー部分の再生・停止表示

  NormCount: Integer;       // Normalizeレベルの表示用カウンタ

  // 新描画用
  desc, PreviousDesc, SongName, PreviousSongName: WideString;
  manu, system, hard, RomName, parentname: String;
  rctNorm, rctList, rctNext, rctSong, rctLV, rctSongName, rctGameDesc: TRect;
  
  Buffer, DisplayBuffer, imgBack, imgIcons, imgLevel, imgDigits,
  AlphaBitmap: TBitmap;

  clrGameDesc, clrSong, clrInfoLabel, clrInfoDesc, clrPanel,
  clrLWBack, clrLWFont: TColor;

procedure StartTimer;
procedure ResetTimer;
procedure StopPlay;
procedure StartPlay(Song_No:Integer);
procedure List_PlayNext;

procedure Set_Normalize(flag:Boolean);
procedure Set_ListMode(flag:Boolean);
procedure Set_Hexadecimal(flag:Boolean);
procedure ResetFormOrder( AlwaysOnTop: boolean );

function  Find_RomPath(fn:PAnsiChar):integer;
procedure Flush_Peaks;

implementation

uses Unit4;


{$R *.dfm}
{$R 'default_theme.RES'}

//
procedure FormFitMoveToForms(frmTgt: TForm; var rectForm: TRect);

  function SubH(rectTgt: TRect): boolean;
  begin
    Result := FALSE;

    if ((rectForm.Bottom + ciFittingThreshold >= rectTgt.Top   ) and
        (rectForm.Top    - ciFittingThreshold <= rectTgt.Bottom)) then
    begin

      // 左辺同士と右辺同士はターゲット外の時のみ
      if (Abs(rectForm.Left - rectTgt.Left) <= ciFittingThreshold) and
         ((rectForm.Bottom <= rectTgt.Top + ciFittingThreshold) or
          (rectTgt.Bottom - ciFittingThreshold <= rectForm.Top )) then
      begin
        OffsetRect(rectForm, rectTgt.Left - rectForm.Left, 0);
        Result := TRUE;
      end
      else
      if (Abs(rectForm.Right - rectTgt.Right) <= ciFittingThreshold) and
         ((rectForm.Bottom <= rectTgt.Top + ciFittingThreshold) or
          (rectTgt.Bottom-ciFittingThreshold <= rectForm.Top )) then
      begin
        OffsetRect(rectForm, rectTgt.Right - rectForm.Right, 0);
        Result := TRUE;
      end
      // 左辺と右辺
      else
      if (Abs(rectForm.Left  - rectTgt.Right) <= ciFittingThreshold) then
      begin
        OffsetRect(rectForm, rectTgt.Right - rectForm.Left, 0);
        Result := TRUE;
      end
      // 右辺と左辺
      else
      if (Abs(rectForm.Right - rectTgt.Left )<= ciFittingThreshold) then
      begin
        OffsetRect(rectForm, rectTgt.Left- rectForm.Right, 0);
        Result := TRUE;
      end;
    end;
  end;

  function SubDH(rectTgt: TRect): boolean;
  var
    rectForm1,
    rectAttached : TRect;
    groupLeft,
    groupRight   : integer;
  begin
    Result := FALSE;

    rectForm1 := GetRealWindowRect(Form1.Handle);
    groupLeft := rectForm1.Left;
    groupRight := rectForm1.Right;

    if Attached or Attached3 then
    begin
      rectAttached := GetRealWindowRect(Form2.Handle);
      if rectAttached.Left < groupLeft then
        groupLeft := rectAttached.Left;
      if rectAttached.Right > groupRight then
        groupRight := rectAttached.Right;
    end;

    if Attached2 or Attached3 then
    begin
      rectAttached := GetRealWindowRect(Form6.Handle);
      if rectAttached.Left < groupLeft then
        groupLeft := rectAttached.Left;
      if rectAttached.Right > groupRight then
        groupRight := rectAttached.Right;
    end;

    Inc(rectTgt.Left, rectForm1.Left - groupLeft);
    Dec(rectTgt.Right, groupRight - rectForm1.Right);
    if ((rectForm.Bottom + ciFittingThreshold >= rectTgt.Top   ) and
        (rectForm.Top    - ciFittingThreshold <= rectTgt.Bottom)) then
    begin

      // Left side to left side
      if (Abs(rectForm.Left - rectTgt.Left) <= ciFittingThreshold) then
      begin
        OffsetRect(rectForm, rectTgt.Left - rectForm.Left, 0);
        Result := TRUE;
      end
      // Right side to right side
      else
      if (Abs(rectForm.Right - rectTgt.Right) <= ciFittingThreshold) then
      begin
        OffsetRect(rectForm, rectTgt.Right - rectForm.Right, 0);
        Result := TRUE;
      end;

    end;
  end;

  function SubV(const rectTgt: TRect): boolean;
  begin
    Result := FALSE;
    if ((rectForm.Right + ciFittingThreshold >= rectTgt.Left ) and
        (rectForm.Left  - ciFittingThreshold <= rectTgt.Right)) then
    begin

      // 上辺同士と下辺同士は ターゲット外にあるとき
      if (Abs(rectForm.Top - rectTgt.Top) <= ciFittingThreshold) and
         ((rectForm.Right <= rectTgt.Left + ciFittingThreshold) or
          (rectTgt.Right - ciFittingThreshold <= rectForm.Left)) then
      begin
        OffsetRect(rectForm, 0, rectTgt.Top - rectForm.Top);
        Result := TRUE;
      end
      else
      if (Abs(rectForm.Bottom - rectTgt.Bottom) <= ciFittingThreshold) and
         ((rectForm.Right <= rectTgt.Left) or
          (rectTgt.Right  <= rectForm.Left)) then

      begin
        OffsetRect(rectForm, 0, rectTgt.Bottom - rectForm.Bottom);
        Result := TRUE;
      end
      else

      // 上辺と下辺
      if (Abs(rectForm.Top  - rectTgt.Bottom) <= ciFittingThreshold) then
      begin
        OffsetRect(rectForm, 0, rectTgt.Bottom - rectForm.Top);
        Result := TRUE;
      end
      else
      //　下辺と上辺
      if (Abs(rectForm.Bottom - rectTgt.Top ) <= ciFittingThreshold) then
      begin
        OffsetRect(rectForm, 0, rectTgt.Top - rectForm.Bottom);
        Result := TRUE;
      end;

    end;
  end;

  function SubDV(rectTgt: TRect): boolean;
  var
    rectForm1,
    rectAttached : TRect;
    groupTop,
    groupBottom  : integer;
  begin
    Result := FALSE;

    rectForm1 := GetRealWindowRect(Form1.Handle);
    groupTop := rectForm1.Top;
    groupBottom := rectForm1.Bottom;

    if Attached or Attached3 then
    begin
      rectAttached := GetRealWindowRect(Form2.Handle);
      if rectAttached.Top < groupTop then
        groupTop := rectAttached.Top;
      if rectAttached.Bottom > groupBottom then
        groupBottom := rectAttached.Bottom;
    end;

    if Attached2 or Attached3 then
    begin
      rectAttached := GetRealWindowRect(Form6.Handle);
      if rectAttached.Top < groupTop then
        groupTop := rectAttached.Top;
      if rectAttached.Bottom > groupBottom then
        groupBottom := rectAttached.Bottom;
    end;

    Inc(rectTgt.Top, rectForm1.Top - groupTop);
    Dec(rectTgt.Bottom, groupBottom - rectForm1.Bottom);
    if ((rectForm.Right + ciFittingThreshold >= rectForm.Left) and
        (rectForm.Left  - ciFittingThreshold <= rectForm.Right)) then
    begin

      // 上辺同士と下辺同士
      if (Abs(rectForm.Top - rectTgt.Top) <= ciFittingThreshold) then
      begin
        OffsetRect(rectForm, 0, rectTgt.Top - rectForm.Top);
        Result := TRUE;
      end
      else
      if (Abs(rectForm.Bottom - rectTgt.Bottom) <= ciFittingThreshold) then
      begin
        OffsetRect(rectForm, 0, rectTgt.Bottom - rectForm.Bottom);
        Result := TRUE;
      end;
    end;

  end;

var
  iCntr       : integer;
  frmTmp      : TForm;
  rectTmp     : TRect;
  rectScreen  : TRect;
begin

  rectScreen:=Form1.Monitor.WorkareaRect;//Screen.WorkAreaRect;

  SubDH(rectScreen);


  // フォームの左右辺を隣接させる
  for iCntr := 0 to Screen.FormCount - 1 do
  begin
    frmTmp  := Screen.Forms[iCntr];

    // アタッチと対象フォームの指定
    if ((not Attached) and (not Attached2)) or
       (Attached and (not Attached2) and (frmTmp.Name='Form6')) or
       ((not Attached) and Attached2 and (frmTmp.Name='Form2')) then
    begin

      rectTmp := GetRealWindowRect(frmTmp.Handle);

      if (frmTmp <> frmTgt) and (frmTmp.Visible) then
      begin
        if (SubH(rectTmp)) then
          break;
      end;
    end;

  end;

  SubDV(rectScreen);
  
  // フォームの上下辺を隣接させる
  for iCntr := 0 to Screen.FormCount - 1 do
  begin
    frmTmp  := Screen.Forms[iCntr];

    // アタッチと対象フォームの指定
    if ((not Attached) and (not Attached2)) or
       (Attached and (not Attached2) and (frmTmp.Name='Form6')) or
       ((not Attached) and Attached2 and (frmTmp.Name='Form2')) then
    begin
    
      rectTmp := GetRealWindowRect(frmTmp.Handle);

      if (frmTmp <> frmTgt) and (frmTmp.Visible) then
      begin
        if (SubV(rectTmp)) then
          break;

      end;
    end;
    
  end;

end;

procedure TForm1.WMEnterSizeMove(var MSG: Tmessage);

  function RangesOverlap(const A1, A2, B1, B2: Integer): Boolean;
  begin
    Result := (A1 <= B2) and (B1 <= A2);
  end;

  function EdgesTouch(const A, B: Integer): Boolean;
  begin
    Result := Abs(A - B) <= ciFittingThreshold;
  end;

  function RectsAttached(const A, B: TRect): Boolean;
  begin
    Result :=
      (RangesOverlap(A.Left, A.Right, B.Left, B.Right) and
       (EdgesTouch(A.Top, B.Bottom) or EdgesTouch(A.Bottom, B.Top))) or
      (RangesOverlap(A.Top, A.Bottom, B.Top, B.Bottom) and
       (EdgesTouch(A.Left, B.Right) or EdgesTouch(A.Right, B.Left)));
  end;

var
  rectForm1,
  rectForm2,
  rectForm6: TRect;
begin
  inherited;
  FpntMoveOrg.X := Self.Left;
  FpntMoveOrg.Y := Self.Top;
  FpntMoveFit   := FpntMoveOrg;

  // Attachの判断
  Attached  := False;
  Attached2 := False;
  Attached3 := False;

  if Attachable=False then exit;

  rectForm1 := GetRealWindowRect(Form1.Handle);

  if Form2.Visible then
  begin
    rectForm2 := GetRealWindowRect(Form2.Handle);
    Attached := RectsAttached(rectForm1, rectForm2);
  end;

  if Form6.Visible then
  begin
    rectForm6 := GetRealWindowRect(Form6.Handle);
    Attached2 := RectsAttached(rectForm1, rectForm6);
  end;

  if Form2.Visible and Form6.Visible and (Attached xor Attached2) then
    Attached3 := RectsAttached(rectForm2, rectForm6);

end;

procedure TForm1.WMMoving(var MSG: Tmessage);
var
  rectNew,
  rectFit,
  rectOuter,
  rectReal : TRect;
  iWidth,iHeight : integer;
  offsetLeft,
  offsetTop,
  offsetRight,
  offsetBottom : Integer;

begin

  inherited;

  // Form1の元の位置
  oldForm1.X:=Form1.Left;
  oldForm1.Y:=Form1.Top;

  rectNew := PRect(Msg.LParam)^;

  FpntMoveOrg.X := FpntMoveOrg.X + rectNew.Left - FpntMoveFit.X;
  FpntMoveOrg.Y := FpntMoveOrg.Y + rectNew.Top  - FpntMoveFit.Y;

  iWidth  := rectNew.Right  - rectNew.Left;
  iHeight := rectNew.Bottom - rectNew.Top;

  rectNew.TopLeft := FpntMoveOrg;
  rectNew.Right   := FpntMoveOrg.X + iWidth;
  rectNew.Bottom  := FpntMoveOrg.Y + iHeight;

  rectOuter := Rect(Form1.Left, Form1.Top, Form1.Left + Form1.Width, Form1.Top + Form1.Height);
  rectReal := GetRealWindowRect(Form1.Handle);
  offsetLeft := rectReal.Left - rectOuter.Left;
  offsetTop := rectReal.Top - rectOuter.Top;
  offsetRight := rectReal.Right - rectOuter.Right;
  offsetBottom := rectReal.Bottom - rectOuter.Bottom;

  rectFit := rectNew;
  Inc(rectFit.Left, offsetLeft);
  Inc(rectFit.Top, offsetTop);
  Inc(rectFit.Right, offsetRight);
  Inc(rectFit.Bottom, offsetBottom);

  FormFitMoveToForms(Self, rectFit);

  rectNew.Left := rectFit.Left - offsetLeft;
  rectNew.Top := rectFit.Top - offsetTop;
  rectNew.Right := rectFit.Right - offsetRight;
  rectNew.Bottom := rectFit.Bottom - offsetBottom;

  FpntMoveFit := rectNew.TopLeft;

  PRect(Msg.LParam)^ := rectNew;
  Msg.Result := -1;

end;

procedure TForm1.WMMove(var msg: TMessage);
var dX,dY : Integer;
begin

  if not booting then
  begin

    if Attached or Attached3 then
    begin
      dX:= Form1.Left - oldForm1.X;
      dY:= Form1.Top  - oldForm1.Y;
      Form2.Left:=Form2.Left + dX;
      Form2.Top :=Form2.Top  + dY;
    end;

    if Attached2 or Attached3 then
    begin
      dX:= Form1.Left - oldForm1.X;
      dY:= Form1.Top  - oldForm1.Y;
      Form6.Left:=Form6.Left + dX;
      Form6.Top :=Form6.Top  + dY;
    end;

  end;
end;

// --------------------------------------------------------------------
// タイトルバーのダブルクリック
{procedure TForm1.TitleDblClick;
//var
//   ch:integer;
begin
   {ch:=GetSystemMetrics(SM_CYFRAME)*2+GetSystemMetrics(SM_CYCAPTION);
   if Msg.YCursor<ch+Top then
   begin
      if Height>ch then
      begin
         orgHeight:=Height;
         Height :=ch;
      end else Height:=orgHeight;

      //Form6.Show;
   end;
end;
}


//---------------------------------------------------------------------
// バッファしたピークレベルの初期化
procedure Flush_Peaks;
var i:Integer;
begin
  for i:=0 to VU_Latency do
  begin
    peaks_L[i]:=0;
    peaks_R[i]:=0;
  end;
end;

// --------------------------------------------------------------------
// Find ROM
// [Arg] char *fn : zip file name
// [Ret] Integer 1: found  0: not found

function find_rompath(fn:PAnsiChar):integer;
var
  i:Integer;
  FullPath: AnsiString;
begin

  SetCurrentDir(Exe_Path);

  for i:=0 to Length(rom_path)-1 do
  begin
    if FileExists(JoinPath(rom_path[i], string(fn))) then
    begin

      FullPath := AnsiString(ExpandFileName(JoinPath(rom_path[i], string(fn))));
      Move(PAnsiChar(FullPath)^, fn^, Length(FullPath) + 1);
      find_rompath:=1;
      Exit;
    end;
  end;

  find_rompath:=0;

end;

// --------------------------------------------------------------------
// bm1.txt読み込み
//
// 0.4.3 読み仮名追加
// 0.4.4 仮想リスト対応
// 0.6.0 unicode化
//
// 返値:True  utf-8
//      False utf-8じゃない

function TForm1.LoadGameNames: Boolean;
var
  i : Integer;
  F1: TextFile;
  rom_name : String;
  kana, j_name : WideString;

  WStrList: TWideStrings;
  St: WideString;
  wSt: WideString;
  BomRemoved: Boolean;

begin

  Result := True;

  // ファイルあるか
  if not FileExists(EXE_Path+List_Path+'bm1.txt') then
    Exit;

  AssignFile(F1, EXE_Path+List_Path+'bm1.txt');
  SetTextCodePage(F1, CP_UTF8);
  Reset(F1);

  BomRemoved := False;
  if not Eof(F1) then
  begin
    ReadLn(F1, St);
    if (Length(St) > 0) and (St[1] = WideChar($FEFF)) then
      BomRemoved := True;
  end;
  CloseFile(F1);

  AssignFile(F1, EXE_Path+List_Path+'bm1.txt');
  SetTextCodePage(F1, CP_UTF8);
  Reset(F1);

  WStrList := TWideStringList.Create;
  try
    while not Eof(F1) do
    begin
      ReadLn(F1, wSt);

      if BomRemoved then
      begin
        if (Length(wSt) > 0) and (wSt[1] = WideChar($FEFF)) then
          Delete(wSt, 1, 1);
        BomRemoved := False;
      end;

      if (Copy(wSt, 1, 2) <> '//') and (Trim(wSt) <> '') then
      begin
        i := WideTsvSeparate(wSt, WStrList);

        if i > 2 then  // カナがあるとき
        begin
          rom_name := WStrList[0];
          j_name := WStrList[1];
          kana := WStrList[2];
        end
        else if i = 2 then  // カナがないとき
        begin
          rom_name := WStrList[0];
          j_name := WStrList[1];
          kana := WStrList[1];
        end;

        for i := 0 to max_games - 1 do
        begin
          if rom_name = PROMList(RL[i]).RomName then
          begin
            PRomList(RL[i]).Title := j_name;
            PRomList(RL[i]).Kana := kana;
            break;
          end;
        end;
      end;
    end;
  finally
    WStrList.Free;
    CloseFile(F1);
  end;

end;





//
procedure StartTimer;
begin

  playing := True;
  Indicator:=DIGI_PLAY;
  PauseCount:=0;

end;

// タイマーリセット
// タイマー停止、タイムリセット、表示リセット、開始TickCount取得
procedure ResetTimer;
begin

  playing := False;
  PauseCount:=0;
  TimeCount:=0;
  stmm:='00';
  stss:='00';
  StartTick:=TimeGetTime;

end;

// --------------------------------------------------------------------
//  停止処理
//  録音の後処理
//  コアポーズ、タイマーリセット、タイマー停止、
//  ピークバッファクリア、インディケータを停止状態に
//  トレイアイコンのTIPをリセット

procedure StopPlay;
begin

  // 録音中の場合、一旦RecOFF→曲切替え→RecON
  if recording then
  begin
    // 繰り返すとゴミがたまるので一回のみ実行
    if (not pause) and playing then
    begin
      m1snd_setoption(M1_OPT_WAVELOG,0);
      m1snd_run(M1_CMD_SONGJMP, CurrentSongNo);
      m1snd_setoption(M1_OPT_WAVELOG,1);
    end;
  end;

  if playing then
  begin
    pause:=True;
    playing:=False;
    Flush_Peaks;
    Indicator:=DIGI_STOP;
  end;

  // トレイアイコン
  Form1.ModifyTrayIcon('BridgeM1');

  ResetTimer;
  m1snd_run(M1_CMD_PAUSE, 0);
  
end;

procedure StartPlay(Song_No:Integer);
begin

  if Song_No<-1 then exit;
  

  Form1.ShowSongName(Song_No);

  m1snd_run(M1_CMD_SONGJMP, Song_No);
  if pause then m1snd_run(M1_CMD_UNPAUSE, 0);

  CurrentSongNo:=Song_No;
  pause:=False;
  playing:=True;
  ResetTimer;
  StartTimer;

end;


// --------------------------------------------------------------------
// normalizeの設定
procedure Set_Normalize(Flag:Boolean);
begin

  normalize:= Flag;

  if Flag then
  begin
    m1snd_setoption(M1_OPT_NORMALIZE, 1);

    if NormVolume > 0 then
      Form2.Label1.Caption:='Normaliation Gain: '+InttoStr(NormVolume) +' %'
    else
      Form2.Label1.Caption:='Normaliation Gain: --- %';

  end
  else
  begin
    m1snd_setoption(M1_OPT_NORMALIZE, 0);

    if FixedVolume <> -1 then
      Form2.Label1.Caption:='Fixed Volume: '+InttoStr(FixedVolume) +' %'
    else
      Form2.Label1.Caption:='Fixed Volume: --- %';

  end;

end;


// --------------------------------------------------------------------
// List Modeの設定
procedure Set_ListMode(Flag:Boolean);
begin

  ListMode:= Flag;

end;


// --------------------------------------------------------------------
// Hex表示の設定
procedure Set_Hexadecimal(Flag:Boolean);
begin

  Hexadecimal:= Flag;
  Form1.ShowSongName(CurrentSongNo);
  Form2.ListBox1.Invalidate;
  Application.ProcessMessages;

end;


//------------------------------------------------------------------------------
// フォーム位置の再設定
procedure ResetFormOrder( AlwaysOnTop: boolean );
begin

  Form1.Alwaysontop1.Checked:=AlwaysOnTop;

  if AlwaysOnTop then
  begin
    SetWindowPos( Form1.Handle, HWND_TOPMOST, 0, 0, 0, 0,
                  SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);

    SetWindowPos( Form2.Handle, HWND_TOPMOST, 0, 0, 0, 0,
                  SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);

    SetWindowPos( Form6.Handle, HWND_TOPMOST, 0, 0, 0, 0,
                  SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
  end
  else
  begin
    SetWindowPos( Form1.Handle, HWND_NOTOPMOST, 0, 0, 0, 0,
                  SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);

    SetWindowPos( Form2.Handle, HWND_NOTOPMOST, 0, 0, 0, 0,
                  SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);

    SetWindowPos( Form6.Handle, HWND_NOTOPMOST, 0, 0, 0, 0,
                  SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
  end;
  
    SetWindowPos( Form1.Handle, HWND_TOP, 0, 0, 0, 0,
                  SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);

    SetWindowPos( Form2.Handle, HWND_TOP, 0, 0, 0, 0,
                  SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);

    SetWindowPos( Form6.Handle, HWND_TOP, 0, 0, 0, 0,
                  SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
end;


// --------------------------------------------------------------------
// リストモード用の次の曲開始
Procedure List_PlayNext;
var
  i:Integer;
begin

  if ListMode then
  begin

    // リスト内の次の曲を探す
    for i:=CurrentIndex+1 to TL.Count-1 do
    begin
      if PTrackList(TL[i])^.Song_No<>-1 then
      begin
        CurrentIndex:=i;
        StartPlay(PTrackList(TL[i]).Song_No);
        //Form2.MakeVisible(i); // リストをスクロール
        Form2.ListBox1.Invalidate;
        Exit;
      end;
    end;

    // 最後の曲の場合は停止
    Form1.btnStopClick(nil);

  end;

end;


// --------------------------------------------------------------------
// 初期化
procedure TForm1.FormCreate(Sender: TObject);
var
  i,drv:Integer;
  st  : String;

  NewItem : PROMList;

begin

  InitializeMainButtonImages;

  // メインスレッドの優先度
  MainThread := GetCurrentThread;
  SetThreadPriority(MainThread, THREAD_PRIORITY_ABOVE_NORMAL);
    // THREAD_PRIORITY_IDLE,
    // THREAD_PRIORITY_LOWEST
    // THREAD_PRIORITY_BELOW_NORMAL
    // THREAD_PRIORITY_NORMAL
    // THREAD_PRIORITY_ABOVE_NORMAL
    // THREAD_PRIORITY_HIGHEST
    // THREAD_PRIORITY_TIME_CRITICAL

  // フォームのタイトル
  Form1.Caption:=APPNAME;

  Application.HintPause := 250;
  Application.HintHidePause := 5000;
  
  // Exe Path
  exe_path := ExtractFilePath(Application.ExeName);

  // 動作OSの言語取得
  i:= GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SENGCOUNTRY, PChar(nil), 0);
  SetLength(st, i);
  GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SENGCOUNTRY, PChar(st), i);
  SetLength(st, i-1);
  st:=UpperCase(st);
  
  if st='JAPAN' then
  begin
    DispLang:= LANG_JP;
  end
  else
  begin
    DispLang:= LANG_EN;
  end;
  
  NewLang := DispLang; // 変更後の言語

  // タイマー精度
  timeBeginPeriod(1);

  // 初期化処理
  rom_loaded  := False;
  playing     := False;           // プレイ中じゃない

  ScrollX     := 0;
  SongDrag    := False;
  NameDrag    := False;

  RctNorm     := Rect(290, 5, 312,33);
  RctList     := Rect(317, 5, 339,33);
  RctNext     := Rect(344, 5, 366,33);
  RctSong     := Rect(47,  8, 47+233, 8+22);
  RctGameDesc := Rect(47, 42, 47+318,42+16);
  RctLV       := Rect( 8,  7, 30,145);
  RctSongName := Rect(47, 58, 47+318,58+16);

  ImgBack     := TBitmap.Create;
  ImgDigits   := TBitmap.Create;
  ImgIcons    := TBitmap.Create;
  ImgLevel    := TBitmap.Create;
  AlphaBitmap := TBitmap.Create;

  Buffer                    := TBitmap.Create;
  Buffer.Width              := THEME_DESIGN_WIDTH;
  Buffer.Height             := THEME_DESIGN_HEIGHT;
  Buffer.PixelFormat        := pf24bit;
  Buffer.Canvas.Brush.Style := bsClear;

  DisplayBuffer := TBitmap.Create;
  DisplayBuffer.PixelFormat := pf24bit;
  DisplayBuffer.SetSize(PaintBox1.ClientWidth, PaintBox1.ClientHeight);
  DisplayBuffer.Canvas.Brush.Style := bsClear;

  Buffer.Canvas.Font.Name   := Form1.Font.Name;
  Buffer.Canvas.Font.Charset:= ANSI_CHARSET;

  
  // ----------------------------------

  Indicator := DIGI_STOP;
  ResetTimer;

  Flush_Peaks;
  current_peak:=0;
  PeakL := 0;
  PeakR := 0;
  VelL  := 0;
  VelR  := 0;

  CurrentIndex  := -1;
  PauseCount    := -1;
  recording     := False;
  CurrentGameID := -1;

  TrayIconTip:='BridgeM1';

  // listsフォルダのチェック
  If not DirectoryExists('lists') then
    CreateDir('lists');

  // VU_Latency
  {if pos('0.7.4',M1String(m1snd_get_info_str(M1_SINF_COREVERSION, 0)))<>0 then
    VU_Latency:=46
  else
  if pos('0.7.3',M1String(m1snd_get_info_str(M1_SINF_COREVERSION, 0)))<>0 then
    VU_Latency:=46
  else
    VU_Latency:=17;}

  VU_Latency:=48;

  // 初期値
  wav_path          := 'waves';   // デフォルトwav_path
  SetLength(rom_path,1);          // デフォルトrom_path
  rom_path[0]       := 'roms';
  Sample_Rate       := 48000;     // Sample Rate
  Stereo_Mix        := 0;         // Stereo Mix
  MasterVolume      := 100;       // Post Volume

  Hexadecimal       := False;     // 16進数
  RefreshRate       := 2;         // Timer=60fps
  ScrollSpeed       := 2;         // 1.0x

  fm1.X := Form1.Left;            // iniが無いときに備えて初期化
  fm1.Y := Form1.Top;
  fm2.X := fm1.X;
  fm2.Y := fm1.Y + Form1.Height;
  fm2_w := DesignPixels(Form1.Width);
  fm2_h := DesignPixels(Form1.Height);

  fm3.X:=0; fm3.Y:=0;
  fm3_w:=0; fm3_h:=0;

  fm6.X:=fm1.X+Form1.Width;
  fm6.Y:=fm1.Y;

  PlayList          := True;
  MixerWindow       := True;
  Normalize         := True;
  UseFixedVolume    := False;
  UseNormalize      := True;
  
  Display_peaks     := True;
  //Always_List_Mode  := True;
  AutoMoveOn        := True;
  Repeat_One        := False;
  Keep_Scrolling    := True;
  Rom_Condition     := ALL_SETS;
  Reset_Normalize   := False;
  SystemTray        := True;
  AlwaysOnTop       := False;

  UserWavFileName   := False;
  Wav_Format        := '%ORDR %GDSC (%ZIP) [#%TNUM] %SDSC';
  OptionTabIndex    := 0; // Form4の表示タブ

  QueryMaker        := '(Manufaturer)';
  QuerySystem       := '(System)';
  QueryChip         := '(Chip)';
  QueryWord         := '';

  CurrentSongNo     := -1;
  CurrentTheme      := '';

  UseDefaultTime  := True;
  DefaultPlayTime := 105000; // 1m45s (ms)
  Attachable:=True;

  FixedVolume := -1;

  DefaultFadeout := True;
  DefaultFOLength := 10000; //  10s (ms)

  // Column sort history
  for i:=0 to Length(SortHistory)-1 do
    SortHistory[i] := i+1;

  // Default track list font
  TLFont := TFont.Create;
  TLFont.Name := 'Tahoma';
  TLFont.Size := 8;

  // ini読み込み
  LoadIni;

  // デフォルト設定読み込み
  LoadDefaultCFG;
  
  // コアの初期化
  m1snd_setoption(M1_OPT_LANGUAGE,    LANG_NONE); // dummy to avoid loading lsts by core
  m1snd_setoption(M1_OPT_FIXEDVOLUME, 100);
  m1snd_setoption(M1_OPT_SAMPLERATE,  Sample_Rate);
  m1snd_setoption(M1_OPT_RETRIGGER,   0);
  m1snd_setoption(M1_OPT_WAVELOG,     0);
  m1snd_setoption(M1_OPT_USELIST,     0);
  m1snd_setoption(M1_OPT_STEREOMIX,   Stereo_Mix);
  m1snd_init(nil, m1ui_message);

  // Reset Normalize設定
  if Reset_Normalize then
    m1snd_setoption(M1_OPT_RESETNORMALIZE, 0)
  else
    m1snd_setoption(M1_OPT_RESETNORMALIZE, 1);

  ListMode:=False;

  // M1サポート数
  max_games := m1snd_get_info_int(M1_IINF_TOTALGAMES, 0);

  // ゲーム情報
  RL:=TList.Create;
  RLSub:=TList.Create;
  
  for i:=0 to max_games-1 do
  begin

    new(NewItem);
    
    drv:=m1snd_get_info_int(M1_IINF_BRDDRV,i);

    NewItem.RomName  := M1String(m1snd_get_info_str(M1_SINF_ROMNAME,    i));
    NewItem.Master   := M1String(m1snd_get_info_str(M1_SINF_PARENTNAME, i));
    NewItem.Title    := M1String(m1snd_get_info_str(M1_SINF_VISNAME,    i));
    NewItem.Year     := M1String(m1snd_get_info_str(M1_SINF_YEAR,       i));
    NewItem.Maker    := M1String(m1snd_get_info_str(M1_SINF_MAKER,      i));
    NewItem.System   := M1String(m1snd_get_info_str(M1_SINF_BNAME,      drv));
    NewItem.Hard     := M1String(m1snd_get_info_str(M1_SINF_BHARDWARE,  drv));
    NewItem.Kana     := M1String(m1snd_get_info_str(M1_SINF_VISNAME,    i)); // added in 0.4.3
    NewItem.NumPlay  := 0;

    if FileExists(Exe_Path+List_Path+NewItem.RomName+'.lst') then
      NewItem.List:= 'Yes'
    else
      NewItem.List:= '';

    //
    NewItem.Maker := AnsiReplaceText( NewItem.Maker, '/', ' / ');
    NewItem.Maker := AnsiReplaceText( NewItem.Maker, '  /  ', ' / ');

    if NewItem.RomName='tigerh' then
      NewItem.Maker:='[Toaplan] Taito';
      

    if ((Pos('Technos', NewItem.Maker)<>0) and
        (Pos('Technos Japan', NewItem.Maker)=0) and
        (Pos('Technosoft', NewItem.Maker)=0) )then
      NewItem.Maker := AnsiReplaceText( NewItem.Maker, 'Technos', 'Technos Japan');

    if ((Pos('Seibu', NewItem.Maker)<>0) and
        (Pos('Seibu Kaihatsu', NewItem.Maker)=0)) then
      NewItem.Maker := AnsiReplaceText( NewItem.Maker, 'Seibu', 'Seibu Kaihatsu');


    NewItem.Maker := AnsiReplaceText( NewItem.Maker, 'Video System Co.', 'Video System');
    NewItem.Maker := AnsiReplaceText( NewItem.Maker, 'V-System Co.', 'Video System');
    NewItem.Maker := AnsiReplaceText( NewItem.Maker, 'Data East Corporation', 'Data East');
    NewItem.Maker := AnsiReplaceText( NewItem.Maker, 'Data East Pinball', 'Data East');
    NewItem.Maker := AnsiReplaceText( NewItem.Maker, 'Sega / Coreland', 'Coreland / Sega');
    NewItem.Maker := AnsiReplaceText( NewItem.Maker, 'Taito America Corp.', 'Taito America');
    NewItem.Maker := AnsiReplaceText( NewItem.Maker, 'Taito America Corporation', 'Taito America');
    NewItem.Maker := AnsiReplaceText( NewItem.Maker, 'Taito Corporation Japan', 'Taito');
    NewItem.Maker := AnsiReplaceText( NewItem.Maker, 'Taito Corporation', 'Taito');
    NewItem.Maker := AnsiReplaceText( NewItem.Maker, 'Taito Europe Corporation', 'Taito Europe');
    NewItem.Maker := AnsiReplaceText( NewItem.Maker, 'Alpha Denshi Co.', 'Alpha Denshi');
    NewItem.Maker := AnsiReplaceText( NewItem.Maker, 'Hi Tech Exp', 'Hi-Tech Exp');
    NewItem.Maker := AnsiReplaceText( NewItem.Maker, 'BreezaSoft', 'BrezzaSoft');
    
    if NewItem.Maker='Whiteboard' then NewItem.Maker:='White Board';
    if NewItem.Maker='Techno Soft' then NewItem.Maker:='Technosoft';
    
    NewItem.Idx:=i;
    NewItem.Rom_state:=0;
    RL.Add(NewItem);

  end;

  // Normalization
  if normalize=true then
    m1snd_setoption(M1_OPT_NORMALIZE, 1)
  else
    m1snd_setoption(M1_OPT_NORMALIZE, 0);

  // Repeat
  btnRepeat.Down:=Repeat_One;

  // 言語別のパス設定
  Case DispLang of
    // 日本語
    LANG_JP :
    begin
      List_Path:=IncludeTrailingPathDelimiter(JoinPath('lists', 'jp'));
      // ゲーム名置き換えファイル読み込み
      if LoadGameNames=false then
      begin
        if DispLang=LANG_JP then
          Windows.MessageBox( Form1.Handle,
                              PChar('古い"bm1.txt"ファイルが見つかりました。　 '+#13#10+
                              '場所：'+ EXE_Path+List_Path+'bm1.txt  '+#13#10#13#10+
                              'ゲーム名を日本語で表示するにはこのファイルが必要です。　　'+#13#10+
                              '付属の utf-8 版と差し替えてください。  '),
                              'BridgeM1 Warning',
                              MB_OK or MB_ICONWARNING);
       end;
    end;
    
    // 英語
    LANG_EN :
    begin
      List_Path:=IncludeTrailingPathDelimiter(JoinPath('lists', 'en'));
    end;

  end;

  
  // TrackList用TList
  TL:=TList.Create;

  // Initialize Volume Controller
  FKnobWidth := Image10.Picture.Width;
  FKnobHeight := Image10.Picture.Height;
  KnobRect:=Rect(0, 0, FKnobWidth, FKnobHeight);

end;

procedure TForm1.FormShow(Sender: TObject);
begin

  // Debug
  DebugTime:=TimeGetTime;

  GetVolume;

  // Hexadecimal 設定
  Set_Hexadecimal(Hexadecimal);

  // Theme初期化と設定
  clrLWPlaying  := $40ccff;
  clrLWSelected := $405066;

  Theme(CurrentTheme);

  // メインフォームの位置チェック
  if PtinRect(Screen.DesktopRect,fm1) then
  begin
    Form1.Left:= fm1.X;
    Form1.Top := fm1.Y;
  end;
  
  if PlayList then
    Form2.Show;

  if MixerWindow then
    Form6.Show;

  // タイマー始動
  Timer1.Enabled:=True;

  // Idle 送信スレッド始動
  IdleOn := True;
  Thread_on := True;
  IdleThread := TIdleThread.Create(False);
  IdleThread.OnTerminate := IdleThreadDone;
  IdleThread.FreeOnTerminate:=True;
  IdleThread.Priority:=tpTimeCritical;

  //
  ResetFormOrder(AlwaysOnTop);

end;


// --------------------------------------------------------------------
// 終了処理
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  //
  m1snd_run(M1_CMD_PAUSE, 0);
  
  IdleOn:=False;
  if Thread_on then IdleThread.Terminate;

  // ロード中の場合
  if Loading then
  begin
    //Action := caNone;
    //exit;
  end;

  // Save Game Config
  if not Loading then
    SaveGameCFG(CurrentGameID);

  // Save settings
  SaveIni;

  // Ensure termination of the idle sender thread
  While (Thread_on) do
  begin
    Application.ProcessMessages;

  end;


  m1snd_shutdown;

  timeEndPeriod(1);
  Application.Terminate;
  
end;


procedure TForm1.FormDestroy(Sender: TObject);
var i : Integer;
begin

  // TROMListの各項目のメモリ解放
  for i:= 0 to RL.count-1 do
    dispose(PROMList(RL[i]));
  if RL.Count<>0 then RL.Clear;

  // ROMList用TList
  RL.Free;
  RLSub.Free;

  // TListの各項目のメモリ解放
  for i:= 0 to TL.count-1 do
    dispose(PTrackList(TL[i]));
  if TL.Count<>0 then TL.Clear;

  // TrackList用TList
  TL.Free;

  // TrackListの表示フォント
  TLFont.Free;

  //
  imgBack.Free;
  imgDigits.Free;
  imgIcons.Free;
  imgLevel.Free;
  AlphaBitmap.Free;
  Buffer.Free;
  DisplayBuffer.Free;

  for i := 0 to MAIN_SPEEDBUTTON_COUNT - 1 do
    FMainButtonGlyphs[i].Free;

end;

// ---------------------------------------------------------------------
//  ボタン操作  
procedure TForm1.btnPlayClick(Sender: TObject);
var i: integer;
begin

  // リストのリロード対策
  // リスト内の位置が不定のとき
  if ListLoaded and ListMode and (CurrentIndex=-1) then
  begin
    // デフォルト曲に設定する
    CurrentSongNo:=DefaultSongNo;
    for i:=0 to TL.Count-1 do
    begin
      if PTrackList(TL[i]).Song_No=CurrentSongNo then
      begin
        CurrentIndex:=i;
        break;
      end;
    end;
    
  end;

  //
  if CurrentIndex<>-1 then
  begin
    CurrentPlayTime :=PTrackList(TL[CurrentIndex]).PlayTime;
    CurrentFadeout :=PTrackList(TL[CurrentIndex]).FadeOut;
    CurrentFOLength :=PTrackList(TL[CurrentIndex]).FOLength;
  end;

  ShowSongName(CurrentSongNo);

  if (not pause) or (not playing) then // ポーズ中以外は最初からプレイ
  begin
    ResetTimer;
    ScrollX:=0;
    ScrollWaitCount:=0;
    m1snd_run(M1_CMD_SONGJMP, CurrentSongNo);
  end
  else
  begin
    // 再生開始のTickCountをずらす
    StartTick := StartTick + (Integer(TimeGetTime)-PauseTick);
  end;

  m1snd_run(M1_CMD_UNPAUSE, 0);

  pause:=False;
  playing:=True;
  StartTimer;

  Form2.MakeVisible(CurrentIndex); // リストをスクロール
  Form2.ListBox1.Invalidate;

end;

procedure TForm1.btnStopClick(Sender: TObject);
begin

  StopPlay;

end;

procedure TForm1.btnPauseClick(Sender: TObject);
begin

  // 再生→ポーズ
  if playing and (not pause) then
  begin
    m1snd_run(M1_CMD_PAUSE, 0);
    PauseTick:=TimeGetTime;
    PauseCount:=0;
    pause:=True;
    Indicator:=DIGI_PAUSE;
    Flush_Peaks;
    exit;
  end;

  // ポーズ解除
  if playing and pause then
  begin
    m1snd_run(M1_CMD_UNPAUSE, 0);
    // 再生開始のTickCountをずらす
    StartTick := StartTick + (Integer(TimeGetTime)-PauseTick);
    pause:=False;
    playing:=True;
    StartTimer;
  end;

end;

Procedure TForm1.btnNextClick(Sender: TObject);
var
  i:Integer;
begin

  if ListMode then
  begin

    for i:=CurrentIndex+1 to TL.Count-1 do
    begin
      if PTrackList(TL[i]).Song_No<>-1 then
      begin
        CurrentIndex:=i;
        StartPlay(PTrackList(TL[i]).Song_No);
        Form2.MakeVisible(i); // リストをスクロール
        Form2.ListBox1.Invalidate; // ここから呼ばないと更新されない
        Exit;
      end;
    end;

  end
  else
  begin

	  if (CurrentSongNo < max_song_num) and
       (CurrentSongNo < 9999999) then
    begin
      Inc(CurrentSongNo);

      // リスト有効なら
      if ListLoaded then
      begin
        CurrentIndex:=-1;
        for i:=0 to TL.Count-1 do // リスト内を探す
        begin
          if CurrentSongNo=PTrackList(TL[i])^.Song_No then
          begin
            CurrentIndex:=i;
            // ボタンを本当にクリックしたとき
            if (Sender <> nil) then
            begin
              Form2.MakeVisible(i); // リストをスクロール
            end;

            break;
          end;
        end;

      end;

      StartPlay(CurrentSongNo);
      Form2.ListBox1.Invalidate; // ここから呼ばないと更新されない
    end;
    
  end;

end;

procedure TForm1.btnPrevClick(Sender: TObject);
var
  i:Integer;
  StartIndex: Integer;
begin

  if ListMode then
  begin

    // リロード対策 (曲数がcurrentindexに満たない時)
    if TL.Count-1 < CurrentIndex-1 then
      StartIndex := TL.Count-1 // 検索を始めるインデックス
    else
      StartIndex := CurrentIndex-1;
      
    // リスト内の前の曲を探す
    for i:=StartIndex downto 0 do
    begin

      if PTrackList(TL[i]).Song_No<>-1 then
      begin
        CurrentIndex:=i;
        StartPlay(PTrackList(TL[i]).Song_No);
        Form2.MakeVisible(i); // リストをスクロール
        Form2.ListBox1.Invalidate; // ここから呼ばないと更新されない
        Exit;
      end;
    end;

  end
  else
  begin
  if (CurrentSongNo > 0 ) then //m1snd_get_info_int(M1_IINF_MINSONG, 0)
  begin
    // 曲名はリストから探す
    if ListLoaded then
    begin
      CurrentIndex:=-1;
      for i:=0 to TL.Count-1 do
      begin
        if PTrackList(TL[i])^.Song_No=CurrentSongNo-1 then
        begin
          CurrentIndex:=i;
          Form2.MakeVisible(i); // リストをスクロール
          break;
        end;
      end;
    end;

    StartPlay(CurrentSongNo-1);
    Form2.ListBox1.Invalidate; // ここから呼ばないと更新されない
    end;
  end;

end;


procedure TForm1.btnListClick(Sender: TObject);
begin

  if PlayList then
    Form2.Close
  else
    Form2.Show;

end;


procedure TForm1.btnRepeatClick(Sender: TObject);
begin

  Repeat_One:=btnRepeat.Down;

end;

//---------------------------------------------------------------------
// ゲームのロード
procedure TForm1.btnLoadClick(Sender: TObject);
var
  i:Integer;
  prevGameID: Integer;
begin

  if btnLoad.Enabled=False then exit;
  btnLoad.Enabled:=False;


  prevGameID:=CurrentGameID;
  

  if (Form3.ShowModal = mrOK) and (CurrentGameID<>-1) then
  begin

    // 直前のゲームの設定保存
    SaveGameCFG(prevGameID);

    // ゲーム設定を読み込む
    LoadGameCFG(CurrentGameID);

    // Mixerウィンドウを無効に
    Form6.DisableMixer;

    Form2.label2.Caption:='';
    Form2.label2.Cursor:=crDefault;

    // 録音を無効に
    if recording then
    begin
      btnRec.Down:=False;
      m1snd_setoption(M1_OPT_WAVELOG,0);
      recording:=False;
      Form1.Caption:=APPNAME;
    end;

    // 音停止とリセット
    CurrentSongNo:=-1;  // 曲番号リセット
    CurrentIndex:=-1;  // リスト選択項目無効
    StopPlay;

    // 操作ボタン無効
    btnPrev.Enabled  := False;
    btnPlay.Enabled  := False;
    btnPause.Enabled := False;
    btnNext.Enabled  := False;
    btnStop.Enabled  := False;
    btnRec.Enabled   := False;

    // 表示・新処理
    desc       := PRomList(RL[CurrentGameID]).Title;
    SongName   := '';
    manu       := PRomList(RL[CurrentGameID]).Year+' '+PRomList(RL[CurrentGameID]).Maker;
    system     := PRomList(RL[CurrentGameID]).System;
    hard       := PRomList(RL[CurrentGameID]).Hard;
    RomName    := PRomList(RL[CurrentGameID]).RomName;
    parentname := PRomList(RL[CurrentGameID]).Master;

    FixedVolume := -1;
    DefaultSongNo:=m1snd_get_info_int(M1_IINF_DEFSONG, CurrentGameID);

    // プレイリスト読み込み
    ListLoaded:=LoadList(PRomList(RL[CurrentGameID]).RomName);
    Set_ListMode(ListLoaded);

    // Fixed Volume関係
    if FixedVolume=-1 then
      m1snd_setoption(M1_OPT_FIXEDVOLUME, 100)
    else
      m1snd_setoption(M1_OPT_FIXEDVOLUME, FixedVolume);

    // Use_FixedVolume
    if ( FixedVolume <> -1 ) and UseFixedVolume then
      Set_Normalize(False)
    else
      Set_Normalize(UseNormalize);

    if not Normalize then
    begin
      if FixedVolume <> -1 then
        Form2.Label1.Caption:='Fixed Volume: '+InttoStr(FixedVolume) +' %'
      else
        Form2.Label1.Caption:='Fixed Volume: --- %';
    end;

    // デフォルト曲設定
    m1snd_setoption(M1_OPT_DEFCMD, DefaultSongNo);
    CurrentSongNo:=DefaultSongNo;

    // リストの項目選択
    if ListLoaded then
    begin
      for i:=0 to TL.Count-1 do
      begin
        if PTrackList(TL[i]).Song_No=CurrentSongNo then
        begin
          Form2.ListBox1.ItemIndex:=i;
          CurrentIndex:=i;
          break;
        end;
      end;
    end;

    // ピークバッファクリア
    Flush_Peaks;
    
    // 入力レベル0に
    CurrentL:=0;
    CurrentR:=0;
    
    // IDLE送信停止
    IdleOn := False;

    // リストの更新を終わらせてから
    Application.ProcessMessages;

    // タイマー停止
    Timer1.Enabled:=False;

    // ゲームをロード
    m1snd_setoption(M1_OPT_RESETNORMALIZE, 0);
    m1snd_run(M1_CMD_UNPAUSE,0);
    Pause   := False;
    Loading := True;   // ロード中に本体を終了できないように
    m1snd_run(M1_CMD_GAMEJMP, CurrentGameID);



    if CurrentGameID<>-1 then // ロード成功時のみ
    begin

      // max_song_num
      if max_song_num = -1 then
      begin
        max_song_num:=m1snd_get_info_int(M1_IINF_MAXSONG, 0);
      end;

      if not Reset_Normalize then
        m1snd_setoption(M1_OPT_RESETNORMALIZE, 1);

      Form6.ResetMixer;

      // Play Times
      PRomList(RL[CurrentGameID]).NumPlay := PRomList(RL[CurrentGameID]).NumPlay +1;
    end;

  end;

  btnLoad.Enabled:=True;
  Form2.ListBox1.Invalidate;

  // ウィンドウの重ね合わせを初期化
  if not AlwaysOnTop then
  begin
    SetWindowPos( Form1.Handle, HWND_TOP, 0, 0, 0, 0,
                  SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
    SetWindowPos( Form2.Handle, HWND_TOP, 0, 0, 0, 0,
                  SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
    SetWindowPos( Form6.Handle, HWND_TOP, 0, 0, 0, 0,
                  SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
  end;

  // リストロードされたら
  if Form2.Showing and ListLoaded then
    Form2.ListBox1.SetFocus;

end;


//---------------------------------------------------------------------
//  曲名の表示
//  曲の長さも取得
procedure TForm1.ShowSongName(Song_No:Integer);
var
  S,T:WideString;
begin

  CurrentPlayTime:=0;

  // プレイリストが無効、曲がリストに無い場合
  if (not ListLoaded) or (CurrentIndex=-1) then
  begin
  
    // トレイアイコン
    if Hexadecimal then
      S:=RomName+': '+ AnsiLowerCase(Format('0x%.2x ',[Song_No]))
    else
      S:=RomName+': #'+InttoStr(Song_No);

    ModifyTrayIcon(S);
    
    CurrentSongName:='';  // 素の曲名
    SongName:='';         // 曲番+曲名+時間
    exit;
    
  end;

  S:='';
  T:='';

  // フェードアウト情報
  CurrentFadeOut  := PTrackList(TL[CurrentIndex]).FadeOut;
  CurrentFOLength := PTrackList(TL[CurrentIndex]).FOLength;

  // 曲名保持 (wavファイル名用)
  CurrentSongName := PTrackList(TL[CurrentIndex]).Text;

  // 曲番号を頭につける
  if Hexadecimal then
    S:=AnsiLowerCase(Format('0x%.2x ',[PTrackList(TL[CurrentIndex]).Song_No]))+
                     CurrentSongName
  else
    S:='#'+PTrackList(TL[CurrentIndex]).Song_St+' '+CurrentSongName;

  // トレイアイコンTIP更新
  ModifyTrayIcon(S);


  // AutoMoveでプレイ時間が指定されているときは曲名に付ける
  if (ListMode) and (PTrackList(TL[CurrentIndex]).PlayTime <> 0) then
  begin

    // フェードアウト指定
    if PTrackList(TL[CurrentIndex]).FadeOut = foYes then
      S:=S+' <..'+FormatPlayTime(PTrackList(TL[CurrentIndex]).PlayTime)+'>'
    else
      S:=S+' <'+FormatPlayTime(PTrackList(TL[CurrentIndex]).PlayTime)+'>';

    CurrentPlayTime:=PTrackList(TL[CurrentIndex]).PlayTime;
  end;

  SongName:=S;

end;



//---------------------------------------------------------------------
// キーショートカット
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  if Shift=[ssCtrl] then
  begin

    case Key of

      Ord('W'):   // Ctrl+W
      begin
        Application.Minimize;
      end;
      
      Ord('Q'):    // Cntl+Q
      begin
        Form1.Close;
        Application.Terminate;
        Exit;
      end;
    end;
  end;

  case Key of

      Ord('O'):    // Ctrl+O
      begin
        btnLoadClick(Self);
        Exit;
      end;
      
    8  :begin // BackSpace
      if Form2.Visible then
        Form2.SetFocus;
    end;

    111:begin
      //Image2Click(Self);
    end; // /

    106:begin
      //Image3Click(Self);
    end; // *

    96 :begin // Keypad 0
      btnLoadClick(Self);
    end;

    38 :begin // Up arrow
      MasterVolume:=MasterVolume+2048;
      if MasterVolume>65535 then
        MasterVolume:=65535;

      SetVolume(MasterVolume);
      DrawVolume;
    end;

    40 :begin // Down arrow
      MasterVolume:=MasterVolume-2048;
      if MasterVolume<0 then MasterVolume:=0;

      SetVolume(MasterVolume);
      DrawVolume;
    end;

  end;

  if btnPlay.Enabled then
  begin

    case Key of

    // Play
    Ord('X'),101 :
    begin // X, keypad 5
      if Integer(TimeGetTime)-KeyTickCount>KEY_REPEAT then
      begin
        btnPlayClick(Self); KeyTickCount:=TimeGetTime;
      end;
    end;

    // Next
    Ord('B'),107,102:
    begin  // B, keypad +,keypad 6
      if Integer(TimeGetTime)-KeyTickCount>KEY_REPEAT then
      begin
        btnNextClick(Self);
        KeyTickCount:=TimeGetTime;
      end;
    end;

    // Stop
    Ord('V'): StopPlay;

    // Pause
    Ord('C'),32 :
    begin
      if Integer(TimeGetTime)-KeyTickCount>KEY_REPEAT then
      begin
        btnPauseClick(Self);
        KeyTickCount:=TimeGetTime;
      end;
    end;

    // Previous
    Ord('Z'),109,100:
    begin // Z,keypad -, keypad 4
      if Integer(TimeGetTime) - KeyTickCount > KEY_REPEAT then
      begin
        btnPrevClick(Self);
        KeyTickCount:=TimeGetTime;
      end;
    end;

    VK_RETURN :begin
        if ListLoaded then
        begin
          if Integer(TimeGetTime)-KeyTickCount>KEY_REPEAT then
          begin
            Form2.ListBox1DblClick(Self); KeyTickCount:=TimeGetTime;
          end;
        end
        else
        begin
          if Integer(TimeGetTime)-KeyTickCount>KEY_REPEAT  then
          begin
            btnPlayClick(Self); KeyTickCount:=TimeGetTime;
          end;
        end;
      end;

    end;
  end;
end;


//----------------------------------------------------------------------
// テーマ読み込みと適用
procedure TForm1.Theme(ThemeName : String);
var
  F1 : TextFile;
  St : String;
  count : Integer;
  Loading : String; // ロード中のファイル名

begin

  // デフォルト
  imgBack.LoadFromResourceName(HInstance,'BACK');
  imgDigits.LoadFromResourceName(HInstance,'DIGITS');
  AlphaBitmap.LoadFromResourceName(HInstance,'DIGITS_ALPHA');
  imgIcons.LoadFromResourceName(HInstance,'ICONS');
  imgLevel.LoadFromResourceName(HInstance,'LEVEL');
  //IntensityToAlpha(imgDigits, AlphaBitmap);

  imgBack.PixelFormat:=pf24bit;
  imgDigits.PixelFormat:=pf24bit;
  AlphaBitmap.PixelFormat:=pf24bit;

  DIGIT_WIDTH  := 16;
  COLON_WIDTH  :=  8;
  clrGameDesc  := $00003F87;
  clrSong      := $00003f87;
  clrInfoLabel := $00003f87;
  clrInfoDesc  := $00003f87;
  clrPanel     := $00111111;
  clrLWBack    := $00333333;
  clrLWFont    := $00ABABAB;

  // form2で共有
  clrLWPlaying  := $0040ccff;
  clrLWSelected := $00405066;

  // Validate Theme
  if not DirectoryExists(JoinPath(JoinPath(exe_path, THEMEDIR), ThemeName)) then
    ThemeName:='';
  if not FileExists(JoinPath(JoinPath(JoinPath(exe_path, THEMEDIR), ThemeName), 'colors.ini')) then
    ThemeName:='';

  
  if ThemeName='' then
  begin

  end
  else
  begin

    AssignFile(F1, JoinPath(JoinPath(JoinPath(exe_path, THEMEDIR), ThemeName), 'colors.ini'));
    Reset(F1);
    Count:=0;

    try
      while not Eof(F1) do
      begin
        Inc(Count);
        ReadLn(F1,St);
        UpperCase(ST);

        if (pos('//',St)=1) then

        else
        if (pos('MW_FRAMECOLOR',St)<>0) then
        begin
          St:=Trim(Copy(St,pos(':=',St)+2,Length(St)));
          clrPanel:=StrtoInt('$'+St);
        end else
        if (pos('TB_DESCCOLOR',St)<>0) then
        begin
          St:=Trim(Copy(St,pos(':=',St)+2,Length(St)));
          clrGameDesc:=StrtoInt('$'+St);
        end else
        if (pos('TB_SONGCOLOR',St)<>0) then
        begin
          St:=Trim(Copy(St,pos(':=',St)+2,Length(St)));
          clrSong:=StrtoInt('$'+St);
        end else
        if (pos('IB_LABELCOLOR',St)<>0) then
        begin
          St:=Trim(Copy(St,pos(':=',St)+2,Length(St)));
          clrInfoLabel:=StrtoInt('$'+St);
        end else
        if (pos('IB_DESCCOLOR',St)<>0) then
        begin
          St:=Trim(Copy(St,pos(':=',St)+2,Length(St)));
          clrInfoDesc:=StrtoInt('$'+St);
        end else
        if (pos('LW_FONTCOLOR',St)<>0) then
        begin
          St:=Trim(Copy(St,pos(':=',St)+2,Length(St)));
          clrLWFont:=StrtoInt('$'+St);
        end else
        if (pos('LW_BGCOLOR',St)<>0) then
        begin
          St:=Trim(Copy(St,pos(':=',St)+2,Length(St)));
          clrLWBack:=StrtoInt('$'+St);
        end else
        if (pos('LW_PLAYINGCOLOR',St)<>0) then
        begin
          St:=Trim(Copy(St,pos(':=',St)+2,Length(St)));
          clrLWPlaying:=StrtoInt('$'+St);
        end else
        if (pos('LW_SELCOLOR',St)<>0) then
        begin
          St:=Trim(Copy(St,pos(':=',St)+2,Length(St)));
          clrLWSelected:=StrtoInt('$'+St);
        end else
        if (pos('DIGIT_WIDTH',St)<>0) then
        begin
          St:=Trim(Copy(St,pos(':=',St)+2,Length(St)));
          DIGIT_WIDTH:=StrtoInt(St);
        end else
        if (pos('COLON_WIDTH',St)<>0) then
        begin
          St:=Trim(Copy(St,pos(':=',St)+2,Length(St)));
          COLON_WIDTH:=StrtoInt(St);
        end;

      end;

    except
      on EConvertError do
      begin
        St:='The color.ini file contains an invalid color value in line '+InttoStr(Count)+'.  '+#10#13#10#13+'Canceled loading the theme "'+ThemeName+'".  ';
        Windows.MessageBox(Form1.WindowHandle, PChar(St), 'Theme Load Error', MB_OK + MB_ICONSTOP);
        CloseFile(F1);
        Exit;
      end;
    end;
    CloseFile(F1);

    if not FileExists(JoinPath(JoinPath(JoinPath(exe_path, THEMEDIR), ThemeName), 'colors.ini')) then
    begin
      St:='Invalid theme file.'+#10#13+'Canceled loading "'+ThemeName+'".  ';
      Windows.MessageBox(Form1.WindowHandle, PChar(St), 'Theme Load Error', MB_OK + MB_ICONWARNING);
      Theme('');
      Exit;
    end;


    try

      Loading:='back.bmp';
      imgBack.LoadFromFile(JoinPath(JoinPath(THEMEDIR, ThemeName), 'back.bmp'));
      imgBack.PixelFormat:=pf24bit;

      Loading:='digits.bmp';
      imgDigits.LoadFromFile(JoinPath(JoinPath(THEMEDIR, ThemeName), 'digits.bmp'));
      imgDigits.PixelFormat:=pf24bit;

      Loading:='icons.bmp';
      imgIcons.LoadFromFile(JoinPath(JoinPath(THEMEDIR, ThemeName), 'icons.bmp'));
      imgIcons.PixelFormat:=pf24bit;

      Loading:='level.bmp';
      imgLevel.LoadFromFile(JoinPath(JoinPath(THEMEDIR, ThemeName), 'level.bmp'));
      imgLevel.PixelFormat:=pf24bit;


      AlphaBItmap.ReleaseHandle;

      if FileExists(JoinPath(JoinPath(THEMEDIR, ThemeName), 'alpha.bmp')) then
      begin
        Loading:='alpha.bmp';
        AlphaBitmap.LoadFromFile(JoinPath(JoinPath(THEMEDIR, ThemeName), 'alpha.bmp'));
        AlphaBitmap.PixelFormat:=pf24bit;
      end;

    except
      on EInvalidGraphic do
      begin
        St:='The bitmap file "'+Loading+'" is invalid.  '+#10#13#10#13+
            'Canceled loading the theme "'+ThemeName+'".  ';
        Windows.MessageBox(Form1.WindowHandle,PChar(St), 'Invalid theme file', MB_OK + MB_ICONSTOP);
        Theme('');
        Exit;
      end;
      on EFOpenError do
      begin
        St:='The bitmap file "'+Loading+'" is not found.  '+#10#13#10#13+'Canceled loading the theme "'+ThemeName+'".  ';
        Windows.MessageBox(Form1.WindowHandle,PChar(St), 'Invalid theme file', MB_OK + MB_ICONSTOP);
        Theme('');
        Exit;
      end;
    end;

  end;

  Shape1.Brush.Color:=clrPanel;
  Form2.Panel1.Color:=clrPanel;
  Form2.Panel1.ParentBackground:=False;
  Form2.Panel1.ParentBackground:=True;
  Form2.Panel1.ParentBackground:=False;


  Form2.ListBox1.Color:=clrLWBack;
  Form2.ListBox1.Font.Color:=clrLWFont;
  Form2.ListBox1.Canvas.Brush.Color:=clrLWBack;
  Form2.ListBox1.Invalidate;

  CurrentTheme:=ThemeName;

end;


// ---------------------------------------------------------------------
// ポップアップメニュー表示
// Themeフォルダのチェックと項目の追加

procedure TForm1.PopupMenu1Popup(Sender: TObject);
var
  NewItem: TMenuItem;
  sr: TSearchRec;

begin

  // Auto Moveon
  popAutoMove.Checked:=AutoMoveOn;

  // Normalize
  popNormalize.Checked:=Normalize;

  // ListMode
  popListMode.Checked:=ListMode;
  popListMode.Enabled:=ListLoaded;


  // Theme
  NewItem := TMenuItem.Create(PopupMenu1);
  NewItem.Caption := '<Default>';
  NewItem.onClick := PopupThemeClick;
  if CurrentTheme='' then
    NewItem.Checked := True;

  PopupMenu1.Items[0].Clear;
  PopupMenu1.Items[0].Add(NewItem);

  if FindFirst(JoinPath(JoinPath(exe_path, THEMEDIR), '*'),faAnyFile , sr) = 0 then
  try
    repeat
      if (sr.Attr and faDirectory ) <> 0 then // ディレクトリのみ対象にする
      begin
        if (sr.Name<>'.') and (sr.Name<>'..') then
        begin
          if FileExists(JoinPath(JoinPath(JoinPath(exe_path, THEMEDIR), sr.Name), 'colors.ini')) then
          begin
            NewItem := TMenuItem.Create(PopupMenu1);
            NewItem.Caption := sr.Name;
            NewItem.onClick := PopupThemeClick;
            if CurrentTheme=sr.Name then
              NewItem.Checked := True;
            PopupMenu1.Items[0].Add(NewItem);
          end;
        end;
      end;
    until FindNext(sr) <> 0; //repeat文の終了条件
  finally
    FindClose(sr); //FindFirstと対で使う、実行しないとメモリ関係のトラブルの原因に。
  end;

end;

procedure TForm1.PopupThemeClick(Sender: TObject);
var
  SelTheme : TMenuItem;
begin

  SelTheme := (Sender as TmenuItem);

  if SelTheme.Caption='<Default>' then
    Theme('')
  else
    Theme(SelTheme.Caption);

end;

procedure TForm1.Options1Click(Sender: TObject);
begin

  Form4.ShowModal;

end;


// --------------------------------------------------------------------
// マルチスレッド関係
procedure TForm1.IdleThreadDone(Sender: TObject);
begin
  Thread_on := false;
end;


//---------------------------------------------------------------------
// 録音ボタンの処理
procedure TForm1.btnRecClick(Sender: TObject);
begin

  if btnRec.Down then
  begin
    StopPlay;
    m1snd_setoption(M1_OPT_WAVELOG,1);
    recording:=True;
    Form1.Caption:=APPNAME + ' - [Wave Logging]';
  end
  else
  begin

    m1snd_setoption(M1_OPT_WAVELOG,0);

    // WAVファイルが閉じられないための応急処置
    if playing then
      m1snd_run(M1_CMD_SONGJMP, CurrentSongNo);

    recording:=False;
    StopPlay;
    Form1.Caption:=APPNAME;

  end;

end;



// --------------------------------------------------------------------
// システムトレイにアイコン作成
procedure TForm1.MakeTrayIcon;
begin

  if TrayIconTip=': #-1' then
    TrayIconTIp:='Game is not loaded';
    
  if Length(TrayIconTip)>64 then
  begin
    TrayIconTip:=Copy(TrayIconTip,1,60)+'...';
  end;

  NotifyIcon.cbSize := SizeOf(NotifyIcon);
  NotifyIcon.Wnd := Form1.Handle;
  NotifyIcon.uID := 1;
  NotifyIcon.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
  NotifyIcon.uCallbackMessage := UDM_NotifyTasktray;
  NotifyIcon.hIcon := Form2.Icon.Handle;
  StrPLCopy(NotifyIcon.szTip, TrayIconTip, Length(NotifyIcon.szTip)-1);
  Shell_NotifyIcon(NIM_ADD,@NotifyIcon);
end;

// システムトレイのアイコン削除
procedure TForm1.DeleteTrayIcon;
begin
   Shell_NotifyIcon(NIM_DELETE,@NotifyIcon);
end;

// システムトレイアイコンのTIP変更
procedure TForm1.ModifyTrayIcon(st:String);
begin

  TrayIconTip:=st;

  if Length(st)>64 then
  begin
    st:=Copy(st,1,60)+'...';
  end;
  
  if Tray_Icon then
  begin

    NotifyIcon.cbSize := SizeOf(NotifyIcon);
    NotifyIcon.Wnd := Form1.Handle;
    NotifyIcon.uID := 1;
    NotifyIcon.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
    NotifyIcon.uCallbackMessage := UDM_NotifyTasktray;
    NotifyIcon.hIcon := Form2.Icon.Handle;
    StrPLCopy(NotifyIcon.szTip, St, Length(NotifyIcon.szTip)-1);
    Shell_NotifyIcon(NIM_MODIFY,@NotifyIcon);    
  end;
end;


// システムトレイのイベント
procedure TForm1.SystemTrayEvent(var Msg : TMsg);
var
  Point : TPoint;  // Mouse position
begin

  case Msg.wParam of
    WM_LBUTTONDOWN:
    begin
    end;

    WM_RBUTTONDOWN:
    begin
      SetForegroundWindow(Handle);
      GetCursorPos(Point);
      PopupMenu2.Popup(Point.X, Point.Y);
    end;

    WM_LBUTTONDBLCLK:
    begin

      if Form3.Visible or Form4.Visible then
      begin
        exit;
      end;

      DeleteTrayIcon;
      SetForegroundWindow(Form1.Handle);
      Application.Restore;
    end;

    WM_RBUTTONDBLCLK:
    begin
    end;

  end;
end;

// -----------------------------------------------------------------
// popup menu of the system tray icon

procedure TForm1.PopupMenu2Popup(Sender: TObject);
begin

  popPrevious.Enabled := btnPlay.Enabled;
  popPlay.Enabled     := btnPlay.Enabled;
  popPause.Enabled    := btnPlay.Enabled;
  popStop.Enabled     := btnPlay.Enabled;
  popNext.Enabled     := btnPlay.Enabled;

  popLoad.Enabled     := not Form4.Visible;
  popOptions.Enabled  := not Form3.Visible;

end;

procedure TForm1.popLoadClick(Sender: TObject);
begin
  btnLoadClick(Sender);
end;

procedure TForm1.popOptionsClick(Sender: TObject);
begin
  //Options1Click(Sender);
  Form4.Show;
end;

procedure TForm1.popPreviousClick(Sender: TObject);
begin
  btnPrevClick(Sender);  
end;

procedure TForm1.popPlayClick(Sender: TObject);
begin
  btnPlayClick(Sender);
end;

procedure TForm1.popPauseClick(Sender: TObject);
begin
  btnPauseClick(Sender);
end;

procedure TForm1.popStopClick(Sender: TObject);
begin
  btnStopClick(Sender);
end;

procedure TForm1.popNextClick(Sender: TObject);
begin
  btnNextClick(Sender);
end;

procedure TForm1.popExitClick(Sender: TObject);
begin
  DeleteTrayIcon;
  SetForegroundWindow(Form1.Handle);
  Form1.Close;
  Application.Terminate;
end;



//------------------------------------------------------------------------------
// Volume Control
//
procedure TForm1.pbVolumeMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  if (X<VolRect.Right) and (X>VolRect.Left) then
  begin
    VolPoint.X:=X-VolRect.Left;
  end
  else
    VolPoint.X:=Scale96(5);

  VolRect.Left :=X-VolPoint.X;

  if VolRect.Left< 0 then VolRect.Left:=0;
  if VolRect.Left> (pbVolume.Width-VolumeKnobWidth) then
    VolRect.Left:=(pbVolume.Width-VolumeKnobWidth);

  VolRect.Right:=VolRect.Left+VolumeKnobWidth;

  MasterVolume:=VolRect.Left * 65535 div (pbVolume.Width-VolumeKnobWidth);
  SetVolume(MasterVolume);
  DrawVolume;

end;

procedure TForm1.pbVolumeMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin

  if ssLeft	in Shift then
  begin

    VolRect.Left:=X-VolPoint.X;

    if VolRect.Left<0 then
    begin
      VolRect.Left:=0;
    end
    else
    if VolRect.Left> (pbVolume.Width-VolumeKnobWidth) then
    begin
      VolRect.Left:=pbVolume.Width-VolumeKnobWidth;
    end;

    VolRect.Right:=VolRect.Left+VolumeKnobWidth;

    MasterVolume:=VolRect.Left * 65535 div (pbVolume.Width-VolumeKnobWidth);
    SetVolume(MasterVolume);
    DrawVolume;

  end;

end;

procedure TForm1.GetVolume;
var
  Volume: DWORD;
begin
  if waveOutGetVolume(HWAVEOUT(WAVE_MAPPER), @Volume) = MMSYSERR_NOERROR then
    MasterVolume := LoWord(Volume);
  //btnMute.Down:=M<>0;

  UpdateVolumeRect;
  DrawVolume();

end;

procedure TForm1.UpdateVolumeRect;
var
  TrackWidth: Integer;
begin
  TrackWidth := pbVolume.Width - VolumeKnobWidth;
  if TrackWidth < 0 then
    TrackWidth := 0;

  if TrackWidth = 0 then
    VolRect.Left := 0
  else
    VolRect.Left := MasterVolume * TrackWidth div 65535;
  VolRect.Right := VolRect.Left + VolumeKnobWidth;
  VolRect.Top := 0;
  VolRect.Bottom := pbVolume.Height;
end;

procedure TForm1.SetVolume(Value: Integer);
var
  Volume: DWORD;
begin
  if Value < 0 then
    Value := 0
  else if Value > 65535 then
    Value := 65535;

  MasterVolume := Value;
  UpdateVolumeRect;

  if Muted then
    Volume := 0
  else
    Volume := DWORD(Value) or (DWORD(Value) shl 16);

  waveOutSetVolume(HWAVEOUT(WAVE_MAPPER), Volume);
end;

function TForm1.Scale96(Value: Integer): Integer;
begin
  Result := MulDiv(Value, CurrentPPI, 96);
end;

function TForm1.DesignPixels(Value: Integer): Integer;
begin
  Result := MulDiv(Value, 96, CurrentPPI);
end;

function TForm1.VolumeKnobWidth: Integer;
begin
  Result := Scale96(FKnobWidth);
end;

function TForm1.MainSpeedButton(Index: Integer): TSpeedButton;
begin
  case Index of
    0: Result := btnRec;
    1: Result := btnPrev;
    2: Result := btnPlay;
    3: Result := btnPause;
    4: Result := btnStop;
    5: Result := btnNext;
    6: Result := btnLoad;
    7: Result := btnRepeat;
    8: Result := btnList;
    9: Result := btnMixer;
  else
    Result := nil;
  end;
end;

procedure TForm1.InitializeMainButtonImages;
var
  I: Integer;
  Button: TSpeedButton;
begin
  // Temporary conversion of legacy multi-state glyphs. Replace these
  // generated ImageLists when native high-resolution images are available.
  for I := 0 to MAIN_SPEEDBUTTON_COUNT - 1 do
  begin
    Button := MainSpeedButton(I);
    FMainButtonGlyphs[I] := TBitmap.Create;
    FMainButtonGlyphs[I].Assign(Button.Glyph);
    FMainButtonStateCounts[I] := Button.NumGlyphs;
    FMainButtonImages[I] := TImageList.Create(Self);
    FMainButtonImages[I].ColorDepth := cd32Bit;
    Button.Glyph := nil;
  end;
  BuildMainButtonImages;
end;

procedure TForm1.BuildMainButtonImages;
var
  I, State, StateCount, SourceWidth: Integer;
  Button: TSpeedButton;
  SourceFrame, Frame: TBitmap;
  MaskColor: TColor;
begin
  for I := 0 to MAIN_SPEEDBUTTON_COUNT - 1 do
  begin
    Button := MainSpeedButton(I);
    if (Button = nil) or (FMainButtonGlyphs[I] = nil) or
       FMainButtonGlyphs[I].Empty or (FMainButtonImages[I] = nil) then
      Continue;

    StateCount := FMainButtonStateCounts[I];
    if StateCount < 1 then
      StateCount := 1;
    SourceWidth := FMainButtonGlyphs[I].Width div StateCount;
    if SourceWidth = 0 then
      Continue;

    FMainButtonImages[I].Clear;
    FMainButtonImages[I].Width := Scale96(SourceWidth);
    FMainButtonImages[I].Height := Scale96(FMainButtonGlyphs[I].Height);

    SourceFrame := nil;
    Frame := nil;
    try
      SourceFrame := TBitmap.Create;
      Frame := TBitmap.Create;
      SourceFrame.PixelFormat := pf32bit;
      SourceFrame.SetSize(SourceWidth, FMainButtonGlyphs[I].Height);
      for State := 0 to StateCount - 1 do
      begin
        SourceFrame.Canvas.CopyRect(
          Rect(0, 0, SourceWidth, FMainButtonGlyphs[I].Height),
          FMainButtonGlyphs[I].Canvas,
          Rect(State * SourceWidth, 0, (State + 1) * SourceWidth,
            FMainButtonGlyphs[I].Height));
        ScaleImageBicubicGDIPlus(SourceFrame, Frame,
          FMainButtonImages[I].Width, FMainButtonImages[I].Height);
        MaskColor := Frame.Canvas.Pixels[0, Frame.Height - 1];
        FMainButtonImages[I].AddMasked(Frame, MaskColor);
      end;
    finally
      Frame.Free;
      SourceFrame.Free;
    end;

    Button.Images := FMainButtonImages[I];
    Button.ImageIndex := 0;
    if StateCount > 1 then
      Button.DisabledImageIndex := 1
    else
      Button.DisabledImageIndex := -1;
    if StateCount > 2 then
      Button.PressedImageIndex := 2
    else
      Button.PressedImageIndex := -1;
    if StateCount > 3 then
      Button.SelectedImageIndex := 3
    else
      Button.SelectedImageIndex := 0;
    Button.Invalidate;
  end;
end;

procedure TForm1.ChangeScale(M, D: Integer; IsDpiChange: Boolean);
begin
  inherited;
  BuildMainButtonImages;
  if DisplayBuffer <> nil then
    DisplayBuffer.SetSize(PaintBox1.ClientWidth, PaintBox1.ClientHeight);
  PreviousDesc := #0;
  PreviousSongName := #0;
  if FKnobWidth > 0 then
  begin
    GetVolume;
    PaintBox1.Invalidate;
  end;
end;

procedure TForm1.pbVolumePaint(Sender: TObject);
begin
  DrawVolume;
end;

procedure TForm1.DrawVolume;
var VolBuffer : TBitMap;
var Rct    : TRect;
begin

  VolBuffer := TBitMap.Create;
  VolBuffer.PixelFormat := pf24bit;
  VolBuffer.Width:=pbVolume.Width;
  VolBuffer.Height:=pbVolume.Height;
  VolBuffer.Canvas.Brush:=Form1.Canvas.Brush;
  Rct:=pbVolume.Canvas.ClipRect;

  Image10.Canvas.Lock;

  VolBuffer.Canvas.FillRect(Rct);

  // Triangle Background like WMP
  VolBuffer.Canvas.Pen.Color := clBtnHighlight;
  VolBuffer.Canvas.MoveTo(-1, pbVolume.Height-Scale96(3));
  VolBuffer.Canvas.LineTo(pbVolume.Width-1, pbVolume.Height-Scale96(3));
  VolBuffer.Canvas.LineTo(pbVolume.Width-1, Scale96(2));
  VolBuffer.Canvas.Pen.Color := clBtnShadow;
  VolBuffer.Canvas.LineTo(0, pbVolume.Height-Scale96(3));

  VolBuffer.Canvas.CopyRect(VolRect,Image10.Canvas,KnobRect);
  Image10.Canvas.UnLock;

  pbVolume.Canvas.CopyRect( pbVolume.Canvas.ClipRect,
                            VolBuffer.Canvas,
                            pbVolume.Canvas.ClipRect);

  VolBuffer.Free;
  pbVolume.Hint:=
    Format('Volume: %d%%',[VolRect.Left * 100 div (pbVolume.Width-VolumeKnobWidth)]);

end;

//procedure TForm1.btnMuteClick(Sender: TObject);
//begin
//  SetVolume(MasterVolume);
//  DrawVolume();
//end;


procedure TForm1.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

  MasterVolume:=MasterVolume-2048;
  if MasterVolume<0 then MasterVolume:=0;

  SetVolume(MasterVolume);
  DrawVolume();
  
end;

procedure TForm1.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

  MasterVolume:=MasterVolume+2048;
  if MasterVolume>65535 then
    MasterVolume:=65535;

  SetVolume(MasterVolume);
  DrawVolume();

end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  if ssLeft in Shift then
  begin
    ReleaseCapture;
     SendMessage(Handle, WM_SYSCOMMAND, SC_MOVE or 2, MakeLong(X, Y));
  end;

end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  i,j : Integer;
  temp: Integer;
  TGT : Integer;
begin

{  // debug
  Inc(frames);
  if frames=60 then
  begin
    Label1.Caption:= InttoStr((TimeGetTime-debugTime) div 6);
    frames:=0;
    debugTime:=TimeGetTime;
  end;
}

  // Pause点滅カウント処理
  if playing and pause then
  begin
    Inc(PauseCount);

    if (PauseCount=PAUSE_ON_FREQ) then
    begin

    end
    else
    if (PauseCount = PAUSE_ON_FREQ + PAUSE_OFF_FREQ) then
    begin
      PauseCount:=0;
    end;
  end
  else
    PauseCount:=0;


  // 時計とフェードアウトの処理
  if playing and not pause then
  begin

    i:=TimeCount div 1000; // 更新前の秒数
    j:=TimeCount div 100; // 1/10 sec

    try
      TGT:=TimeGetTime;
      TimeCount := TGT - StartTick;
    except
    on EIntOverflow do
      begin
        TimeCount:=1;
      end;
    end;

    if TimeCount>=3600000 then TimeCount:=1; // one hour to reset


    // 次曲に進む
    if AutoMoveOn then
    begin
      // デフォルト時間とプレイ時間のチェック
      // プレイ時間を優先する
      if ( UseDefaultTime and
          (TimeCount >= DefaultPlayTime) and
          (TimeCount < DefaultPlayTime + 3000) and
          (DefaultPlayTime > CurrentPlayTime))
        or
         ((TimeCount >= CurrentPlayTime) and
          (CurrentPlayTime <> 0))
      then
      begin

        if Repeat_One then
          btnPlayClick(nil)
        else
        if ListMode then
          List_Playnext
        else
          Form1.btnNextClick(nil);

      end;

    end
    else  // automoveがオフ
    begin
      if ListMode then  // リストモード
      begin
        if ( (TimeCount >= CurrentPlayTime) and // 曲時間になったら停止
             (CurrentPlayTime <> 0) ) then
          StopPlay;  

      end;
    end;

    // 時間表示（1秒おき）
    if ( i <> (TimeCount div 1000) ) then
    begin

      i:=TimeCount div 60000;
      stmm:=Format('%.2d',[i]);
      stss:=Format('%.2d',[(TimeCount-i*60000) div 1000]);

    end;

    // Fade Out [0.5.2] [0.6.0a10]
    // per 0.1 sec
    if ( j <> (TimeCount div 100) ) then
    begin

      // リストでフェードアウトON
      if (CurrentFadeOut=foYes) and (CurrentPlayTime<>0) and ListMode then
      begin
        if CurrentFOLength=0 then // フェード長指定なし
          SetFadeOut( TimeCount, CurrentPlayTime, DefaultFOLength )
        else                      // フェード長指定あり
          SetFadeOut( TimeCount, CurrentPlayTime, CurrentFOLength );
      end
      else
      // リストでフェードアウトOFF
      if (CurrentFadeOut=foNo) and ListMode then
      begin
        m1snd_setoption(M1_OPT_POSTVOLUME, 100);
      end
      else
      // デフォルトのフェードアウト
      if DefaultFadeout and AutoMoveOn and UseDefaultTime and (CurrentPlayTime=0) then
      begin
        SetFadeOut( TimeCount, DefaultPlayTime, DefaultFOLength);
      end
      else
        m1snd_setoption(M1_OPT_POSTVOLUME, 100);

    end;

  end;

  /// レベルメーターの処理
  // レベル値の加工
  if LevelL <= CurrentL then
    LevelL := CurrentL
  else
    LevelL := LevelL-DECAY;

  if LevelR <= CurrentR then
    LevelR := CurrentR
  else
    LevelR := LevelR-DECAY;

  if LevelL < 0 then LevelL :=0;
  if LevelR < 0 then LevelR :=0;

  // ピーク
  Inc(WaitCountL);
  if WaitCountL > WAIT then begin
    VelL:=VelL+ACCELERATION;
    PeakL:=PeakL-VelL;
  end;

  if Trunc(PeakL) <= LevelL then begin
    PeakL:=LevelL; VelL:=0; WaitCountL:=0;
  end;

  Inc(WaitCountR);
  if WaitCountR>WAIT then begin
    VelR:=VelR+ACCELERATION;
    PeakR:=PeakR-VelR;
  end;

  if Trunc(PeakR) <= LevelR then begin
    PeakR:=LevelR; VelR:=0; WaitCountR:=0;
  end;


  if PeakL>=RESOLUTION then
    PeakL:=RESOLUTION;

  if PeakR>=RESOLUTION then
    PeakR:=RESOLUTION;

  if Pause then
  begin
    CurrentL:=0;
    CurrentR:=0;
  end;

  // メインウィンドウの更新
  DrawMainWindow(True);

  
  // Normlization 音量表示
  Inc(NormCount);
  if NormCount>=10 then
  begin

    temp:=NormVolume;

    if Normalize then
    begin
      NormVolume:=m1snd_get_info_int(M1_IINF_NORMVOL, 0);

      if temp<>NormVolume then
      begin
        if (NormVolume > 0) then
          Form2.Label1.Caption:='Normalization Gain: '+InttoStr(NormVolume) +' %'
        else
          Form2.Label1.Caption:='Normalization Gain: --- %';
      end;

    end;
    NormCount:=0;
  end;

end;

//------------------------------------------------------------------------------
//  フェードアウト処理
//  CurrentTime: 現在時
//  EndTime: 曲長
//  FOLength: フェードアウト長
//
//                          |            | 1.5sec |
//                          |<---  FOLength   --->|                  CurrentTime
//     -------------------------------------------------------------->
//                                                |<- EndTime
//
procedure TForm1.SetFadeOut( CurrentTime: Integer; EndTime: Integer; FOLength: Integer);
var vol: integer;
begin

  // フェードアウト+3秒後は音量を戻す (これがないとバッファが再生される)
  if ( EndTime+3000 < CurrentTime ) then
  begin
    m1snd_setoption(M1_OPT_POSTVOLUME, 100);
    exit;
  end;

  // フェードアウト前
  if ( EndTime - FOLength > CurrentTime ) then
  begin
    // 再生が3秒以上
    if CurrentTime > 3000 then
      m1snd_setoption(M1_OPT_POSTVOLUME, 100);
    exit;
  end;

                                                     
  // 終わりの1.5秒以降は無音
  if ( EndTime - CurrentTime <= 1500 ) then
  begin
    m1snd_setoption(M1_OPT_POSTVOLUME, 0);
    exit;
  end;

  // Linear 100 to 0
  vol := (100 * (EndTime-CurrentTime-1500)) div (FOLength-1500);
  // Log10
  vol := 100 - Trunc(log10(10 - vol*9/100) * 100);

  m1snd_setoption(M1_OPT_POSTVOLUME, vol);

end;

//------------------------------------------------------------------------------
procedure TForm1.PresentMainWindow;
begin
  if PaintBox1.Canvas.TryLock then
  begin
    try
      PaintBox1.Canvas.Draw(0, 0, DisplayBuffer);
    finally
      PaintBox1.Canvas.Unlock;
    end;
  end;
end;
//------------------------------------------------------------------------------
//
procedure TForm1.DrawMainWindow(timer: Boolean);
var
  i         : Integer;
  x,y       : Integer;
  St        : WideString;
  GameDrawText, SongDrawText: WideString;
  GameDrawX, SongDrawX: Integer;
  digits    : Array [0..14] of Integer;
  digi_left : Integer;  // 桁の左位置 pixel
  digi      : Integer;  // 文字位置

  slBack, slAlpha, slDigits: PByteArray;

  R,G,B: Extended;
  DWidth: Integer; // 文字の横幅

  shift : Integer; // 文字位置ずらし

  function DisplayTextWidth(const Text: WideString;
    const Style: TFontStyles): Integer;
  begin
    if (PaintBox1.ClientWidth <= 0) or (PaintBox1.ClientHeight <= 0) then
    begin
      Result := 0;
      Exit;
    end;

    if (DisplayBuffer.Width <> PaintBox1.ClientWidth) or
       (DisplayBuffer.Height <> PaintBox1.ClientHeight) then
      DisplayBuffer.SetSize(PaintBox1.ClientWidth, PaintBox1.ClientHeight);

    DisplayBuffer.Canvas.Font.Name := 'Tahoma';
    DisplayBuffer.Canvas.Font.PixelsPerInch := CurrentPPI;
    DisplayBuffer.Canvas.Font.Size := 9;
    DisplayBuffer.Canvas.Font.Style := Style;

    Result := MulDiv(
      WideTextWidth(DisplayBuffer.Canvas.Handle, PWideChar(Text)),
      THEME_DESIGN_WIDTH, DisplayBuffer.Width);
  end;

  procedure ComposeScaledFrame;
  var
    wm, ws, wh, wf, wp: Integer;
    TextRect: TRect;

    function SX(Value: Integer): Integer;
    begin
      Result := MulDiv(Value, DisplayBuffer.Width, THEME_DESIGN_WIDTH);
    end;

    function SY(Value: Integer): Integer;
    begin
      Result := MulDiv(Value, DisplayBuffer.Height, THEME_DESIGN_HEIGHT);
    end;

  begin
    if (PaintBox1.ClientWidth <= 0) or (PaintBox1.ClientHeight <= 0) then
      Exit;

    ScaleImageBicubicGDIPlus(Buffer, DisplayBuffer,
      PaintBox1.ClientWidth, PaintBox1.ClientHeight);

    DisplayBuffer.Canvas.Brush.Style := bsClear;
    DisplayBuffer.Canvas.Font.Name := 'Tahoma';
    DisplayBuffer.Canvas.Font.PixelsPerInch := CurrentPPI;
    DisplayBuffer.Canvas.Font.Size := 9;

    DisplayBuffer.Canvas.Font.Style := [fsBold];
    DisplayBuffer.Canvas.Font.Color := clrGameDesc;
    TextRect := Rect(
      SX(RctGameDesc.Left), SY(RctGameDesc.Top + shift),
      SX(RctGameDesc.Right), SY(RctGameDesc.Bottom + shift));
    WideTextRect(DisplayBuffer.Canvas.Handle, TextRect,
      SX(RctGameDesc.Left + GameDrawX), SY(RctGameDesc.Top + shift),
      GameDrawText);

    DisplayBuffer.Canvas.Font.Style := [];
    DisplayBuffer.Canvas.Font.Color := clrSong;
    TextRect := Rect(
      SX(RctSongName.Left), SY(RctSongName.Top + shift),
      SX(RctSongName.Right), SY(RctSongName.Bottom + shift));
    WideTextRect(DisplayBuffer.Canvas.Handle, TextRect,
      SX(RctSongName.Left + SongDrawX), SY(RctSongName.Top + shift),
      SongDrawText);

    DisplayBuffer.Canvas.Font.Size := 8;
    DisplayBuffer.Canvas.Font.Style := [fsBold];
    DisplayBuffer.Canvas.Font.Color := clrInfoLabel;
    DisplayBuffer.Canvas.TextOut(SX(47), SY(89), 'Manufacturer:');
    DisplayBuffer.Canvas.TextOut(SX(47), SY(104), 'System:');
    DisplayBuffer.Canvas.TextOut(SX(47), SY(119), 'Hardware:');
    DisplayBuffer.Canvas.TextOut(SX(47), SY(134), 'File:');
    DisplayBuffer.Canvas.TextOut(SX(200), SY(134), 'Parent:');

    wm := DisplayBuffer.Canvas.TextWidth('Manufacturer:  ');
    ws := DisplayBuffer.Canvas.TextWidth('System:  ');
    wh := DisplayBuffer.Canvas.TextWidth('Hardware:  ');
    wf := DisplayBuffer.Canvas.TextWidth('File:  ');
    wp := DisplayBuffer.Canvas.TextWidth('Parent:  ');

    DisplayBuffer.Canvas.Font.Style := [];
    DisplayBuffer.Canvas.Font.Color := clrInfoDesc;
    TextRect := Rect(SX(47) + wm, SY(89),
      SX(47) + wm + SX(235), SY(200));
    Windows.DrawText(DisplayBuffer.Canvas.Handle, PChar(manu), -1, TextRect,
      DT_END_ELLIPSIS or DT_VCENTER);
    DisplayBuffer.Canvas.TextOut(SX(47) + ws, SY(104), system);
    DisplayBuffer.Canvas.TextOut(SX(47) + wh, SY(119), hard);
    DisplayBuffer.Canvas.TextOut(SX(47) + wf, SY(134), RomName);
    DisplayBuffer.Canvas.TextOut(SX(200) + wp, SY(134), parentname);
  end;
  
begin

  if Minimized then exit;

  if Buffer.Canvas.TryLock then
  begin

    try

      /// 背景
      Buffer.Canvas.CopyRect( Buffer.Canvas.ClipRect,
                              imgBack.Canvas,
                              Buffer.Canvas.ClipRect);
      //Buffer.Canvas.Font.Name   := Form1.Font.Name;
      Buffer.Canvas.Font.Size   := 9;
      

      /// ゲーム名
      Case DispLang of
        LANG_JP: Buffer.Canvas.Font.Name := 'Tahoma';
        LANG_EN: Buffer.Canvas.Font.Name := 'Tahoma';
      end;

      Case DispLang of
        LANG_JP: shift := 0;
        LANG_EN: shift := 0;
      else
        shift:=0;
      end;

      Buffer.Canvas.Font.Style  := [fsBold];
      Buffer.Canvas.Font.Color  := clrGameDesc;

      // ゲーム名スクロール
      if PreviousDesc <> desc then
      begin
        // ゲーム名変更時
        ScrollX2:=0;
        NameDrag:=False;    // ドラッグ無効
        DragX2:=0;          // ドラッグ位置0
        ScrollWaitCount2:=0;
        Scrolled2:=False;

        // テキストの幅
        SongTextWidth2 := DisplayTextWidth(desc, [fsBold]);
        ScrollTextWidth2 := SongTextWidth2 +
          DisplayTextWidth('   ***   ', [fsBold]);
      end;

      St:=desc;
      
      // テキストの幅が収まる場合
      if SongTextWidth2 < (RctGameDesc.Right - RctGameDesc.Left) then
      begin
        ScrollX2:=0;
        ScrollWaitCount2:=0;
        NameDrag:=False;
      end
      else
      // テキストの幅が収まらない場合
      begin


        // ドラッグ中の場合
        if NameDrag then
        begin
          St:=St+'   ***   '+St;
        end
        else
        
        // 一回だけスクロールの場合
        if (not Scrolled2) or Keep_Scrolling then
        begin

          // スクロール待ち中
          if ScrollWaitCount2 < SCROLL_WAIT2 then
          begin
            if timer then // タイマーからの更新のときだけ
              Inc(ScrollWaitCount2);
          end
          else
          // スクロール中
          begin
            if timer then // タイマーからの更新のときだけ
              ScrollX2:= ScrollX2 - DescScrollSpeed;

            St:=St+'   ***   '+St;

            if ScrollX2 + ScrollTextWidth2 <=0 then
            begin
              ScrollX2:=0;
              ScrollWaitCount2:=0;
              Scrolled2:=True; // 一回スクロール完了
            end;
          end;
          
        end;
      end;

      // ドラッグ位置
      x:= Round(ScrollX2) + DragX2;
      if ScrollTextWidth2<>0 then
        x:= x mod ScrollTextWidth2;
      
      if x>0 then    // 右方向にドラッグした場合
        x:= x-ScrollTextWidth2;
        
      GameDrawText := St;
      GameDrawX := x;



      /// 曲名スクロール
      //  曲名変更のチェック
      Buffer.Canvas.Font.Color :=clrSong;
      Buffer.Canvas.Font.Style := [];

      // 曲名が変わったら
      if PreviousSongName <> SongName then
      begin

        ScrollX:=0;         // スクロール位置初期化
        SongDrag:=False;    // ドラッグ無効
        DragX1:=0;          // ドラッグ位置0
        ScrollWaitCount:=0;
        Scrolled:=False;

        // テキストの幅
        SongTextWidth := DisplayTextWidth(SongName, []);
        ScrollTextWidth := SongTextWidth +
          DisplayTextWidth('   ***   ', []);

      end;

      St:=SongName;
      
      // テキストの幅が収まる場合
      if SongTextWidth < (RctSongName.Right - RctSongName.Left) then
      begin
        ScrollX:=0;
        ScrollWaitCount:=0;
        SongDrag:=False;
      end
      else
      // テキストの幅が収まらない場合
      begin

        // ドラッグ中の場合
        if SongDrag then
        begin
          St:=St+'   ***   '+St;
        end
        else

        // 一回だけスクロールの場合
        if (not Scrolled) or Keep_Scrolling then
        begin

          // スクロール待ち中
          if ScrollWaitCount < SCROLL_WAIT then
          begin
            if timer then // タイマーからの更新のときだけ
              Inc(ScrollWaitCount);
          end
          else
          // スクロール中
          begin
            if timer then // タイマーからの更新のときだけ
              ScrollX:=ScrollX - SongScrollSpeed;
            St:=St+'   ***   '+St;

            if ScrollX + ScrollTextWidth <=0 then
            begin
              ScrollX:=0;
              ScrollWaitCount:=0;
              Scrolled:=True; // 一回スクロール完了
            end;
          end;
        end;
      end;

      // ドラッグ位置
      x:= Round(ScrollX) + DragX1;
      if ScrollTextWidth<>0 then
        x:= x mod ScrollTextWidth;
      
      if x>0 then    // 右方向にドラッグした場合
        x:= x-ScrollTextWidth;

      SongDrawText := St;
      SongDrawX := x;


      /// 曲番号と時間表示
      // デフォルト表示
      digits[0]:=DIGI_BAR;
      digits[1]:=DIGI_BAR;
      digits[2]:=DIGI_BAR;
      digi:=3;

      if Hexadecimal then
      begin
        digits[3]:=DIGI_BAR;
        digi:=4;
      end;

      // 曲番号部分
      if CurrentSongNo<>-1 then
      begin

        if Hexadecimal then
        begin
          digits[0]:=0;
          digits[1]:=16;
          digi:=2;
          st:=Format('%.2x',[CurrentSongNo])
        end
        else
        begin
          digi:=0;
          st:=Format('%.3d',[CurrentSongNo]);
        end;

        for i:=0 to Length(St)-1 do
          digits[i+digi]:=StrtoInt('$'+copy(St,i+1,1));

        Inc(digi,Length(St));

      end;

      digits[digi]:=Indicator;
      Inc(digi);

      // タイム部分
      if PauseCount < PAUSE_ON_FREQ then
      begin
        digits[digi]:=StrtoInt(Copy(stmm,1,1)); Inc(digi);
        digits[digi]:=StrtoInt(Copy(stmm,2,1)); Inc(digi);
        digits[digi]:=DIGI_COLON; Inc(digi);
        digits[digi]:=StrtoInt(Copy(stss,1,1)); Inc(digi);
        digits[digi]:=StrtoInt(Copy(stss,2,1));
      end
      else
      begin
        digits[digi]:=DIGI_SPC;   Inc(digi);
        digits[digi]:=DIGI_SPC;   Inc(digi);
        digits[digi]:=DIGI_COLON; Inc(digi);
        digits[digi]:=DIGI_SPC;   Inc(digi);
        digits[digi]:=DIGI_SPC;
      end;

      digi_left:=0;

      for i:=0 to digi do
      begin

        if digits[i]<>DIGI_COLON then  // 普通の文字の幅
        begin
          DWidth:=DIGIT_WIDTH;
        end                            // コロンの幅
        else
        begin
          DWidth:=COLON_WIDTH;
        end;

        // アルファブレンディングの場合
        if AlphaBitmap.HandleAllocated then
        begin

          for y:=0 to 21 do
          begin
            slBack  :=Buffer.ScanLine[8+y];
            slAlpha :=AlphaBitmap.ScanLine[y];
            slDigits:=ImgDigits.ScanLine[y];

            for x:=0 to DWidth-1 do
            begin
              // 強度取得
              B:= slAlpha[(digits[i] * DIGIT_WIDTH + x) * 3    ] / 255;
              G:= slAlpha[(digits[i] * DIGIT_WIDTH + x) * 3 + 1] / 255;
              R:= slAlpha[(digits[i] * DIGIT_WIDTH + x) * 3 + 2] / 255;

              // アルファブレンディング
              slBack[(48+digi_left+x)*3  ]:=Trunc((1.0-B) * slBack[(48+digi_left+x)*3  ]+
                                                       B  * slDigits[(digits[i] * DIGIT_WIDTH + x) * 3    ]);
              slBack[(48+digi_left+x)*3+1]:=Trunc((1.0-G) * slBack[(48+digi_left+x)*3+1]+
                                                       G  * slDigits[(digits[i] * DIGIT_WIDTH + x) * 3 + 1]);
              slBack[(48+digi_left+x)*3+2]:=Trunc((1.0-R) * slBack[(48+digi_left+x)*3+2]+
                                                       R  * slDigits[(digits[i] * DIGIT_WIDTH + x) * 3 + 2]);
            end;
          end;
        end
        // 普通の描画の場合
        else
        begin
          Buffer.Canvas.CopyRect(Rect(48+digi_left,8,48+digi_left+DWidth,8+22),
                                 imgDigits.Canvas,
                                 Rect(digits[i] * DIGIT_WIDTH, 0, digits[i] * DIGIT_WIDTH+DWidth, 22));
        end;

        Inc(digi_left, DWidth);
      end;

      /// レベルメーター
      Buffer.Canvas.CopyRect(Rect( 8, 7, 18, 7+145),imgLevel.Canvas,Rect( 0, 0, 10, 145));
      Buffer.Canvas.CopyRect(Rect(20, 7, 30, 7+145),imgLevel.Canvas,Rect(30, 0, 40, 145));

      Buffer.Canvas.CopyRect(Rect( 8, 7+145-3*LevelL, 18, 7+145),
                             imgLevel.Canvas,
                             Rect(10,   145-3*LevelL, 20,   145));

      Buffer.Canvas.CopyRect(Rect(20, 7+145-3*LevelR, 30, 7+145),
                             imgLevel.Canvas,
                             Rect(40,   145-3*LevelR, 50,   145));

      // ピーク表示
      if display_peaks then
      begin

        if PeakL >= 1 then
          Buffer.Canvas.CopyRect(Rect( 8, 152-3*Trunc(PeakL), 18, 152-3*Trunc(PeakL)+3),
                                 imgLevel.Canvas,
                                 Rect(20, 145-3*Trunc(PeakL), 30, 145-3*Trunc(PeakL)+3));

        if PeakR >= 1 then
          Buffer.Canvas.CopyRect(Rect(20, 152-3*Trunc(PeakR), 30, 152-3*Trunc(PeakR)+3),
                                 imgLevel.Canvas,
                                 Rect(50, 145-3*Trunc(PeakR), 60, 145-3*Trunc(PeakR)+3));

      end;

      // モード表示
      if Normalize then
        Buffer.Canvas.CopyRect(RctNorm,imgIcons.Canvas,Rect(0,0,22,28))
      else
        Buffer.Canvas.CopyRect(RctNorm,imgIcons.Canvas,Rect(22,0,44,28));

      if ListMode then
        Buffer.Canvas.CopyRect(RctList,imgIcons.Canvas,Rect(44,0,66,28))
      else
        Buffer.Canvas.CopyRect(RctList,imgIcons.Canvas,Rect(66,0,88,28));

      if AutoMoveOn then
        Buffer.Canvas.CopyRect(RctNext,imgIcons.Canvas,Rect(88,0,110,28))
      else
        Buffer.Canvas.CopyRect(RctNext,imgIcons.Canvas,Rect(110,0,132,28));


      ComposeScaledFrame;

      PreviousDesc:=desc;
      PreviousSongName:=SongName;

      PresentMainWindow;

    finally
      Buffer.Canvas.Unlock;
    end;
    
  end;


end;

// -----------------------------------------------------------------------------
// メインウィンドウ上のクリック処理
//
procedure TForm1.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin

  X := MulDiv(X, THEME_DESIGN_WIDTH, PaintBox1.ClientWidth);
  Y := MulDiv(Y, THEME_DESIGN_HEIGHT, PaintBox1.ClientHeight);

  // 曲名ドラッグ中
  if SongDrag then
  begin
    DragX1:=X-DragStart1;
    DrawMainWindow(false);
    exit;
  end
  else
  // ゲーム名ドラッグ中
  if NameDrag then
  begin
    DragX2:=X-DragStart2;
    DrawMainWindow(false);
    exit;
  end;
  
  // Normalizeアイコン上
  if PtinRect(RctNorm,Point(X,Y)) then
  begin
    PaintBox1.Cursor:=crHandPoint;
    PaintBox1.Hint:='Click to toggle output normalization';
    PaintBox1.ShowHint:=True;
  end
  else
  // Listアイコン上
  if PtinRect(RctList,Point(X,Y)) then
  begin
    if ListLoaded then // プレイリスト読み込み時のみ
    begin
      PaintBox1.Cursor:=crHandPoint;
      PaintBox1.Hint:='Click to toggle List Mode';
      PaintBox1.ShowHint:=True;
    end;
  end
  else
  // Automoveアイコン上
  if PtinRect(RctNext,Point(X,Y)) then
  begin
    PaintBox1.Cursor:=crHandPoint;
    PaintBox1.Hint:='Click to toggle Auto Moving';
    PaintBox1.ShowHint:=True;
  end
  else
  // 曲番号上
  if PtinRect(RctSong,Point(X,Y)) then
  begin
    PaintBox1.Cursor:=crHandPoint;
  end
  else
  // レベルメータ上
  if PtinRect(RctLV,Point(X,Y)) then
  begin
    PaintBox1.Cursor:=crHandPoint;
  end
  else
  // 曲名上
  if ( PtinRect(RctSongName,Point(X,Y)) and
       ( SongTextWidth > (RctSongName.Right - RctSongName.Left)) ) then
  begin

    // 曲名幅が大きいときはアイコンを←→にする
    PaintBox1.Cursor:=crsizewe;

  end
  else
  // ゲーム名上
  if ( PtinRect(RctGameDesc,Point(X,Y)) and
       ( SongTextWidth2 > (RctGameDesc.Right - RctGameDesc.Left)) ) then
  begin

    PaintBox1.Cursor:=crsizewe;

  end
  else
  begin
    PaintBox1.Cursor:=crDefault;
    PaintBox1.Hint:='';
    PaintBox1.ShowHint:=False;
  end;

end;

procedure TForm1.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  X := MulDiv(X, THEME_DESIGN_WIDTH, PaintBox1.ClientWidth);
  Y := MulDiv(Y, THEME_DESIGN_HEIGHT, PaintBox1.ClientHeight);

  if Button<>mbLeft then exit;

  // 曲名ドラッグ終了
  if SongDrag then
  begin
    SongDrag:=False;

    // ドラッグ位置反映
    DragX1:= Round(ScrollX) + DragX1;
    if ScrollTextWidth<>0 then
      DragX1:= DragX1 mod ScrollTextWidth;
    if DragX1>0 then    // 右方向にドラッグした場合
      DragX1:= DragX1-ScrollTextWidth;

    ScrollX:= DragX1;


    DragX1:=0;
    ScrollWaitCount:=SCROLL_WAIT; // すぐスクロールを始める
    Scrolled:=False;              // 一回スクロールも戻す
    PaintBox1.Cursor:=crDefault;
    exit;
  end
  else
  // ゲーム名ドラッグ終了
  if NameDrag then
  begin
    NameDrag:=False;

    // ドラッグ位置反映
    DragX2:= Round(ScrollX2) + DragX2;
    if ScrollTextWidth2<>0 then
      DragX2:= DragX2 mod ScrollTextWidth2;
    if DragX2>0 then    // 右方向にドラッグした場合
      DragX2:= DragX2-ScrollTextWidth2;

    ScrollX2:= DragX2;

    DragX2:=0;
    ScrollWaitCount2:=SCROLL_WAIT2; // すぐスクロールを始める
    Scrolled2:=False;               // 一回スクロールも戻す
    PaintBox1.Cursor:=crDefault;
    exit;
  end;

  // Normalizeアイコン上
  if PtinRect(RctNorm,Point(X,Y)) then
  begin

    Set_Normalize(not Normalize);
    UseNormalize:=Normalize;

  end
  else
  // Listアイコン上
  if PtinRect(RctList,Point(X,Y)) then
  begin

    if ListLoaded=False then
      exit;

    Set_ListMode(not ListMode);
    ShowSongName(CurrentSongNo); // 曲時間の表示切り替え
    
  end
  else
  // Automoveアイコン上
  if PtinRect(RctNext,Point(X,Y)) then
  begin
    AutoMoveOn:= not AutoMoveOn;
  end
  else
  // 曲番号の上 Hex
  if PtinRect(RctSong,Point(X,Y)) then
  begin
    actHexNumberExecute(nil)
  end
  else
  // レベルメーターの上
  if PtinRect(RctLV,Point(X,Y)) then
  begin
    display_peaks := not display_peaks;
  end;
  
end;

procedure TForm1.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  PhysicalX, PhysicalY: Integer;
begin

  PhysicalX := X;
  PhysicalY := Y;
  X := MulDiv(X, THEME_DESIGN_WIDTH, PaintBox1.ClientWidth);
  Y := MulDiv(Y, THEME_DESIGN_HEIGHT, PaintBox1.ClientHeight);

  if Button<>mbLeft then exit;

  // 曲名ドラッグ開始
  if PtinRect(RctSongName,Point(X,Y)) then
  begin
    if SongTextWidth > (RctSongName.Right - RctSongName.Left) then
    begin
      SongDrag:=True;
      DragStart1:=X;
    end;
    exit;
  end
  else
  // ゲーム名ドラッグ開始
  if PtinRect(RctGameDesc,Point(X,Y)) then
  begin
    if SongTextWidth2 > (RctGameDesc.Right - RctGameDesc.Left) then
    begin
      NameDrag:=True;
      DragStart2:=X;
    end;
    exit;
  end;

  // クリック可能項目以外の場所ならフォームドラッグ開始
  if (not PtinRect(RctNorm,Point(X,Y))) and
     (not PtinRect(RctList,Point(X,Y))) and
     (not PtinRect(RctNext,Point(X,Y))) and
     (not PtinRect(RctSong,Point(X,Y))) and
     (not PtinRect(RctLV,Point(X,Y))) then
  begin

    ReleaseCapture;
    SendMessage(Handle, WM_SYSCOMMAND, SC_MOVE or 2,
      MakeLong(PhysicalX, PhysicalY));
  end;
  
end;



procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  if Buffer.Canvas.TryLock then
  begin
    try
      PresentMainWindow;
    finally
      Buffer.Canvas.Unlock;
    end;
  end;
end;

procedure TForm1.popAutoMoveClick(Sender: TObject);
begin

  AutoMoveOn:= not AutoMoveOn;

end;

procedure TForm1.btnMixerClick(Sender: TObject);
begin

  if Form6.Visible then
    Form6.Close
  else
    Form6.Show;

end;

procedure TForm1.rackListFont1Click(Sender: TObject);
begin

  FontDialog1.Font:=TLFont;

  if FontDialog1.Execute then
  begin
    TLFont.Name:=FontDialog1.Font.Name;
    TLFont.Size:=FontDialog1.Font.Size;
    TLFont.Style:=FontDialog1.Font.Style;
    Form2.ListBox1.Font.Name:=TLFont.Name;
    Form2.ListBox1.Font.Size:=TLFont.Size;
    Form2.ListBox1.Font.Style:=TLFont.Style;
    Form2.ListBox1.ItemHeight:=(Abs(Form2.ListBox1.Font.Height)) + 3;
    Form2.ListBox1.Invalidate;
  end;

end;

procedure TForm1.ApplicationEvents1Minimize(Sender: TObject);
begin

  Minimized := True;

  if SystemTray then
  begin
    ShowWindow(Application.Handle, SW_HIDE);
    Form2.Hide; // 常に手前表示で追加
    Form6.Hide;
    MakeTrayIcon;
    Tray_Icon:= True;
  end
  else
  begin
    Form2.Hide;
    Form6.Hide;
  end;

end;

procedure TForm1.ApplicationEvents1Restore(Sender: TObject);
begin

  Minimized := False;

  if Tray_Icon then
  begin
    DeleteTrayIcon;
  end;

  if MixerWindow then
    Form6.Show;

  if PlayList then
    Form2.Show;

  Form1.SetFocus;

end;

procedure TForm1.popNormalizeClick(Sender: TObject);
begin
  Set_Normalize(not Normalize);
  UseNormalize:=Normalize;
end;


procedure TForm1.popListModeClick(Sender: TObject);
begin

  if ListLoaded=False then
    exit;

  Set_ListMode(not ListMode);
  ShowSongName(CurrentSongNo); // 曲時間の表示切り替え

end;

procedure TForm1.actAlwaysTopExecute(Sender: TObject);
begin
  AlwaysOnTop:=not AlwaysOnTop;
  ResetFormOrder(AlwaysOnTop);
end;

procedure TForm1.actAlwaysTopUpdate(Sender: TObject);
begin

  actAlwaysTop.Checked:=AlwaysOnTop;

end;

procedure TForm1.actHexNumberExecute(Sender: TObject);
begin
  Set_Hexadecimal(not Hexadecimal);
end;

procedure TForm1.actHexNumberUpdate(Sender: TObject);
begin
  actHexNumber.Checked:=Hexadecimal;
end;


procedure TForm1.ApplicationEvents1Activate(Sender: TObject);
begin

  if (not Form4.Visible) and (not Form3.Visible) then
  begin
    ResetFormOrder(AlwaysOnTop);
  end;


end;

procedure TForm1.FormActivate(Sender: TObject);
begin

  ResetFormOrder(AlwaysOnTop);

end;

end.
