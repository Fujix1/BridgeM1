unit Common;

interface

uses CommCtrl, SysUtils, Graphics, Classes, StrUtils, WSDLIntf, WideStrings,
     Windows, M1;
const

  APPNAME  = 'Bridge v0.70';
  DWMWA_EXTENDED_FRAME_BOUNDS = 9;

  CFGDIR   = 'm1cfg';
  THEMEDIR = 'themes';

  ciFittingThreshold  =  9; // ウィンドウスナップのマージン
  //DIGIT_W      =  16; //  デジタル一桁の幅
  DIGIT_H        =  22; //              高さ
  //COLON_W      =   8; //  コロンの幅

  // デジタル表示用マークの番号
  DIGI_BLANK     =  16;
  DIGI_PLAY      =  17;
  DIGI_STOP      =  18;
  DIGI_PAUSE     =  19;
  DIGI_SPC       =  21;
  DIGI_COLON     =  22;
  DIGI_BAR       =  20;

  LEFT_MARGIN    =   4; // リスト左側のマージン

  PAUSE_ON_FREQ  =  62; // ポーズ点滅間隔 (表示) x 16ms
  PAUSE_OFF_FREQ =  46; // ポーズ点滅間隔 (消す) x 16ms

  IDLE_FREQ      =  25;
  KEY_REPEAT     = 130; // キー入力のリピート間隔

  // 曲名スクロールの間隔 x 16ms
  SCROLL_FREQ    =   1;
  SCROLL_WAIT    =  80; // スクロール開始までの待ち

  // ゲーム名のスクロール間隔
  SCROLL_WAIT2   =  100; // スクロール開始までの待ち

  // 描画インターバル
  TIMER_20FPS    =  40; //ms
  TIMER_30FPS    =  30; //ms
  TIMER_60FPS    =  16; //ms

  // テキストスクロール速度
  SCROLL_SPEED0  =  0.6;
  SCROLL_SPEED1  =  0.8;
  SCROLL_SPEED2  =  1.0;
  SCROLL_SPEED3  =  1.2;
  SCROLL_SPEED4  =  1.4;


  // 言語設定
  LANG_EN = 0;  // English
  LANG_JP = 1;  // Japaneses
  LANG_NONE = -1;

  // ROM表示設定
  ALL_SETS       = 0; // 全部
  AVAILABLE_SETS = 1; // 使用可
  BAD_SETS       = 2; // 不可
  MEGADRIVE_ONLY = 3; // メガドライブのみ

  ROM_STATUS_OK       = 1; // ROM問題なし
  ROM_STATUS_ERROR    = 2; // 問題あり
  ROM_STATUS_MISSING  = 0; // ROMなし


  // VUメータ用
  METER_W       =   10;  // メーターの幅
  METER_H       =  146;  // メーターの高さ
  RESOLUTION    =   48;  // 段階数
  DECAY         =    2;  // 減衰量
  ACCELERATION  = 0.13;  // 落下加速度
  WAIT          =   25;  // 落下開始まで


type // ROMリスト用
  PROMList = ^TROMList;
  TROMList = record

    RomName     : string;     // ROM名
    Master      : string;     // マスタ名
    Year        : string;     // 年度
    Title       : WideString; // 名称
    Maker       : string;     // 製造元
    System      : string;     // システム
    Hard        : string;     // ハード
    List        : string;     // リスト
    Rom_State   : integer;    // 0:なし 1:あり 2:不良
    Kana        : WideString; // 読み仮名
    Idx         : integer;    // インデックス
    NumPlay     : integer;    // プレイ回数

  end;

  // Fade out mode
  type TFadeOut = (foYes, foNo, foNoCare);

  // Track List
  PTrackList= ^TTrackList;
  TTrackList= record

    Song_No : integer;    // 曲番号
    Song_St : String;     // 曲番号の10進数テキスト（リスト表記のまま）
    Text    : WideString; // 曲名
    PlayTime: integer;    // プレイ時間 (ms) (0:default)
    FadeOut : TFadeOut;   // フェードアウト
    FOLength: integer;    // フェイドアウト長 (0:default, ms)
  end;

  //              | フェードON    | フェードOFF   | 設定なし
  //---------------------------------------------------------------
  // 時間設定あり | フェード      | フェード無し  | フェード無し
  // 時間設定なし | デフォルト    | フェード無し  | デフォルト


  // Streams and Channels
  TMixer = record
    Stream : integer;   // ストリーム番号
    Channel: integer;   // チャンネル番号
    Name   : String;    // チャンネル名
    DefLev : integer;   // デフォルトレベル
    Level  : integer;   // 今のレベル
    Enabled: boolean;   //
  end;

  // Default Stream and Channels
  TDefMixer = record
    System  : string;    // システム名
    ROM     : string;    // ROM名
    Stream  : integer;   // ストリーム番号
    Channel : integer;   // チャンネル番号
    DefLev  : integer;   // デフォルトレベル
  end;

var

  RL : TList;   // ROM List用TList変数
  RLSub: TList; // ROM List用TList変数

  TL : TList;   // TrackList用TList変数

  //Saved8087CW: word;

  exe_path : string;          // Exe Path
  rom_path : array of string; // ROM Paths
  wav_path : string;          // WAV Path

  // 設定
  Normalize       : Boolean;  // Current Normalization setting
  Reset_Normalize : Boolean;  // Reset Normalize

  UseFixedVolume  : Boolean;  // Use fixed volume than normalization
  UseNormalize    : Boolean;  // Use Normalization

  ListMode        : Boolean;  // List_Mode
  AutoMoveOn      : Boolean;  // Auto Move on
  Repeat_One      : Boolean;  // リピート

  CurrentTheme    : String;   // 現在のテーマファイル（''でデフォルト）
  Hexadecimal     : Boolean;  // 16進数での曲表示
  Display_Peaks   : Boolean;  // LVメータのピーク表示有無
  Keep_Scrolling  : Boolean;  // スクロール継続
  Rom_Condition   : Integer;  // ROMリスト表示条件
  SystemTray      : Boolean;  // 最小化時System Trayにアイコン表示

  UserWavFileName : Boolean;  // ユーザ設定のWavファイル名
  Wav_Format      : String;   // ユーザ設定のWavファイル名フォーマット
  Sample_Rate     : Integer;  // サンプルレート
  Stereo_Mix      : Integer;  // ステレオ混合率
  MasterVolume    : Integer;  // 音量
  Muted           : Boolean;  // ミュート
  Attachable      : Boolean;  // アタッチ可能か
  AlwaysOnTop     : Boolean;  // 常に上
  TLFont          : TFont;    // トラックリストのフォント
  RefreshRate     : Integer;  // 0=20fps(40ms), 1=30fps(30ms), 2=60fps(15ms), 3:=60+fps(10ms)
  SongScrollSpeed : Double;   // 曲名スクロール速度
  DescScrollSpeed : Double;   // ゲーム名スクロール速度
  ScrollSpeed     : Integer;  // 全般のスクロール速度

  //AddJPDesc       : Boolean;  // テスト用

  // 状態保持
  DispLang        : Integer;  // 表示設定の言語
  NewLang         : Integer;  // 変更された言語設定
  MultiInstance   : Boolean;  // 二重起動可能か

  Tray_Icon       : Boolean;  // トレイアイコン表示中
  Minimized       : Boolean;  // 最小化中

  max_games       : Integer;  // サポート数
  ava_games       : Integer;  // Available数
  fm1             : TPoint;   // メインウィンドウの表示位置（ATI対策）
  fm2_w,fm2_h     : Integer;  // プレイリストの表示情報
  fm3             : TPoint;
  fm3_w,fm3_h     : Integer;  // Form3の位置とサイズ
  fm3_colwidths   : String;   // Form3.ListView1のコラム幅
  fm3_colorder    : String;   // Form3.ListView1のコラム順
  PlayList        : Boolean;  // プレイリストが表示中かどうか
  MixerWindow     : Boolean;  // ミキサー表示中か
  Recording       : Boolean;  // WAV保存中か
  fm6             : TPoint;   // Form6の位置
  fm2             : TPoint;

  CurrentGameID   : integer;  // ロードされたゲーム番号
  max_song_num    : integer;  // 曲番号上限
  max_song_num_core:integer;  // コアの曲番号上限

  FixedVolume     : integer;  // 固定音量

  QueryMaker, QuerySystem, QueryChip
                  : String;   // ROMリスト表示条件
  QueryWord       : String;

  Selecting       : String;   // 選択中項目
  Selecting2      : String;   // 選択中項目

  playing         : boolean;  // プレイ中
  pause           : boolean;  // ポーズ中
  CurrentSongNo   : Integer;  // プレイ中の曲番号
  CurrentSongName : WideString;   // プレイ中の曲名
  DefaultSongNo   : Integer;  // リストで指定されたデフォルト曲番号 (-1は無効)
  ListLoaded      : boolean;  // リストが読み込まれたか
  rom_loaded      : boolean;  // ROMが読み込まれたか

  CurrentPlayTime : Integer;  // 今プレイ中の曲の長さ
  CurrentIndex    : Integer;  // 今プレイ中の曲のリスト内でのIndex
  TimeCount       : Integer;  // 現在の演奏時間カウント (ms)
  NormVolume      : Integer;  // Normalization音量
  StartTick       : Integer;  // 曲開始時のTickCount
  PauseTick       : Integer;  // Pause開始時のTickCount

  IdleOn          : Boolean;  // Idle送信可能か

  List_Path       : String;   // 言語に応じてリストのパス変更

  DefaultPlayTime : Integer;  // デフォルトの曲時間
  UseDefaultTime  : Boolean;  // デフォルトの曲時間を使うか

  OptionTabIndex  : Integer;  // 表示中オプションページ


  ScrollX         : Double;   // 曲名スクロールの位置
  ScrollWaitCount : Integer;  // 曲名スクロール待ちカウント
  Scrolled        : boolean;  // 一回だけスクロール時のフラグ
  SongDrag        : boolean;  // 曲名ドラッグ中
  DragStart1      : Integer;  // 曲名ドラッグの初期位置
  DragX1          : Integer;  // 今のドラッグ相対位置

  ScrollX2        : Double;   // ゲーム名スクロールの位置
  ScrollWaitCount2: Integer;  // ゲーム名スクロール待ちカウント
  Scrolled2       : boolean;  // 一回だけスクロール時のフラグ
  NameDrag        : boolean;  // ゲーム名ドラッグ中
  DragStart2      : Integer;  // ゲーム名ドラッグの初期位置
  DragX2          : Integer;  // 今のドラッグ相対位置

  SongTextWidth   : Integer;  // テキストの幅
  ScrollTextWidth : Integer;  // スクロールさせるテキストの幅
  SongTextWidth2  : Integer;  // テキストの幅
  ScrollTextWidth2: Integer;  // スクロールさせるテキストの幅


  PauseCount      : Integer;  // Pauseのカウント (-1の時はカウントしない）
  Loading         : Boolean;  // コアがROMロード中

  Wave_Device_ID  : Integer;  // WaveデバイスのID

  KeyTickCount    : Integer;  // キー入力時のTickCount

  DefaultFOLength : Integer;  // Default Fadeout length (msec)
  DefaultFadeout  : Boolean;  // Default Fadeout

  CurrentFadeout  : TFadeOut; // 今の曲のフェードアウト指定
  CurrentFOLength : Integer;  // 今の曲のフェードアウト長

  SortHistory     : array [0..6] of Shortint; // ソートのヒストリー

  Mixer           : array of TMixer; // ミキサー設定
  CfgMixer        : array of TMixer; // cfgから読み込んだミキサー設定
  DefMixers       : array of TDefMixer; // デフォルトのミキサー設定

  ErrorMsg        : String;   // コアからのエラーメッセージ
  
  // Theme用共有
  clrLWPlaying    : TColor;   // プレイ中の表示色
  clrLWSelected   : TColor;   // 選択中の表示色
  DIGIT_WIDTH     : integer;  // デジタル横幅
  COLON_WIDTH     : integer;  // コロン横幅

  //
  Attached        : Boolean;  // アタッチの判断
  Attached2       : Boolean;  // Form1とForm6のアタッチ
  Attached3       : Boolean;  // Form2とForm6のアタッチ

  //
  Booting         : Boolean;  // 起動中

  //
  TrayIconTip: String;

  LevelL,  LevelR   : Integer; // 現在のレベル 0～25
  CurrentL,CurrentR : Integer; // 入力レベルの変換値

  PeakL, PeakR      : Double ; // ピーク位置
  VelL,  VelR       : Double ; // 落下速度
  WaitCountL,
  WaitCountR        : Integer; // 落下開始までのカウント

  DecayCount        : Integer;
  MeterCount        : Integer;

  VU_Latency        : Integer;  // VUメータのレイテンシ


  debugTime         : Integer;  // デバッグ用
  frames            : Integer;
  

function FormatPlayTime(ms:integer): String;
function StrtoPlayTime(St: String): integer;
function ParseMetaTag(St: String; trklist:PTrackList): string;
function CsvSeparate(const Str: string; StrList: TStrings): integer;
function TSVSeparate(const Str: string; StrList: TStrings): integer;
function WideTsvSeparate(Const Str: WideString; StrList: TWideStrings): Integer;
function WideTextWidth(hDC: HDC; Text: LPWSTR): Integer;
procedure WideTextRect(hDC: HDC; Rect: TRect; X, Y: Integer; Text: WideString);
function ExtractXML(const element: string; const xml:string): string;
function get_game_no(setname: String): integer;
function htmlspecialchar(str: string): string;
function htmlspecialchars_decode(str: string): string;
function booltoyesno(bool: boolean): string;
function yesnotobool(str: string): boolean;
function GetRealWindowRect(hWnd: HWND): TRect;
function JoinPath(const BasePath, ChildPath: string): string;


function SaveIni: integer;
function LoadIni: integer;
function LoadList(Name: String): Boolean;
procedure SaveGameCFG(GameID: Integer);
procedure LoadGameCFG(GameID: Integer);
procedure LoadDefaultCFG;

implementation

uses Unit1, Unit2, Unit3, Unit6;

type
  TDwmGetWindowAttribute = function(hWnd: HWND; dwAttribute: DWORD; pvAttribute: Pointer; cbAttribute: DWORD): HRESULT; stdcall;

function JoinPath(const BasePath, ChildPath: string): string;
begin
  Result := IncludeTrailingPathDelimiter(BasePath) + ChildPath;
end;

function GetRealWindowRect(hWnd: HWND): TRect;
var
  hDwmApi: THandle;
  DwmGetWindowAttribute: TDwmGetWindowAttribute;
begin
  Result := Rect(0, 0, 0, 0);
  hDwmApi := LoadLibrary('dwmapi.dll');
  if hDwmApi <> 0 then
  try
    @DwmGetWindowAttribute := GetProcAddress(hDwmApi, 'DwmGetWindowAttribute');
    if Assigned(DwmGetWindowAttribute) and
       Succeeded(DwmGetWindowAttribute(hWnd, DWMWA_EXTENDED_FRAME_BOUNDS, @Result, SizeOf(Result))) then
      Exit;
  finally
    FreeLibrary(hDwmApi);
  end;
  GetWindowRect(hWnd, Result);
end;


// ------------------------------------------
// Find a No. of the game
//
// [Arg] String game zip name
// [Ret] Integer N: (-1:notfound)
// ------------------------------------------

function get_game_no(setname: String): integer;
var
  i:integer;
  st: string;
begin
  for i:=0 to max_games-1 do
  begin
    st:=M1String(m1snd_get_info_str(M1_SINF_ROMNAME, i));
    if setname=st then
    begin
      get_game_no:=i;
      exit;
    end;
  end;
  get_game_no:=-1;
end;


// ---------------------------------------------------------------------
// PlayTime: Milisecond to String [updated in 0.5.1]
Function FormatPlayTime(ms:integer): String;
var mm,ss : integer;
begin

  if ms<=0 then
  begin
    Result:='';
    exit;
  end;

  mm:=ms div 60000;
  ss:=(ms - mm * 60000) div 1000;
  ms:=(ms - mm * 60000 - ss * 1000) div 10;

  // 100分の1秒ありか
  if ms=0 then
    Result:=Format('%.1d:%.2d', [mm,ss])
  else
  if (ms mod 10) = 0 then
    Result:=Format('%.1d:%.2d.%1s',[mm,ss,Copy(IntToStr(ms),1,1)])
  else
    Result:=Format('%.1d:%.2d.%.2d',[mm,ss,ms]);

end;


//-----------------------------------------------------------------------
// PlayTIme: String to MiliSeconds [new in 0.5.1]

function StrtoPlayTime(St:String): integer;
var PT :integer;
// Returned Value
// -1: Convert Error
//  0: blank
begin

  St:=Trim(St);
  PT:=0;

  if St='' then
  begin
    result:=0;
    exit;
  end;

  try
    
    // 分がある場合 [minutes]
    if Pos(':',St)<>0 then
    begin
      PT:=StrtoInt(Copy(St,1,pos(':',St)-1)) * 60000;
      St:=Copy(St,pos(':',St)+1,Length(St));
    end;

    // 一秒未満がある場合 [0.1 Sec or 0.01 Sec]
    if Pos('.',St)<>0 then
    begin

      // 0を最後に追加
      if Length(Copy(St,pos('.',St)+1,2))=1 then
        St:=St+'0';

      PT:=PT + StrtoInt(Copy(St,pos('.',St)+1,2)) * 10;

      St:=Copy(St,1,pos('.',St)-1);
    end;

    // 秒 [Second]
    PT:=PT + StrtoInt(St)*1000;

    if PT >= 3600000 then
      PT:=3599000;

  except
  on EConvertError do
    PT:=-1;
  end;

  Result:=PT;
  
end;

// --------------------------------------------------------------------
// リストファイル読み込み
// utf-8対応

function LoadList( Name: String ) : Boolean;
var
  F1    : TextFile;
  FB    : File;
  b1,b2,b3: Byte;
  St,S  : String;
  i,line: Integer;
  hex   : boolean;
  tracklist : PTrackList;
  lst_version: Integer;

  utf8: boolean;
  bom: boolean;
  uSt: Utf8String;
  wSt: WideString;
  Raw: AnsiString;
  BomRemoved: boolean;
  Flag: boolean;

  function IsValidUtf8(const S: AnsiString): Boolean;
  var
    p: PAnsiChar;
    len,i: Integer;
    b: Byte;
  begin
    len := Length(S);
    if len = 0 then
    begin
      Result := True;
      Exit;
    end;

    p := PAnsiChar(S);
    i := 1;
    while i <= len do
    begin
      b := Byte(p[i]);
      if b < $80 then
        Inc(i)
      else if (b and $E0) = $C0 then
      begin
        if (i + 1 <= len) and ((Byte(p[i + 1]) and $C0) = $80) and (b > $C1) then
          Inc(i, 2)
        else
        begin
          Result := False;
          Exit;
        end;
      end
      else if (b and $F0) = $E0 then
      begin
        if (i + 2 <= len) and ((Byte(p[i + 1]) and $C0) = $80) and ((Byte(p[i + 2]) and $C0) = $80) then
          Inc(i, 3)
        else
        begin
          Result := False;
          Exit;
        end;
      end
      else if (b and $F8) = $F0 then
      begin
        if (i + 3 <= len) and ((Byte(p[i + 1]) and $C0) = $80) and ((Byte(p[i + 2]) and $C0) = $80) and ((Byte(p[i + 3]) and $C0) = $80) then
          Inc(i, 4)
        else
        begin
          Result := False;
          Exit;
        end;
      end
      else
      begin
        Result := False;
        Exit;
      end;
    end;

    Result := True;
  end;

  procedure FreePendingTrackList;
  begin
    if TrackList <> nil then
    begin
      Dispose(TrackList);
      TrackList := nil;
    end;
  end;
begin

  result:=False;
  Flag:=False;
  TrackList:=nil;

  // 初期化
  // TListの各項目のメモリ解放
  for i:= 0 to TL.count-1 do
    dispose(PTrackList(TL[i]));

  TL.Clear;

  max_song_num := -1;
  lst_version  :=  2;
  FixedVolume:=-1;

  Form2.ListBox1.Items.Clear;


  // ファイルがあるか？
  if not FileExists(Exe_Path+List_Path+Name+'.lst') then
  begin
    result:=False;
    exit;
  end;

  // 読み込み開始
  AssignFile(FB, Exe_Path+List_Path+Name+'.lst');
  Reset(FB, 1);
  utf8 := False;
  bom  := False;
  if FileSize(FB) >= 3 then
  begin
    BlockRead(FB, b1, 1);
    BlockRead(FB, b2, 1);
    BlockRead(FB, b3, 1);
    bom := (b1 = $EF) and (b2 = $BB) and (b3 = $BF);
  end;
  Seek(FB, 0);
  SetLength(Raw, FileSize(FB));
  if Length(Raw) > 0 then
    BlockRead(FB, Raw[1], Length(Raw));
  CloseFile(FB);

  if bom then
    utf8 := True
  else
    utf8 := IsValidUtf8(Raw);

  AssignFile(F1, Exe_Path+List_Path+Name+'.lst');
  if utf8 then
    SetTextCodePage(F1, CP_UTF8);
  Reset(F1);
  line:=1;

  try

  while not Eof(F1) do
  begin

    ReadLn(F1,wSt);
    if (utf8) and (BomRemoved=False) then
    begin
      if (Length(wSt)>0) and (wSt[1]=WideChar($FEFF)) then
        Delete(wSt,1,1);
      BomRemoved:=True;
    end;

    Inc(line);

    if (Pos(WideString('$default='), wSt)<>0) and (copy(wSt,1,2)<>'//') then
    begin
      DefaultSongNo:=StrtoInt(Copy(wSt,Pos(WideString('='), wSt)+1,Length(wSt)));
    end
    else
    if (Pos(WideString('$songmax='), wSt)<>0) and (copy(wSt,1,2)<>'//') then
    begin
      max_song_num:=StrtoInt(Copy(wSt,Pos(WideString('='), wSt)+1,Length(wSt)));

      // 9999999より大きい指定はエラー
      if max_song_num > 9999999 then
      begin
        s:='Error found in the list file.   '+
           #10#13#10#13+'The largest song number is 9999999. - Line: '+InttoStr(line-1) +'  ';
           Windows.MessageBox( Form1.Handle, PChar(S), 'BridgeM1 : Error', MB_OK or MB_ICONSTOP );
        CloseFile(F1);
        Exit;
      end;
      
    end
    else
    if (Pos(WideString('$fixed_volume='), wSt)<>0) and (copy(wSt,1,2)<>'//') then
    begin
      FixedVolume:=StrtoInt(Copy(wSt,Pos(WideString('='), wSt)+1,Length(wSt)));
    end
    else
    if (Pos(WideString('$version='), wSt)<>0) and (copy(wSt,1,2)<>'//') then
    begin
      lst_version:=StrtoInt(Copy(wSt,Pos(WideString('='), wSt)+1,Length(wSt)));
    end;
    
    if Pos(WideString('$main'), wSt)<>0 then
    begin

      ReadLn(F1,wSt);

      while ((Pos(WideString('$end'), wSt)=0) and (not Eof(F1))) do
      begin

        // コメント行チェック
        if (Copy(wSt,1,2)='//')  then
        begin


        end
        else
        begin
        
          // 初期化
          new(TrackList);
          TrackList.Song_No:=-1;
          TrackList.Text:='';
          TrackList.PlayTime:=0;
          TrackList.FadeOut:=foNoCare;
          TrackList.FOLength:=0;

          if (Copy(wSt,1,1)='#') or (Copy(wSt,1,1)='$') then // 曲番号
          begin

            Flag:=True;

            hex:=(Copy(wSt,1,1)='$'); // 16進数チェック

            // 曲番号読み込みと表示用10進数テキスト保存
            if hex then
            begin
              S:=Copy(wSt,1,Pos(WideString(' '), wSt)-1);

              // 9999999より大きい指定はエラー
              if StrtoInt(S) > 9999999 then
              begin
                s:='Error found in the list file.   '+
                    #10#13#10#13+'The largest song number is 9999999. - Line: '+InttoStr(line) +'  ';
                Windows.MessageBox( Form1.Handle, PChar(S), 'BridgeM1 : Error', MB_OK or MB_ICONSTOP );
                FreePendingTrackList;
                CloseFile(F1);
                Exit;
              end;
                  
              TrackList.Song_No:=StrtoInt(S);
              TrackList.Song_St:=Format('%.3d',[tracklist.Song_No]);
              wSt:=Copy(wSt,Pos(WideString(' '), wSt)+1,Length(wSt));
            end
            else
            begin
              S:=Copy(wSt,2,Pos(WideString(' '), wSt)-2);

              // 9999999より大きい指定はエラー
              if StrtoInt(S) > 9999999 then
              begin
                s:='Error found in the list file.   '+
                    #10#13#10#13+'The largest song number is 9999999. - Line: '+InttoStr(line) +'  ';
                Windows.MessageBox( Form1.Handle, PChar(S), 'BridgeM1 : Error', MB_OK or MB_ICONSTOP );
                FreePendingTrackList;
                CloseFile(F1);
                Exit;
              end;
              
              TrackList.Song_No:=StrtoInt(S);
              TrackList.Song_St:=Trim(S);
              wSt:=Copy(wSt,Pos(WideString(' '), wSt)+1,Length(wSt));
            end;

            // タグあり
            if (Pos(WideString('<'), wSt)<>0) and (Pos(WideString('>'), wSt)<>0) then
            begin

              case lst_version of
                1: // version 1
                begin
                  S:=Trim(Copy(wSt,Pos(WideString('<'), wSt)+1,Pos(WideString('>'), wSt)-Pos(WideString('<'), wSt)));
                  TrackList.PlayTime:=StrtoPlayTime(S);

                  // 再生時間指定時はフェード無し
                  TrackList.FadeOut:=foNo;

                  // コンバートエラー
                  if TrackList.PlayTime = -1 then
                  begin
                    s:='Error found in the list file.   '+
                        #10#13#10#13+'Play time is not valid - Line: '+InttoStr(line) +'  ';

                    Windows.MessageBox( Form1.Handle, PChar(S), 'BridgeM1 : Error', MB_OK or MB_ICONSTOP );
                    FreePendingTrackList;
                    CloseFile(F1);
                    Exit;
                  end;

                  // 0.30秒未満の指定はエラー
                  if TrackList.PlayTime < 300 then
                  begin
                    s:='Error found in the list file.   '+
                        #10#13#10#13+'Play time has to be longer than 0.3 second. - Line: '+InttoStr(line) +'  ';
                    Windows.MessageBox( Form1.Handle, PChar(S), 'BridgeM1 : Error', MB_OK or MB_ICONSTOP );
                    FreePendingTrackList;
                    CloseFile(F1);
                    Exit;
                  end;

                  wSt:=Trim(Copy(wSt,1,Pos(WideString('<'), wSt)-1));
                end;

                2: // version 2
                begin
                  S:= Trim(Copy(wSt,Pos(WideString('<'), wSt),Pos(WideString('>'), wSt)-Pos(WideString('<'), wSt)+1));
                  S:= ParseMetaTag(S, tracklist);
                  
                  if S<>'' then
                  begin
                    S:='Error found in the track list.   '+
                      #10#13#10#13+S+#10#13+'Line: '+InttoStr(line) +'  ';
                    Windows.MessageBox( Form1.Handle, PChar(S), 'BridgeM1 : Error', MB_OK or MB_ICONSTOP );
                    FreePendingTrackList;
                    CloseFile(F1);
                    Exit;
                  end;

                  wSt:=Trim(Copy(wSt,1,Pos(WideString('<'), wSt)-1));
                end;
                
                else // else
                begin
                  s:= 'Unknown list version.   '+
                    #10#13#10#13+'List format version: '+InttoStr(lst_version) +'    ';
                    Windows.MessageBox( Form1.Handle, PChar(S), 'BridgeM1 : Error', MB_OK or MB_ICONSTOP );
                  FreePendingTrackList;
                  CloseFile(F1);
                  Exit;
                end;

              end;
            end;
          end;
        
          wSt:=StringReplace(wSt,'&lt;','<',[rfReplaceAll, rfIgnoreCase]);
          wSt:=StringReplace(wSt,'&gt;','>',[rfReplaceAll, rfIgnoreCase]);
          tracklist.Text:=wSt;

          TL.Add(tracklist);
          TrackList:=nil;
          Form2.ListBox1.Items.Add('');

        end;
        
        // 一行読み込み
        ReadLn(F1,wSt);
          
        Inc(line);

        // $endのチェック
        if Eof(F1) and (Pos(WideString('$end'), wSt)=0) then
        begin
          S:='An error found in the list file.   '+
              #10#13#10#13+'"$end" is missing.   ';
          Windows.MessageBox(Form1.Handle, PChar(S), 'BridgeM1 : Error', MB_OK or MB_ICONSTOP);
        end;
        
      end;

    end;
  end;

  except
  on EConvertError do
    begin
      S:='Found an error in the list file.   '+
          #10#13+'Invalid Number - Line : '+InttoStr(line) +'  ';
      Windows.MessageBox(Form1.Handle, PChar(S), 'BridgeM1 : Error', MB_OK or MB_ICONSTOP);
      FreePendingTrackList;
      CloseFile(F1);
      Exit;
    end;
  end;

  CloseFile(F1);

  // 曲エントリがなかったらFalse
  if Flag=False then
  begin
    s:='List file is empty.  ';
    Windows.MessageBox( Form1.Handle, PChar(S), 'BridgeM1 : Error', MB_OK or MB_ICONSTOP );
    Exit;
  end;

  result:=True;

end;


//-----------------------------------------------------------------------
// Meta tag parser [new 0.5.1]
//
function ParseMetaTag(St: String; trklist:PTrackList): string;
var S: String;
    i: integer;
begin

  Result:='';

  // time
  i:= StrtoPlayTime( ExtractXML('time', St) );
  if i>0 then
  begin
    trklist.PlayTime := i;
    // 時間設定があるときのデフォルトはフェード無し
    trklist.FadeOut:=foNo;
  end
  else if i=-1 then
  begin
    Result:='Invalid time setting.';
    exit;
  end;

  // fadeout
  S:= ExtractXML('fadeout', St);
  if CompareText('yes', S)=0 then
    trklist.FadeOut:=foYes
  else
  if CompareText('no', S)=0 then
    trklist.FadeOut:=foNo;

  // fadeoutlength
  S:= ExtractXML('fadeoutlength', St);
  if S<>'' then
  begin
    try
      i:=StrtoInt(S);
      if (i>1) and (i<61) then
      begin
        trklist.FOLength := i*1000;
       
      end
      else
      begin
        Result:='Fadeout length must be between 2 and 60 seconds.';
        exit;
      end;

    except
    on EConvertError do
      begin
        Result:='Invalid fadeout length.';
        exit;
      end;
    end;
  end;
  
end;

// -----------------------------------------------------------------------------
// CSV分割1 カンマ区切り
function CsvSeparate(const Str: string; StrList: TStrings): integer;
var
  Head, Tail: PChar;
  Len: integer;
begin

  StrList.Clear;

  // 空文字の場合は項目は0
  if Str='' then
  begin
    Result:=0;
    exit;
  end;

  Head := PChar(Str);
  while True do
    if Head^ = '"' then begin
      StrList.Append(AnsiExtractQuotedStr(Head, '"'));
      if Head^ <> #0 then Inc(Head)
    end else begin
      Tail := AnsiStrPos(Head, ',');
      if Tail = nil then begin
        StrList.Append(Head);
        Break
      end else begin
        Len := Tail - Head;
        StrList.Append(Copy(Head, 1, Len));
        Inc(Head, Len + 1)
      end
    end;
  Result := StrList.Count
end;


// -----------------------------------------------------------------------------
// TSV分割
function TSVSeparate(const Str: string; StrList: TStrings): integer;
var
  Head, Tail: PChar;
  Len: integer;

begin
  StrList.Clear;

  Head := PChar(Str);
  while True do
  begin
    Tail := AnsiStrPos(Head, #9);
    if Tail = nil then
    begin
      StrList.Append(Head);
      Break
    end
    else
    begin
      Len := Tail - Head;
      StrList.Append(Copy(Head, 1, Len));
      Inc(Head, Len + 1)
    end;
  end;
  
  Result := StrList.Count
end;

function FontStylesToInteger(const Style: TFontStyles): Integer;
begin
  Result:=0;
  if fsBold in Style then Result:=Result or 1;
  if fsItalic in Style then Result:=Result or 2;
  if fsUnderline in Style then Result:=Result or 4;
  if fsStrikeOut in Style then Result:=Result or 8;
end;

function IntegerToFontStyles(Value: Integer): TFontStyles;
begin
  Result:=[];
  if (Value and 1)<>0 then Include(Result,fsBold);
  if (Value and 2)<>0 then Include(Result,fsItalic);
  if (Value and 4)<>0 then Include(Result,fsUnderline);
  if (Value and 8)<>0 then Include(Result,fsStrikeOut);
end;

// -----------------------------------------------------------------------------
// ini 保存
function SaveIni: integer;

function OnOff(Flag: Boolean): String;
begin
  if Flag then
    Result:='ON'
  else
    Result:='OFF';
end;


var
  F1: TextFile;
  i : integer;
  st: string;
  piOrderArray: Pinteger;
  iOrderArray: array of integer;
  
begin

  AssignFile(F1,exe_path+'bridge.ini');
  ReWrite(F1);

  WriteLn(F1,'# BridgeM1 settings');
  WriteLn(F1,'VERSION:=' + APPNAME);
  WriteLn(F1,'');

  WriteLn(F1,'[Paths]');

  st:='';
  if Length(rom_path)>0 then
  begin
    st:='ROM_PATH:=';
    for i:=0 to Length(rom_path)-1 do
    begin
      st:=st+rom_path[i]+';';
    end;
    st:=copy(st,0,length(st)-1);
    WriteLn(F1,st);
  end;

  WriteLn(F1,'WAV_PATH:='+wav_path);
  WriteLn(F1,'USER_WAV_FILENAME:='+OnOff(UserWavFileName));
  WriteLn(F1,'WAV_FILENAME_FORMAT:='+Wav_Format);

  WriteLn(F1,'');
  WriteLn(F1,'[Main Window]');
  WriteLn(F1,'MAIN_X:=' + InttoStr(Form1.Left));
  WriteLn(F1,'MAIN_Y:=' + InttoStr(Form1.Top));
  WriteLn(F1,'');
  WriteLn(F1,'[Track List]');

  WriteLn(F1,'LIST:='+OnOff(PlayList));
  
  WriteLn(F1,'LIST_X:=' + InttoStr(Form2.Left));
  WriteLn(F1,'LIST_Y:=' + InttoStr(Form2.Top));
  WriteLn(F1,'LIST_W:=' + InttoStr(Form2.DesignPixels(Form2.Width)));
  WriteLn(F1,'LIST_H:=' + InttoStr(Form2.DesignPixels(Form2.Height)));
  WriteLn(F1,'TLFONTNAME:=' + TLFont.Name);
  WriteLn(F1,'TLFONTSIZE:=' + InttoStr(TLFont.Size));
  WriteLn(F1,'TLFONTSTYLE:=' + IntToStr(FontStylesToInteger(TLFont.Style)));

  WriteLn(F1,'');
  WriteLn(F1,'[Load Window]');
  WriteLn(F1,'LOAD_X:=' + InttoStr(Form3.Left));
  WriteLn(F1,'LOAD_Y:=' + InttoStr(Form3.Top));
  WriteLn(F1,'LOAD_W:=' + InttoStr(Form3.DesignPixels(Form3.Width)));
  WriteLn(F1,'LOAD_H:=' + InttoStr(Form3.DesignPixels(Form3.Height)));
  if QueryMaker='(Manufacturer)' then
    WriteLn(F1,'MAKER:=')
  else
    WriteLn(F1,'MAKER:=' + QueryMaker);

  if QuerySystem='(System)' then
    WriteLn(F1,'SYSTEM:=')
  else
    WriteLn(F1,'SYSTEM:=' + QuerySystem);

  if QueryChip='(Chip)' then
    WriteLn(F1,'CHIP:=')
  else
    WriteLn(F1,'CHIP:=' + QueryChip);

  WriteLn(F1,'QUERYWORD:=' + QueryWord);
  WriteLn(F1,'SELECT:=' + selecting);
  WriteLn(F1,'ROM_CONDITION:=' + InttoStr(Rom_Condition));

  WriteLn(F1,'');

  // カラム幅
  St:=Inttostr(Form3.DesignPixels(ListView_GetColumnWidth(Form3.ListView1.Handle,0)));
  for i:=1 to Form3.ListView1.Columns.Count-1 do
  begin
    St:=St+','+Inttostr(Form3.DesignPixels(ListView_GetColumnWidth(Form3.ListView1.Handle,i)));
  end;
  WriteLn(F1,'RB_COLUMN_WIDTHS:='+St);

  // カラム順
  SetLength(iOrderArray,Form3.ListView1.Columns.Count);
  piOrderArray:=@iOrderArray[0];
  ListView_GetColumnOrderArray(Form3.ListView1.Handle,
                               Form3.ListView1.Columns.Count,
                               piOrderArray);
  St:=Inttostr(iOrderArray[0]);
  
  for i:=1 to Length(iOrderArray)-1 do
  begin
    St:=St+','+Inttostr(iOrderArray[i]);
  end;
  WriteLn(F1,'RB_COLUMN_ORDER:='+St);

    
  // ソートヒストリー
  st:=InttoStr(SortHistory[0]);
  for i:=1 to Length(SortHistory)-1 do
  begin
    st:=st+','+InttoStr(SortHistory[i]);
  end;
  WriteLn(F1,'SORT_HISTORY:='+St);

  
  // ミキサー
  WriteLn(F1,'');
  WriteLn(F1,'[Mixing Window]');
  WriteLn(F1,'MIXING:='+OnOff(MixerWindow));
  WriteLn(F1,'MIX_X:='+InttoStr(Form6.Left));
  WriteLn(F1,'MIX_Y:='+InttoStr(Form6.Top));


  WriteLn(F1,'');
  WriteLn(F1,'[Options]');

  // ノーマライズ
  WriteLn(F1,'NORMALIZE:='+OnOff(UseNormalize));
  
  // ノーマライズリセット
  WriteLn(F1,'RESET_NORMALIZE:='+OnOff(Reset_Normalize));
  
  // 固定音量
  WriteLn(F1,'USE_FIXEDVOLUME:='+OnOff(UseFixedVolume));

  // サンプリングレート
  if Sample_Rate<>0 then
    WriteLn(F1,'SAMPLE_RATE:='+InttoStr(Sample_Rate));

  // ステレオミックス
  WriteLn(F1,'STEREO_MIX:='+InttoStr(Stereo_Mix));

  // 自動次の曲
  WriteLn(F1,'AUTO_MOVE_ON:='+OnOff(AutoMoveOn));

  // リピート
  WriteLn(F1,'REPEAT_ONE:='+OnOff(Repeat_One));
  
  // VUメータのピーク表示
  WriteLn(F1,'PEAKS:='+OnOff(display_peaks));

  // 曲名の16進表示
  WriteLn(F1,'HEXADECIMAL:='+OnOff(Hexadecimal));

  // 最小時にシステムトレイに
  WriteLn(F1,'MINIMIZE_TO_SYSTRAY:='+OnOff(SystemTray));

  // デフォルト演奏時間を使うか
  WriteLn(F1,'USE_DEFAULT_TIME:='+OnOff(UseDefaultTime));

  // デフォルト演奏時間
  WriteLn(F1,'DEFAULT_PLAYTIME:='+IntToStr(DefaultPlayTime));

  // フェードアウト
  WriteLn(F1,'FADEOUT:='+OnOff(DefaultFadeout));

  // フェードアウト長
  WriteLn(F1,'FADEOUT_LENGTH:='+IntToStr(DefaultFOLength));

  // リフレッシュレート
  WriteLn(F1,'REFRESH_RATE:='+InttoStr(RefreshRate));

  // テキストスクロール速度
  WriteLn(F1,'SCROLL_SPEED:='+InttoStr(RefreshRate));
  
  WriteLn(F1,'');
  WriteLn(F1,'[Misc]');

  // テーマ名
  WriteLn(F1,'THEME:='+CurrentTheme);

  // 曲名のスクロール
  WriteLn(F1,'KEEP_SCROLL:='+OnOff(Keep_Scrolling));

  // ウィンドウのアタッチ
  WriteLn(F1,'ATTACH_WINDOW:='+OnOff(attachable));

  // 常に手前
  WriteLn(F1,'ALWAYS_ON_TOP:='+OnOff(AlwaysOnTop));

  // 表示言語
  case NewLang of
    LANG_JP : WriteLn(F1,'LANGUAGE:=JP');
    LANG_EN : WriteLn(F1,'LANGUAGE:=EN');
  end;

  // Optionsウィンドウの選択中タブ
  WriteLn(F1,'OPTION_TAB:='+IntToStr(OptionTabIndex));

  // マルチインスタンス
  WriteLn(F1,'ALLOW_MULTI_INSTANCE:='+OnOff(MultiInstance));

  // テスト
  //WriteLn(F1,'ADD_JP_DESC:='+OnOff(AddJPDesc));

  CloseFile(F1);

  result:=0;

end;

// -----------------------------------------------------------------------------
// ini 読み込み
function LoadIni: integer;
var
  F1    : TextFile;
  St,S,St2 : String;
  i     : integer;
  StrList: TStringList;
begin

  if not FileExists(exe_path+'bridge.ini') then
  begin
    result:=1;
    exit;
  end;

  AssignFile(F1, exe_path+'bridge.ini');
  Reset(F1);
  while not Eof(F1) do
  begin
    ReadLn(F1,St);

    if Copy(St,1,8)='ROM_PATH' then
    begin
      St:=Copy(St,pos(':=',St)+2,Length(St));
      if Copy(St,Length(St),1)<>';' then
        St:=St+';';

      i:=0;
      while (pos(';',St)<>0) do
      begin
        S:=Copy(St,1,Pos(';',St)-1);
        St:=Copy(St,Pos(';',St)+1,Length(St));

        Inc(i);
        SetLength(rom_path,i);
        rom_path[i-1]:=S;
      end;

    end
    else

    // user define wav file name [0.4.4]
    if Copy(St,1,10)='USER_WAV_F' then
      UserWavFileName:=(pos('OFF',St)=0)
    else

    // Sample rate [0.5.0]
    if Copy(St,1,10)='SAMPLE_RAT' then
    begin
      St:=Copy(St,pos(':=',St)+2,Length(St));
      Sample_Rate:=StrtoInt(St);
      if (Sample_Rate<>48000) and (Sample_Rate<>44100) and
         (Sample_Rate<>32000) and (Sample_Rate<>24000) and
         (Sample_Rate<>22050) and (Sample_Rate<>11025) and
         (Sample_Rate<>16000) and (Sample_Rate<>8000) then
        Sample_Rate:=44100;
    end
    else
    // Stereo Mix [0.5.0]
    if Copy(St,1,10)='STEREO_MIX' then
    begin
      St:=Copy(St,pos(':=',St)+2,Length(St));
      Stereo_mix:=StrtoInt(St);
      if (Stereo_Mix<0) and (Stereo_Mix>100) then
        Stereo_mix:=0;
    end
    else

    if Copy(St,1,10)='WAV_FILENA' then
    begin
      Wav_Format:=Copy(St,pos(':=',St)+2,Length(St));
    end
    else

    if Copy(St,1,8)='WAV_PATH' then
    begin
      St:=Copy(St,pos(':=',St)+2,Length(St));
      if DirectoryExists(St) then wav_path:=st;
    end
    else

    if Copy(St,1,6)='MAIN_X' then
    begin
      fm1.X:=StrtoInt(Copy(St,pos(':=',St)+2,Length(St)));
    end
    else

    if Copy(St,1,6)='MAIN_Y' then
    begin
      fm1.Y:=StrtoInt(Copy(St,pos(':=',St)+2,Length(St)));
    end
    else

    if Copy(St,1,6)='LIST_X' then
    begin
      fm2.X:=StrtoInt(Copy(St,pos(':=',St)+2,Length(St)));
      if abs(fm2.X)>4000 then fm2.X:=0;
    end
    else
    if Copy(St,1,6)='LIST_Y' then
    begin
      fm2.Y:=StrtoInt(Copy(St,pos(':=',St)+2,Length(St)));
      if abs(fm2.Y)>4000 then fm2.Y:=0;
    end
    else
    if Copy(St,1,6)='LIST_W' then
    begin
      fm2_w:=StrtoInt(Copy(St,pos(':=',St)+2,Length(St)));
    end
    else
    if Copy(St,1,6)='LIST_H' then
    begin
      fm2_h:=StrtoInt(Copy(St,pos(':=',St)+2,Length(St)));
    end
    else
    if Copy(St,1,10)='TLFONTNAME' then
    begin
      TLFont.Name:=Copy(St,pos(':=',St)+2,Length(St));
    end
    else
    if Copy(St,1,10)='TLFONTSIZE' then
    begin
      TLFont.Size:=StrtoInt(Copy(St,pos(':=',St)+2,Length(St)));
    end
    else
    if Copy(St,1,11)='TLFONTSTYLE' then
    begin
      TLFont.Style:=IntegerToFontStyles(
        StrToIntDef(Copy(St,pos(':=',St)+2,Length(St)),0));
    end
    else
    // ソート履歴
    if Copy(St,1,12)='SORT_HISTORY' then
    begin
      St:=Copy(St,pos(':=',St)+2,Length(St));
      StrList:=TStringList.Create;

      // 履歴のカラム数が合わない時は読み込まない
      if CsvSeparate(St,StrList)= Length(SortHistory) then
      begin
        for i:=0 to StrList.Count-1 do
        begin
          SortHistory[i]:=StrtoInt(StrList[i]);
        end;
      end;
      
      StrList.Free;
    end
    else
    if Copy(St,1,5)='LIST:' then
      PlayList:=(pos('OFF',St)=0)
    else
    if Copy(St,1,5)='PEAKS' then
      display_peaks:=(pos('OFF',St)=0)
    else

    // Form3
    // コラム幅
    if Copy(St,1,16)='RB_COLUMN_WIDTHS' then
    begin
      fm3_colwidths:=Copy(St,pos(':=',St)+2,Length(St));
    end
    else
    // コラム順
    if Copy(St,1,15)='RB_COLUMN_ORDER' then
    begin
      fm3_colorder:=Copy(St,pos(':=',St)+2,Length(St));
    end
    else
    if Copy(St,1,6)='LOAD_X' then
    begin
      fm3.X:=StrtoInt(Copy(St,pos(':=',St)+2,Length(St)));
    end
    else
    if Copy(St,1,6)='LOAD_Y' then
    begin
      fm3.Y:=StrtoInt(Copy(St,pos(':=',St)+2,Length(St)));
    end
    else
    if Copy(St,1,6)='LOAD_W' then
    begin
      fm3_w:=StrtoInt(Copy(St,pos(':=',St)+2,Length(St)));
    end
    else
    if Copy(St,1,6)='LOAD_H' then
    begin
      fm3_h:=StrtoInt(Copy(St,pos(':=',St)+2,Length(St)));
    end
    else
    if Copy(St,1,7)='MAKER:=' then
    begin
      St2 := Copy(St,pos(':=',St)+2,Length(St));
      if (St2<>'') and (St<>'--') then
        QueryMaker:=St2;
    end
    else
    if copy(St,1,6)='CHIP:=' then
    begin
      St2 := Copy(St,pos(':=',St)+2,Length(St));
      if (St2<>'') and (St<>'--') then
        QueryChip:=St2;
    end
    else
    if copy(St,1,8)='SYSTEM:=' then
    begin
      St2 := Copy(St,pos(':=',St)+2,Length(St));
      if (St2<>'') and (St<>'--') then
        QuerySystem:=St2;
    end
    else
    if copy(St,1,11)='QUERYWORD:=' then
    begin
      QueryWord:=Copy(St, pos(':=',St)+2, Length(St));
      if Length(QueryWord)>32 then
        QueryWord:=Copy(QueryWord,1,32);
    end
    else
    if copy(St,1,8)='SELECT:=' then
      selecting2:=Copy(St,pos(':=',St)+2,Length(St))
    else
    if copy(St,1,9)='NORMALIZE' then
      UseNormalize:=(pos('OFF',St)=0)
    else
    if copy(St,1,9)='RESET_NOR' then
      Reset_Normalize:=(pos('OFF',St)=0)
    else
    if copy(St,1,12)='AUTO_MOVE_ON' then
      AutoMoveOn:=(pos('OFF',St)=0)
    else
    if copy(St,1,10)='REPEAT_ONE' then
      Repeat_One:=(pos('OFF',St)=0)
    else
    if (copy(St,1,12)='USE_FIXEDVOL') then
      UseFixedVolume:=(pos('OFF',St)=0)
    else
    if (pos('HEXADECIMAL',St)<>0) then
      Hexadecimal:=(pos('OFF',St)=0)
    else
    if (pos('KEEP_SCROLL',St)<>0) then
      Keep_Scrolling:=(pos('OFF',St)=0)
    else
    if (pos('MINIMIZE_TO_SYSTRAY',St)<>0) then
      SystemTray:=(pos('OFF',St)=0)
    else
    if (pos('ATTACH_WINDOW',St)<>0) then
      attachable:=(pos('OFF',St)=0)
    else
    if (pos('ALWAYS_ON_TOP',St)<>0) then
      AlwaysOnTop:=(pos('OFF',St)=0)
    else
    if (pos('LANGUAGE',St)<>0) then
    begin
      St:=Copy(St,pos(':=',St)+2,Length(St));
      if St='JP' then DispLang:=LANG_JP;
      if St='EN' then DispLang:=LANG_EN;

      NewLang:=DispLang;
    end
    else
    if (pos('THEME:=',St)<>0) then
    begin
      St:=Copy(St,pos(':=',St)+2,Length(St));
      CurrentTheme:=St;
    end
    else
    if (pos('USE_DEFAULT_TIME',St)<>0) then
      UseDefaultTime:=(pos('OFF',St)=0)
    else
    if (pos('DEFAULT_PLAYTIME:=',St)<>0) then
    begin
      St:=Copy(St,pos(':=',St)+2,Length(St));
      DefaultPlayTime:=StrtoInt(St);
    end
    else  // Fade Out [0.5.2]
    if (pos('FADEOUT_LENGTH:=',St)<>0) then
    begin
      St:=Copy(St,pos(':=',St)+2,Length(St));
      DefaultFOLength:=StrtoInt(St);

      // validity check
      if (DefaultFOLength < 2000) or (DefaultFOLength > 30000) then
        DefaultFOLength := 10000;

    end
    else
    if (pos('FADEOUT',St)<>0) then
      DefaultFadeout:=(pos('OFF',St)=0)
    else
      // Refresh Rate
    if (pos('REFRESH_RATE:=',St)<>0) then
    begin
      St:=Copy(St,pos(':=',St)+2, Length(St));
      RefreshRate:=StrtoInt(St);

      // validity check
      if (RefreshRate < 0) or (RefreshRate > 2) then
        RefreshRate := 2;

      Case RefreshRate of
        0: Form1.Timer1.Interval := TIMER_20FPS;
        1: Form1.Timer1.Interval := TIMER_30FPS;
        2: Form1.Timer1.Interval := TIMER_60FPS;
      end;
      
    end
    else
      // Scroll Speed
    if (pos('SCROLL_SPEED:=',St)<>0) then
    begin
      St:=Copy(St,pos(':=',St)+2, Length(St));
      ScrollSpeed:=StrtoInt(St);

      // validity check
      if (ScrollSpeed < 0) or (ScrollSpeed > 4) then
        ScrollSpeed := 2;

      Case ScrollSpeed of
        0: SongScrollSpeed := SCROLL_SPEED0;
        1: SongScrollSpeed := SCROLL_SPEED1;
        2: SongScrollSpeed := SCROLL_SPEED2;
        3: SongScrollSpeed := SCROLL_SPEED3;
        4: SongScrollSpeed := SCROLL_SPEED4;
      end;

      DescScrollSpeed := SongScrollSpeed * 0.65;
      
    end
    else
    if (pos('ROM_CONDITION:=',St)<>0) then
    begin
      St:=Copy(St,pos(':=',St)+2,Length(St));
      Rom_Condition:=StrtoInt(St);
    end
    else
    if (pos('OPTION_TAB:=',St)<>0) then
    begin
      St:=Copy(St,pos(':=',St)+2,Length(St));
      OptionTabIndex:=StrtoInt(St);
    end
    else
    if Copy(St,1,5)='MIX_X' then
    begin
      fm6.X:=StrtoInt(Copy(St,pos(':=',St)+2,Length(St)));
    end
    else
    if Copy(St,1,5)='MIX_Y' then
    begin
      fm6.Y:=StrtoInt(Copy(St,pos(':=',St)+2,Length(St)));
    end
    else
    if Copy(St,1,6)='MIXING' then
    begin
      MixerWindow:=(pos('OFF',St)=0);
    end;

  end;

  CloseFile(F1);
  result:=0;

end;

// -----------------------------------------------------------------------------
// 各ゲームのcfg保存
procedure SaveGameCFG(GameID: Integer);
var
  i : Integer;
  F1: TextFile;
  St: String;
  content: boolean;
begin
{
    Stream : integer;   // ストリーム番号
    Channel: integer;   // チャンネル番号
    Name   : String;    // チャンネル名
    DefLev : integer;   // デフォルトレベル
    Level  : integer;   // 今のレベル
}

  if GameID=-1 then exit;

  content:=false;

  if not directoryexists( exe_path + CFGDIR ) then
  begin
    try
      createdir( exe_path + CFGDIR );
    except
    end;
  end;

  St:='';

  // Mixer設定
  for i:=0 to Length(Mixer)-1 do
  begin

    if (Mixer[i].DefLev<>Mixer[i].Level) then
    begin
      St:=St+'            '+
          '<stream number="'+InttoStr(Mixer[i].Stream)+'" '+
                  'channel="'+InttoStr(Mixer[i].Channel)+'" '+
                  'name="'+htmlspecialchar(Mixer[i].Name)+'" '+
                  'volume="'+InttoStr(Mixer[i].Level)+'" '+
                  'enabled="'+BooltoYesNo(Mixer[i].Enabled)+'" '+
          '/>'+#13#10;
          
      content:=true;
    end
    else
    if (Mixer[i].Enabled=false) then
    begin
      St:=St+'            '+
          '<stream number="'+InttoStr(Mixer[i].Stream)+'" '+
                  'channel="'+InttoStr(Mixer[i].Channel)+'" '+
                  'name="'+htmlspecialchar(Mixer[i].Name)+'" '+
                  'enabled="'+BooltoYesNo(Mixer[i].Enabled)+'" '+
          '/>'+#13#10;
          
      content:=true;
    end;
    
  end;

  // 出力内容があるときだけファイルを作る
  if content then
  begin
    try
      AssignFile(F1, JoinPath(JoinPath(exe_path, CFGDIR), PRomList(RL[GameID]).RomName+'.cfg'));
      ReWrite(F1);

      WriteLn(F1,#$EF#$BB#$BF+'<?xml version="1.0"?>');
      WriteLn(F1,'<!-- This file is autogenerated; comments and unknown tags will be stripped -->');
      WriteLn(F1,'<m1config version="1">');

      if St='' then
        WriteLn(F1,'    <game name="'+PRomList(RL[GameID]).RomName+'" />')
      else
      begin
        WriteLn(F1,'    <game name="'+PRomList(RL[GameID]).RomName+'">');
        WriteLn(F1,'        <mixer>');
        Write(F1,St);
        WriteLn(F1,'        </mixer>');
        WriteLn(F1,'    </game>');
      end;

      WriteLn(F1,'</m1config>');

    finally
      Close(F1);
    end;
  end
  else
  begin // 出力内容が無い時は削除する

    if FileExists(JoinPath(JoinPath(exe_path, CFGDIR), PRomList(RL[GameID]).RomName+'.cfg')) then
    begin

      DeleteFile(PChar(JoinPath(JoinPath(exe_path, CFGDIR), PRomList(RL[GameID]).RomName+'.cfg')));

    end;

  end;

end;

// -----------------------------------------------------------------------------
// 各ゲームのcfg読み込み
procedure LoadGameCFG(GameID: Integer);
var
  level : Integer;
  F1: TextFile;
  St,s: String;
begin

  if GameID=-1 then exit;

  SetLength(CfgMixer, 0);

  if not FileExists(JoinPath(JoinPath(exe_path, CFGDIR), PRomList(RL[GameID]).RomName+'.cfg')) then exit;

  AssignFile(F1, JoinPath(JoinPath(exe_path, CFGDIR), PRomList(RL[GameID]).RomName+'.cfg'));
  try
    Reset(F1);

    while not Eof(F1) do
    begin
      ReadLn(F1,St);

      // Mixer
//      if Pos('<mixer',St)<>0 then
//      begin
//        while (Pos('</mixer>',St)=0) and (not Eof(F1)) do
//        begin
//          ReadLn(F1,St);

          try
            if Pos('<stream', St)<>0 then
            begin
              s:=ExtractXML('volume', St);

              // volume設定が見つからないときは-1を入れる
              if s='' then
                level := -1
              else
                level := StrtoInt(s);

              // 値チェック
              if (level <= 255) and (level >= -1) then
              begin
                SetLength(CfgMixer, Length(CfgMixer)+1);
                CfgMixer[ Length(CfgMixer)-1 ].Stream  := StrToInt(ExtractXML('number', St));
                CfgMixer[ Length(CfgMixer)-1 ].Channel := StrtoInt(ExtractXML('channel', St));
                CfgMixer[ Length(CfgMixer)-1 ].Level   := level;
                CfgMixer[ Length(CfgMixer)-1 ].Enabled := YesNotoBool(ExtractXML('enabled', St));
              end;
            end;
          except
          on EConvertError do
            // Ignore invalid values
          end;

//        end;
//      end;

    end;

  finally
    Close(F1);
  end;
  
end;

// -----------------------------------------------------------------------------
// デフォルトcfg読み込み
procedure LoadDefaultCFG;
var
  level : Integer;
  F1: TextFile;
  St,s: String;

begin

  SetLength(DefMixers, 0);

  if not FileExists(JoinPath(JoinPath(exe_path, CFGDIR), 'default.cfg')) then exit;

  AssignFile(F1, JoinPath(JoinPath(exe_path, CFGDIR), 'default.cfg'));
  try
  
    Reset(F1);
    ReadLn(F1,St);
    
    while not Eof(F1) do
    begin

      // system
      if Pos('<system',St)<>0 then
      begin

        s:=ExtractXML('name',St);
        
        while (Pos('</system>',St)=0) and (not Eof(F1)) do
        begin

          ReadLn(F1,St);
          
          try
            if Pos('<stream', St)<>0 then
            begin
              level := StrtoInt(ExtractXML('volume', St));
              
              // 値チェック
              if (level <= 255) and (level >= 0) then
              begin
                SetLength(DefMixers, Length(DefMixers)+1);
                DefMixers[ Length(DefMixers)-1 ].System  := s;
                DefMixers[ Length(DefMixers)-1 ].Stream  := StrToInt(ExtractXML('number', St));
                DefMixers[ Length(DefMixers)-1 ].Channel := StrtoInt(ExtractXML('channel', St));
                DefMixers[ Length(DefMixers)-1 ].DefLev  := level;
              end;
            end;
          except
          on EConvertError do

          end;
          
        end;
       
      end // system
      else
      
      // game
      if Pos('<game',St)<>0 then
      begin

        s:=ExtractXML('name',St);

        while (Pos('</game>',St)=0) and (not Eof(F1)) do
        begin

          ReadLn(F1,St);
          
          try
            if Pos('<stream', St)<>0 then
            begin
              level := StrtoInt(ExtractXML('volume', St));
              // 値チェック
              if (level <= 255) and (level >= 0) then
              begin
                SetLength(DefMixers, Length(DefMixers)+1);
                DefMixers[ Length(DefMixers)-1 ].ROM     := s;
                DefMixers[ Length(DefMixers)-1 ].Stream  := StrToInt(ExtractXML('number', St));
                DefMixers[ Length(DefMixers)-1 ].Channel := StrtoInt(ExtractXML('channel', St));
                DefMixers[ Length(DefMixers)-1 ].DefLev  := level;
              end;
            end;
          except
          on EConvertError do

          end;
          
        end;
       
      end; // game

      ReadLn(F1,St);
      
    end;

  finally
    Close(F1);
  end;
  
end;


// -----------------------------------------------------------------------------
// TSV分割 WideString版
function WideTsvSeparate(Const Str: WideString; StrList: TWideStrings): Integer;
var
  Head, Tail: PWideChar;
  Len: Integer;

begin

  StrList.Clear;

  Head := PWideChar(Str);
  while True do
  begin
    Tail := StrScan(Head, #9);
    if Tail = nil then
    begin
      StrList.Add(Head);
      Break
    end
    else
    begin
      Len := Tail - Head;
      StrList.Add(Copy(Head, 1, Len));
      Inc(Head, Len + 1)
    end;
  end;

  Result := StrList.Count;
end;

//------------------------------------------------------------------------------
// TextWidth WideString版
//
function WideTextWidth(hDC: HDC; Text: LPWSTR): Integer;
var
  Size: TSize;
begin
  Windows.GetTextExtentPoint32W(hDC, Text, Length(Text), Size);
  Result := Size.cX;
end;

//------------------------------------------------------------------------------
// TextRect WideString版
//
procedure WideTextRect(hDC: HDC; Rect: TRect; X, Y: Integer; Text: WideString);
begin
  Windows.ExtTextOutW(hDC, X, Y, ETO_CLIPPED, @Rect, PWideChar(Text), Length(Text), nil);
end;

//------------------------------------------------------------------------------
// xmlの要素取り出し
function ExtractXML(const element: string; const xml:string): string;
var S:string;
    i:integer;
begin

  Result:='';
  if (Pos( ' '+element+'=', xml) = 0) and (Pos( '<'+element+'=', xml) = 0) then exit;

  S:= element+'=';
  i:= pos(S, xml) + length(S) + 1;
  Result:=Copy(xml, i, PosEx('"', xml, i) -i);

end;

//------------------------------------------------------------------------------
function htmlspecialchar(str: string): string;
begin

  str:=StringReplace(str,'&gt;','>',[rfReplaceAll]);
  str:=StringReplace(str,'&lt;','<',[rfReplaceAll]);
  str:=StringReplace(str,'&quot;','"',[rfReplaceAll]);
  str:=StringReplace(str,'&amp;','&',[rfReplaceAll]);
  Result:= str;

end;

function htmlspecialchars_decode(str: string): string;
begin

  str:=StringReplace(str,'>','&gt;',[rfReplaceAll]);
  str:=StringReplace(str,'<','&lt;',[rfReplaceAll]);
  str:=StringReplace(str,'"','&quot;',[rfReplaceAll]);
  str:=StringReplace(str,'&','&amp;',[rfReplaceAll]);
  Result:= str;

end;

function booltoyesno(bool: boolean): string;
begin

  if bool then
    Result:='yes'
  else
    Result:= 'no';

end;

function yesnotobool(str: string): boolean;
begin

  Result:= ( pos('no', AnsiLowerCase(str))=0 );

end;

end.
