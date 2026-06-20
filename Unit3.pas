unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, StrUtils,
  ComCtrls, ImgList, Common, M1, Unit4, Unit5, ExtCtrls, StdCtrls, Buttons,
  Commctrl, Menus, Clipbrd,
  XPStyleActnCtrls, ActnList, ActnMan, mmsystem, Themes, System.Actions,
  System.ImageList;
type
  TForm3 = class(TForm)
    Panel1:       TPanel;
    Panel2:       TPanel;
    StatusBar1: 	TStatusBar;
    ProgressBar1: TProgressBar;
    Image1:       TImage;
    ImageList1: 	TImageList;
    ImageList2: 	TImageList;
    PopupMenu1: 	TPopupMenu;
    PopupMenu3:   TPopupMenu;
    popReset:     TMenuItem;
    ActionManager1: TActionManager;
    actSetFocusToSearch: TAction;
    actResetSearch:     TAction;
    Timer1: TTimer;
    TabControl1:  TTabControl;
    btnResetSearch: TSpeedButton;
    ListView1:    TListView;
    cmbMaker:     TComboBox;
    cmbSystem:    TComboBox;
    ComboBox3:    TComboBox;
    cmbChip:      TComboBox;
    lblShow: TLabel;
    btnOK:        TButton;
    btnCancel:    TBitBtn;
    btnRescan:    TButton;
    btnOptions:   TButton;
    btnAudit:     TButton;
    edtSearch:    TEdit;
    actAddFilterSystem: TAction;
    FilterbySystem1: TMenuItem;
    actHidden: TAction;
    gbxInfo: TGroupBox;
    lblSystem: TLabel;
    lblHardware: TLabel;
    edtSystem: TEdit;
    edtHard: TEdit;
    edtManu: TEdit;
    edtDesc: TEdit;
    actResetPlayCount: TAction;
    ResetPlayCount1: TMenuItem;
    actAuditRom: TAction;
    AuditROMset1: TMenuItem;
 
    procedure RefreshListView;
    procedure FormCreate(Sender: TObject);
    procedure ListView1ColumnClick(Sender: TObject; Column: TListColumn);
    procedure cmbSystemChange(Sender: TObject);
    procedure cmbMakerChange(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure btnRescanClick(Sender: TObject);
    procedure btnOptionsClick(Sender: TObject);
    procedure cmbMakerEnter(Sender: TObject);
    procedure cmbSystemEnter(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure popRomInfoClick(Sender: TObject);
    procedure btnAuditClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure ComboBox3Enter(Sender: TObject);

    // For Virtual ListView
    procedure ListView1Data(Sender: TObject; Item: TListItem);
    procedure UpdateListView;
    procedure StatusBar1Resize(Sender: TObject);
    procedure popResetClick(Sender: TObject);
    procedure cmbChipEnter(Sender: TObject);
    procedure cmbChipChange(Sender: TObject);
    procedure ListView1AdvancedCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage;
      var DefaultDraw: Boolean);
    procedure ListView1DataFind(Sender: TObject; Find: TItemFind;
      const FindString: string; const FindPosition: TPoint;
      FindData: Pointer; StartIndex: Integer; Direction: TSearchDirection;
      Wrap: Boolean; var Index: Integer);
    procedure edtSearchEnter(Sender: TObject);
    procedure edtSearchExit(Sender: TObject);
    procedure actSetFocusToSearchExecute(Sender: TObject);
    procedure actResetSearchExecute(Sender: TObject);
    procedure edtSearchChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure edtSearchKeyPress(Sender: TObject; var Key: Char);
    procedure actAddFilterSystemUpdate(Sender: TObject);
    procedure actAddFilterSystemExecute(Sender: TObject);
    procedure actHiddenExecute(Sender: TObject);
    procedure edtDescMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtManuMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtSystemMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtHardMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure actResetPlayCountUpdate(Sender: TObject);
    procedure actResetPlayCountExecute(Sender: TObject);
    procedure actAuditRomExecute(Sender: TObject);
    procedure actAuditRomUpdate(Sender: TObject);
    
  private
    { Private 宣言 }

    SearchReset: Boolean; // 検索リセット中
    drop_index : Integer;   // ドロップダウンの変更チェック用
    Auditing    : Boolean;    // Audit中
    Cancel_Audit : Boolean; // Auditのキャンセル

    OriginProc: TWndMethod;     // 元のウィンドウ関数保持用
    procedure SubClassProc(var msg: TMessage); // Alternative Message process
    procedure SetListViewColumnSortMark(LV: TListView; ColumnIndex: Integer);
    procedure DisableInfoBox;
    procedure LayoutProgressBar;

  public
    { Public 宣言 }
    IconRect : TRect;
    procedure CreateParams(var Params: TCreateParams); override;
    function Scale96(Value: Integer): Integer;
    function DesignPixels(Value: Integer): Integer;

  end;

procedure Scan_Roms;
Function Save_RomStatus() : Boolean;
Function Load_RomStatus() : Boolean;

var
  Form3: TForm3;

  FOldHDWndProc: TFNWndProc;

implementation

uses Unit1;

{$R *.dfm}

procedure TForm3.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := Form1.Handle;
end;

function TForm3.Scale96(Value: Integer): Integer;
begin
  Result := MulDiv(Value, CurrentPPI, 96);
end;

function TForm3.DesignPixels(Value: Integer): Integer;
begin
  Result := MulDiv(Value, 96, CurrentPPI);
end;

procedure TForm3.LayoutProgressBar;
var
  I, PanelLeft: Integer;
begin
  if (ProgressBar1 = nil) or (StatusBar1.Panels.Count <= 2) then
    Exit;

  PanelLeft := 0;
  for I := 0 to 1 do
    Inc(PanelLeft, StatusBar1.Panels[I].Width);

  ProgressBar1.Left := PanelLeft + Scale96(2);
  ProgressBar1.Width := StatusBar1.Panels[2].Width - Scale96(2);
  if ProgressBar1.Width < 0 then
    ProgressBar1.Width := 0;
end;

//------------------------------------------------------------------------------
// サブクラスウィンドウ関数
procedure TForm3.SubClassProc(var msg: TMessage);
begin

  OriginProc(msg); //本来のウィンドウ関数を実行

  // ウィンドウメッセージによって処理を振り分け
  case msg.Msg of
    4122:
    begin
      SetListViewColumnSortMark(ListView1, SortHistory[0]);
    end;
    else
  end;

end;

// カラムソートマーク設定
procedure TForm3.SetListViewColumnSortMark(LV: TListView;
  ColumnIndex: Integer);
var
  i: Integer;
  hColumn: THandle;
  hi: THDItem;
  IsAsc: Boolean;
begin
  IsAsc := ColumnIndex > 0;
  ColumnIndex := Abs(ColumnIndex) - 1;

  hColumn := SendMessage(LV.Handle, LVM_GETHEADER, 0, 0);
  for i := 0 to LV.Columns.Count - 1 do
  begin
    FillChar(hi, SizeOf(hi), 0);
    hi.Mask := HDI_FORMAT;
    if SendMessage(hColumn, HDM_GETITEMA, i, LPARAM(@hi)) = 0 then
      Continue;

    hi.fmt := hi.fmt and not (HDF_SORTUP or HDF_SORTDOWN);
    if i = ColumnIndex then
    begin
      if IsAsc then
        hi.fmt := hi.fmt or HDF_SORTUP
      else
        hi.fmt := hi.fmt or HDF_SORTDOWN;
    end;

    SendMessage(hColumn, HDM_SETITEMA, i, LPARAM(@hi));
  end;
end;

//--------------------------------------------------------------------
// リストビューのソート処理
procedure TForm3.ListView1ColumnClick(Sender: TObject; Column: TListColumn);
var i,j:Integer;
begin

  // 選択コラム履歴対応
  if Abs(SortHistory[0])=Column.Index+1 then
  begin // 先頭にある場合逆順にする
    SortHistory[0]:=-SortHistory[0];
  end
  else
  begin // 後ろから持って来る
    
    for i:=0 to Length(SortHistory)-1 do
    begin
      if Abs(SortHistory[i])=Column.Index+1 then
      begin
        for j:=i downto 1 do
        begin
          SortHistory[j]:=SortHistory[j-1];
        end;
        SortHistory[0]:=Column.Index+1;
        break;
      end;
    end;
  end;

  SetListViewColumnSortMark(ListView1, SortHistory[0]);
  
  UpdateListView;

end;

procedure TForm3.ListView1SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin

  //

  // 選択時に更新前と更新後の2回呼び出されるので前の方をはじく
  if not Selected then exit;
  
  if (ListView1.Items.Count=0) or (Item.Index=-1) then
  begin
    btnOK.Enabled:=False;
    btnAudit.Enabled:=False;
    selecting:='';
    
    DisableInfoBox;

  end
  else
  begin

    // Audit中でなければ
    if not Auditing then
    begin
      btnOK.Enabled:=True;
      btnAudit.Enabled:=True;
      selecting:=Item.SubItems[1];
    end;

    if ListView1.Selected.Index<>-1 then
    begin
      gbxInfo.Caption:=PRomList(RLSub[ListView1.Selected.Index]).RomName;
      gbxInfo.Enabled:=True;
      edtDesc.Text:=PRomList(RLSub[ListView1.Selected.Index]).Title;
      edtManu.Text:=PRomList(RLSub[ListView1.Selected.Index]).Maker + ', ' +
                    PRomList(RLSub[ListView1.Selected.Index]).Year;
      edtSystem.Text:=PRomList(RLSub[ListView1.Selected.Index]).System;
      edtHard.Text:=PRomList(RLSub[ListView1.Selected.Index]).Hard;
      gbxInfo.Update;
    end;
      
  end;
  
end;

//---------------------------------------------------------------------
// ROMスキャン
procedure Scan_Roms();
var
  i,j:Integer;
begin

  ava_games:=0;
  for i:=0 to max_games-1 do
  begin
    PRomList(RL[i])^.Rom_state:=0;

    // リストファイルの検索
    if FileExists(Exe_Path+List_Path+PRomList(RL[i])^.RomName+'.lst') then
      PRomList(RL[i])^.List  := 'Yes'
    else
      PRomList(RL[i])^.List  := '';

    // ROMの検索
    for j:=0 to Length(rom_path)-1 do
    begin
      if (FileExists(JoinPath(rom_path[j], PRomList(RL[i])^.Master+'.zip'))
       or FileExists(JoinPath(rom_path[j], PRomList(RL[i])^.RomName+'.zip'))) then
      begin
        PRomList(RL[i])^.Rom_state:=1;
        ava_games:=ava_games+1;
        break;
      end;
    end;
  end;
  
end;


//---------------------------------------------------------------------
// リストの表示更新
procedure TForm3.RefreshListView;
begin

  ListView1.Refresh;

  // リスト項目が0件の場合に対応
  if ListView1.Items.Count=0 then
  begin
    btnOK.Enabled:=False;
    btnAudit.Enabled:=False;

    DisableInfoBox;
    
  end
  else
  begin
    btnOK.Enabled:=True;
    btnAudit.Enabled:=True;
  end;

end;

// --------------------------------------------------------------------
procedure TForm3.FormCreate(Sender: TObject);
var
  SortList: TStringList;
  i,j: integer;
  piOrderArray: Pinteger;
  iOrderArray: array of integer;
  StrList: TStringList;
  St,S,S2: String;

begin

  Panel1.DoubleBuffered:=True;
  Panel2.DoubleBuffered:=True;
  ListView1.DoubleBuffered:=True;
  gbxInfo.DoubleBuffered:=True;
  edtDesc.DoubleBuffered:=True;
  edtHard.DoubleBuffered:=True;
  edtSystem.DoubleBuffered:=True;
  edtManu.DoubleBuffered:=True;
  StatusBar1.DoubleBuffered:=True;

  // コントロールのウィンドウ関数を入れ替え
  // 元のウィンドウ関数は保存しておく
  OriginProc :=ListView1.WindowProc;
  ListView1.WindowProc :=SubClassProc;

  
  Form3.Caption:='M1 '+M1String(m1snd_get_info_str(M1_SINF_COREVERSION, 0));

  ProgressBar1.Parent:= StatusBar1;
  ProgressBar1.Top   := Scale96(2);
  ProgressBar1.Max   := max_games;
  StatusBar1Resize(StatusBar1);

  ComboBox3.ItemIndex:=Rom_condition;

  // フォームの位置チェック
  if (fm3.X=0) and (fm3.Y=0) then
  begin
    // 初期位置
    Form3.Top  := (Monitor.Height-Form3.Height) div 2 - 14;
    Form3.Left := (Monitor.Width-Form3.Width) div 2;
  end
  else
  if PtinRect(Screen.DesktopRect, fm3) then
  begin
    Form3.Left:= fm3.X;
    Form3.Top := fm3.Y;
  end
  else
  begin
    // 初期位置
    Form3.Top  := (Monitor.Height-Form3.Height) div 2 - 14;
    Form3.Left := (Monitor.Width-Form3.Width) div 2;
  end;

  // フォームサイズ
  if (fm3_w<>0) and (fm3_h<>0) then
  begin
    Form3.Width  := Scale96(fm3_w);
    Form3.Height := Scale96(fm3_h);
  end;

  // Vista向け位置調整
  if StyleServices.Enabled then
  begin
    ProgressBar1.Height:=ProgressBar1.Height-1;
  end;
  TabControl1.Width:=Form3.ClientWidth;
  TabControl1.Height:=Form3.ClientHeight-StatusBar1.Height;
  StatusBar1Resize(StatusBar1);


  // コラム幅
  StrList:=TStringList.Create;
  CsvSeparate(fm3_colwidths,StrList);
  if StrList.Count=ListView1.Columns.Count then
  begin
    for i:=0 to StrList.Count-1 do
    begin
      ListView_SetColumnWidth(ListView1.Handle, i,
        Scale96(StrToInt(StrList[i])));
    end;
  end;
  StrList.Free;

  // コラム順
  StrList:=TStringList.Create;
  CsvSeparate(fm3_colorder,StrList);

  if StrList.Count=ListView1.Columns.Count then
  begin
    SetLength(iOrderArray,ListView1.Columns.Count);
    piOrderArray:=@iOrderArray[0];

    for i:=0 to ListView1.Columns.Count-1 do
    begin
      iOrderArray[i]:=StrtoInt(StrList[i]);
    end;
    ListView_SetColumnOrderArray(ListView1.Handle,
                               Form3.ListView1.Columns.Count,
                               piOrderArray);
  end;
  StrList.Free;

  // メーカー選択コンボボックスの設定
  SortList := TStringList.Create;
  SortList.Duplicates:=dupIgnore;
  SortList.Sorted:=True;
  
  for i:=0 to max_games-1 do
  begin
    St:=PRomList(RL[i]).Maker;

    if St='Video System Co.' then St:='Video System'
    else if St='Irem America' then St:='Irem'
    else if St='Data East USA' then St:='Data East'
    else if St='Data East Pinball' then St:='Data East'
    else if St='Disney Interactive Studios' then St:='Disney'
    else if St='Mitchell, distributed by Capcom' then St:='Mitchell'
    else if St='Banpresto/Dynamic Pl. Toei Animation' then St:='Banpresto'
    else if St='ATW USA, Inc.' then St:='ATW';

    if Pos('America Corporation', St)<>0 then St:=Copy(St,1,Pos('America',St)-1)
    else if Pos('America Corp.', St)<>0 then St:=Copy(St,1,Pos('America',St)-1)
    else if Pos('Corp.', St)<>0 then St:=Copy(St,1,Pos('Corp.',St)-1)
    else if Pos('Corporation', St)<>0 then St:=Copy(St,1,Pos('Corporation.',St)-1);
    
    if (Pos('(',St)<>0) and (Pos(')',St)<>0) then St:=Trim(Copy(St,1,Pos('(',St)-1));
    if Pos('[',St)=1 then St:=Copy(St,2,Length(St));
    if Pos(']',St)=Length(St) then St:=Copy(St,1,Length(St)-1)
    else  St:=AnsiReplaceStr(St,']','/');
    
    St:=AnsiReplaceStr(St,' / ','/');
    St:=AnsiReplaceStr(St,' + ','/');
    St:=AnsiReplaceStr(St,', supported by ','/');
    St:=AnsiReplaceStr(St,', distributed by ','/');
    
    if Pos('/',St)<>0 then
    begin
      S:=Copy(St,Pos('/',St)+1,Length(St));

      if Pos('/',S)<>0 then
      begin
        S2:=Copy(S,Pos('/',S)+1,Length(S));
        SortList.Add(' '+Trim(S2));
        S:=Copy(S,1,Pos('/',S)-1);
      end;

      SortList.Add(' '+Trim(S));
      St:=Copy(St,1,Pos('/',St)-1);
    end;

    if St<>'' then SortList.Add(' '+Trim(St));
  end;

  for i:=0 to SortList.Count-1 do
  begin
    St:=Trim(SortList[i]);
    cmbMaker.Items.Add(St);

    if QueryMaker=St then
      cmbMaker.ItemIndex:=i+1;    // 読み込んだクエリがあったとき

  end;

  if cmbMaker.ItemIndex=0 then
    QueryMaker:='(Manufacturer)'; // 無効なクエリのとき

  SortList.Free;

  // 検索ボックス設定
  SearchReset:=True;
  edtSearch.Text:=QueryWord;
  SearchReset:=False;
  
  // チップ選択コンボボックスの設定
  SortList:=TStringList.Create;
  SortList.Duplicates:=dupIgnore;
  SortList.Sorted:=True;
  StrList:=TStringList.Create;

  for i:=0 to max_games-1 do
  begin
    St:=PRomList(RL[i]).Hard;
    // ' or 'の処理
    St:=AnsiReplaceText(St,' or ',',');

    for j:=0 to CSVSeparate(St, StrList)-1 do
    begin
      St:=StrList.Strings[j];
      if Pos('(',St)<>0 then
        St:=Copy(St,0,Pos('(',St)-1);

      St:=Trim(St);        
      SortList.Add(' '+St);
    end;
  end;

  for i:=0 to SortList.Count-1 do
  begin
    St:=Trim(SortList[i]);
    cmbChip.Items.Add(St);

    if QueryChip=St then
      cmbChip.ItemIndex:=i+1;    // 読み込んだクエリがあったとき

  end;

  if cmbChip.ItemIndex=0 then
    QueryChip:='(Chip)'; // 無効なクエリのとき

  SortList.Free;
  StrList.Free;


  // システム選択コンボボックスの設定
  for i:=0 to cmbSystem.Items.Count do
  begin
    if QuerySystem=cmbSystem.Items[i] then
    begin
      cmbSystem.ItemIndex:=i;
      break;
    end;
  end;
  if cmbSystem.ItemIndex=0 then
    QuerySystem:='(System)'; // 無効なクエリのとき



  // ROMスキャン
  if not Load_RomStatus then
    Scan_Roms;

  // リストアイテムの更新
  UpdateListView;

  // iniから読み込んだ項目を選択する
  if (RLSub.Count>0) then
  begin
    for i:=0 to RLSub.Count-1 do
    begin
      if PRomList(RLSub[i]).RomName=selecting2 then
      begin
        ListView1.Items[i].Selected:=True;
        ListView1.Items[i].Focused:=True;
        ListView1.ItemFocused.MakeVisible(True);
        break;
      end;
    end;
  end;

  // Rectがだぶってる
  IconRect:=Rect(0,0,16,16);

end;



// 全ROMのAudit
procedure TForm3.btnRescanClick(Sender: TObject);
var
  i,j:Integer;
  Save_Cursor : TCursor;
  Old_State : Integer;

begin

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;    // Show hourglass cursor
  btnOK.Enabled     :=False;
  btnRescan.Enabled :=False;
  btnOptions.Enabled:=False;
  btnAudit.Enabled  :=False;
  ListView1.PopupMenu:=Nil;
  Auditing := True;

  // DPI変更後の実幅とRescan用の進捗範囲をここで確定する
  StatusBar1Resize(StatusBar1);
  ProgressBar1.Min := 0;
  ProgressBar1.Max := max_games;
  ProgressBar1.Step := 1;
  ProgressBar1.Position := 0;

  try

    for i:=0 to max_games-1 do
    begin

      // リストファイルの検索
      if FileExists(Exe_Path+List_Path+PRomList(RL[i]).RomName+'.lst') then
        PRomList(RL[i]).List  := 'Yes'
      else
        PRomList(RL[i]).List  := '';

    end;

    for i:=0 to max_games-1 do
    begin

      if Cancel_Audit then break;
      
      // ROM Audit
      Old_State := PRomList(RL[i]).Rom_state;
      PRomList(RL[i]).Rom_state := AuditRom(PRomList(RL[i]).Idx);

      if PRomList(RL[i]).Rom_state<>Old_State then
      begin
        if Old_State=ROM_STATUS_OK then
          Dec(ava_games)
        else if PRomList(RL[i]).Rom_state=ROM_STATUS_OK then
          Inc(ava_games);
      end;

      for j:=0 to RLSub.Count-1 do
      begin
        if PRomList(RL[i]).Idx=PRomList(RLSub[j]).Idx then
        begin
          ListView1.UpdateItems(j,j);
          break;
        end;
      end;

      ProgressBar1.Position := i + 1;
      StatusBar1.Panels[1].Text:=Format('Auditing : %.1f %%',
                        [((i + 1) * 100 / max_games)]);
      Application.ProcessMessages;

    end;

  finally

    StatusBar1.Panels[1].Text:='';
    ProgressBar1.Position:=0;
    //RefreshListView;
    UpdateListView;
    btnCancel.ModalResult:=mrCancel;
    btnRescan.Enabled :=True;
    btnOptions.Enabled:=True;
    btnAudit.Enabled  :=btnOK.Enabled;
    ListView1.PopupMenu:=PopupMenu1;
    Auditing := False;
    Cancel_Audit:=False;
    Screen.Cursor := Save_Cursor;  // Always restore to normal
    
  end;

end;

procedure TForm3.btnOptionsClick(Sender: TObject);
begin

  if Form4.ShowModal=mrOK then
  begin
    ListView1.Refresh;
  end;

end;


procedure TForm3.cmbMakerChange(Sender: TObject);
begin

  // メーカー名での絞り込み
  if cmbMaker.ItemIndex<>drop_index then
  begin
    QueryMaker:=cmbMaker.Items[cmbMaker.ItemIndex];
    UpdateListView;
    drop_index:=cmbMaker.ItemIndex;
  end;

end;

procedure TForm3.cmbMakerEnter(Sender: TObject);
begin

  // 選択項目が変わらない場合のための処理
  drop_index:=cmbMaker.ItemIndex;

end;

procedure TForm3.cmbSystemChange(Sender: TObject);
begin

  // システムでの絞り込み
  if cmbSystem.ItemIndex<>drop_index then
  begin
    QuerySystem:=cmbSystem.Text;
    UpdateListView;
    drop_index:=cmbSystem.ItemIndex;
  end;

end;

procedure TForm3.cmbSystemEnter(Sender: TObject);
begin
  // 選択項目が変わらない場合のための処理
  drop_index:=cmbSystem.ItemIndex;
end;

procedure TForm3.btnOKClick(Sender: TObject);
begin

  if ListView1.Items.Count=0 then exit;

  if ListView1.ItemFocused.Index<>-1 then
  begin
    CurrentGameID:= PRomList(RLSub[ListView1.ItemFocused.Index]).Idx;
  end
  else
    ModalResult:=mrNone; // ロード無し

end;

procedure TForm3.btnCancelClick(Sender: TObject);
begin

  // Audit中ならAuditキャンセル
  if Auditing then
  begin
    Cancel_Audit:=True;
    ModalResult:=mrNone;
  end;

end;

procedure TForm3.ListView1DblClick(Sender: TObject);
begin

  if Auditing then
  begin
    beep;
    ModalResult:=mrNone;
  end
  else
  begin

    if (ListView1.ItemIndex<>-1) then
    begin
      CurrentGameID := PRomList(RLSub[ListView1.ItemIndex]).Idx;
      ModalResult:=mrOK;
    end;
    
  end;
  
end;

procedure TForm3.FormShow(Sender: TObject);
var Monitor:TMonitor;
begin

  /// マルチモニタのための処理
  if Application.MainForm <> nil then
    Monitor := Application.MainForm.Monitor
  else
    Monitor := Screen.Monitors[0];

  // メインフォームのモニタが違っていたら移動
  if Monitor <> Form3.Monitor then
  begin
    Form3.Top  := Monitor.Top + (Monitor.WorkareaRect.Bottom -
                  Monitor.WorkareaRect.Top - Form3.Height) div 2;
    Form3.Left := Monitor.Left+ (Monitor.Width  - Form3.Width ) div 2;
  end;

  // ウィンドウを最前面に
  // メインフォームだけ他アプリの背面に入るので手前に出す
  if AlwaysOnTop then
    SetWindowPos( Form1.Handle, HWND_TOPMOST,
                  0, 0, 0, 0,
                  SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);

  SetWindowPos( Form3.Handle, HWND_TOP,
                0, 0, 0, 0,
                SWP_NOMOVE or SWP_NOSIZE);

  // ヘッダー生成後に初期ソート方向を表示
  SetListViewColumnSortMark(ListView1, SortHistory[0]);

  ListView1.SetFocus;

end;

procedure TForm3.popRomInfoClick(Sender: TObject);
begin

  if ListView1.Items.Count=0 then exit;

  ShowRomInfo(PRomList(RLSub[ListView1.ItemFocused.Index]).Idx);
  Form5.ShowModal;
  RefreshListView;

end;


// 単品ROM Audit
procedure TForm3.btnAuditClick(Sender: TObject);
begin

  if ListView1.Items.Count=0 then exit;
  if ListView1.ItemFocused.Index=-1 then exit;

  
  SetWindowPos( Form5.Handle, HWND_TOP, 0, 0, 0, 0,
                SWP_NOMOVE or SWP_NOSIZE);

  ShowRomInfo(PRomList(RLSub[ListView1.ItemFocused.Index]).Idx);
  Form5.ShowModal;
  RefreshListView;

end;

// -----------------------------------------------------------------
// romstatus.ini読み込みとlstのスキャン
function Load_RomStatus: Boolean;
var
  i : Integer;
  F1: TextFile;
  St,rom_name : String;
  n: integer;
begin

  if not FileExists(exe_path+'romstatus.ini') then
  begin
    Result:=False;
    exit;
  end;

  ava_games:=0;
  AssignFile(F1,exe_path+'romstatus.ini');
  try
    Reset(F1);

    while not Eof(F1) do
    begin

      ReadLn(F1,St);

      if (Copy(St,1,2) <> '//') and (Trim(St)<>'') then
      begin

        // ROM名
        rom_name:=Copy(St,1,Pos(':=',St)-1);

        // 状態
        St:=Copy(St,Pos(':=',St)+2,Length(St));

        // 再生回数
        n := (StrtoInt(St)) div 10;
        if n>65535 then n:=65535;

        St:=Copy(St, Length(St), 1);
        if StrtoInt(St)>2 then St:='0';

        if St='1' then inc(ava_games);
        
        for i:=0 to max_games-1 do
        begin

          if rom_name=PRomList(RL[i]).RomName then
          begin
            PRomList(RL[i]).NumPlay:=n;
            PRomList(RL[i]).Rom_state:=StrtoInt(St);
            break;
          end;

        end;
      end;
    end;

  finally
    CloseFile(F1);
  end;

  for i:=0 to max_games-1 do
  begin
    // リストファイルの検索
    if FileExists(Exe_Path+List_Path+PRomList(RL[i]).RomName+'.lst') then
      PRomList(RL[i]).List  := 'Yes'
    else
      PRomList(RL[i]).List  := '';
  end;

  for i:=0 to RL.Count-1 do
  begin
    // リストファイルの検索
    if FileExists(Exe_Path+List_Path+PRomList(RL[i]).RomName+'.lst') then
      PRomList(RL[i]).List:='Yes'
    else
      PRomList(RL[i]).List:='';
  end;
 
  result:=True;

end;


// -----------------------------------------------------------------
// romstatus.ini書き込み

function Save_RomStatus() : Boolean;
var
  F1: TextFile;
  i,j: Integer;
begin

  AssignFile(F1,exe_path+'romstatus.ini');
  try
    ReWrite(F1);

    WriteLn(F1,'// Rom Status for BridgeM1');
    WriteLn(F1,'// 0=missing, 1=OK, 2=has a problem');
    WriteLn(F1,'');

    for i:=0 to RL.Count-1 do
    begin
      for j:=0 to RL.Count-1 do
      begin
        if i=PRomList(RL[j]).Idx then
        begin
          WriteLn(F1,PRomList(RL[i]).RomName+':='+
                     InttoStr( PRomList(RL[i]).NumPlay*10+PRomList(RL[i]).Rom_state) );
          break;
        end;
      end;
    end;
    
  finally
    CloseFile(F1);
  end;

  result:=true;

end;

procedure TForm3.FormDestroy(Sender: TObject);
begin
  Save_RomStatus();
end;


procedure TForm3.ComboBox3Change(Sender: TObject);
begin

  Rom_condition := ComboBox3.ItemIndex;
  UpdateListView;

  // ALL_SETS  = 0; // 全部
  // AVAILABLE = 1; // 使用可
  // BAD_SETS  = 2; // 不可
  // MEGADRIVE_ONLY
  
end;

procedure TForm3.ComboBox3Enter(Sender: TObject);
begin
  // 選択項目が変わらない場合のための処理
  drop_index:=ComboBox3.ItemIndex;
end;


//----------------------------------------------------------------------
// Virtual ListView (added in 0.4.4)
// OnData
procedure TForm3.ListView1Data(Sender: TObject; Item: TListItem);
var i : integer;
begin

  i:=Item.Index;
  Item.Caption := PRomList(RLSub[i]).Title;

  Item.SubItems.Add(PRomList(RLSub[i]).Year);
  Item.SubItems.Add(PRomList(RLSub[i]).RomName);
  Item.SubItems.Add(PRomList(RLSub[i]).Maker);
  Item.SubItems.Add(PRomList(RLSub[i]).System);
  Item.SubItems.Add(InttoStr(PRomList(RLSub[i]).NumPlay));
  Item.SubItems.Add(PRomList(RLSub[i]).List);
  
  Item.ImageIndex :=PRomList(RLSub[i]).Rom_state;

end;

// Reconstruct data and redraw ListView
procedure TForm3.UpdateListView;

  // 比較関数
  function AscSort(Item1, Item2: Pointer): Integer;
  var
    i: integer;
  begin

    Result:=0;

    if (Item1 = nil) or (Item2 = nil) then Exit;

    for i:=0 to Length(SortHistory)-1 do
    begin

      case SortHistory[i] of
        1,-1: Result := CompareStr(PRomList(Item1).Kana, PRomList(Item2).Kana);
        2,-2: Result := CompareText(PRomList(Item1).Year,    PRomList(Item2).Year);
        3,-3: Result := CompareText(PRomList(Item1).RomName, PRomList(Item2).RomName);
        4,-4: Result := CompareText(PRomList(Item1).Maker,   PRomList(Item2).Maker);
        5,-5: Result := CompareText(PRomList(Item1).System,  PRomList(Item2).System);
        6,-6: Result := PRomList(Item1).NumPlay - PRomList(Item2).NumPlay;
        7,-7: Result :=-CompareText(PRomList(Item1).List,    PRomList(Item2).List);
      else
        Result:=0;
      end;

      if SortHistory[i] < 0 then Result:=-Result;
      if Result<>0 then break;

    end;
  end;
  
var i : integer;
    Selected_Rom : String;
    //tick:  Longword;
    LQueryWord: String;
    ExactMatch: boolean;
    st:string;
begin

  ExactMatch:=False;

  // 選択項目の保持
  if ListView1.ItemIndex<>-1 then
    Selected_Rom:=ListView1.Selected.SubItems[1];

  RLSub.Clear;

  // 検索とフィルタ
  // インライン化

  case Rom_condition of
    ALL_SETS:
    begin

      RLSub.Assign(RL);

    end;

    AVAILABLE_SETS:
    begin
      for i:=0 to RL.Count-1 do
      begin
        if PRomList(RL[i]).Rom_state=1 then
          RLSub.Add(RL[i]);
      end;
    end;

    BAD_SETS:
    begin
      for i:=0 to RL.Count-1 do
      begin
        if PRomList(RL[i]).Rom_state<>1 then
          RLSub.Add(RL[i]);
      end;
    end;

    MEGADRIVE_ONLY:
    begin
      for i:=0 to RL.Count-1 do
      begin
        if PRomList(RL[i]).System='Sega Genesis/MegaDrive' then
          RLSub.Add(RL[i]);
      end;
    end;

  end;  

  //
  if QueryWord<>'' then
  begin

    St:=Copy(QueryWord, 1, 1);

    // 完全一致
    if (Length(QueryWord) > 2) and
       (Copy(QueryWord, 1, 1) = '"') and
       (Copy(QueryWord, Length(QueryWord), 1)='"') then
    begin
      ExactMatch:=True;
      LQueryWord:=AnsiLowerCase(Copy(QueryWord, 2, Length(QueryWord)-2 ));
    end
    else
    begin
      LQueryWord := AnsiLowerCase( QueryWord );

      // 左右の"をけずる
      if (Copy(LQueryWord, 1, 1) = '"') then
        LQueryWord:=Copy(LQueryWord, 2, Length(LQueryWord));
      if (Copy(QueryWord, Length(QueryWord), 1)='"') then
        LQueryWord:=Copy(LQueryWord, 1, Length(LQueryWord)-1);
    end;
    
    i:=0;

    if ExactMatch then
    begin
      while (i<=RLSub.Count-1) do
      begin
        if (LQueryWord <> AnsiLowerCase(PRomList(RLSub[i]).RomName)) and
           (LQueryWord <> AnsiLowerCase(PRomList(RLSub[i]).Title)) and
           (LQueryWord <> AnsiLowerCase(PRomList(RLSub[i]).Maker)) and
           (LQueryWord <> AnsiLowerCase(PRomList(RLSub[i]).System)) then
          RLSub.Delete(i)
        else
          Inc(i);
      end;
    end
    else
    begin

      while (i<=RLSub.Count-1) do
      begin
        if (Pos(LQueryWord, AnsiLowerCase(PRomList(RLSub[i]).RomName))<>0) or
           (Pos(LQueryWord, AnsiLowerCase(PRomList(RLSub[i]).Title))<>0) or
           (Pos(LQueryWord, AnsiLowerCase(PRomList(RLSub[i]).Maker))<>0) or
           (Pos(LQueryWord, AnsiLowerCase(PRomList(RLSub[i]).System))<>0) then
          Inc(i)
        else
          RLSub.Delete(i);
      end;
    end;

  end;

  if (QueryMaker<>'--') and (QueryMaker<>'(Manufacturer)') then
  begin
    i:=0;
    while (i<=RLSub.Count-1) do
    begin
      if pos(QueryMaker, PRomList(RLSub[i]).Maker)=0 then
        RLSub.Delete(i)
      else
        Inc(i);
    end;
  end;

  if (QuerySystem<>'--') and (QuerySystem<>'(System)') then
  begin
    i:=0;
    while (i<=RLSub.Count-1) do
    begin
      if pos(QuerySystem, PRomList(RLSub[i]).System)=0 then
        RLSub.Delete(i)
      else
        Inc(i);
    end;
  end;

  if (QueryChip<>'--') and (QueryChip<>'(Chip)') then
  begin
    i:=0;
    while (i<=RLSub.Count-1) do
    begin
      if pos(QueryChip, PRomList(RLSub[i]).Hard)=0 then
        RLSub.Delete(i)
      else
        Inc(i);
    end;
  end;

  RLSub.Sort(TListSortCompare(@AscSort));

  // Update ListView
  ListView1.Items.BeginUpdate;
  ListView1.Items.Count:=RLSub.Count;

  // 選択項目の復帰
  //
  if (RLSub.Count>0) then
  begin
    ListView1.Selected:= nil; // have to be called to bring selected event

    for i:=0 to RLSub.Count-1 do
    begin
      if PRomList(RLSub[i]).RomName=Selected_Rom then
      begin
        ListView1.Items[i].Selected:=True;
        ListView1.Items[i].Focused:=True;
        break;
      end;
    end;

    if ListView1.Selected= nil then // 選択項目が無いとき
    begin
      ListView1.Items[0].Selected:=True;
      ListView1.Items[0].Focused:=True;
    end;

    ListView1.ItemFocused.MakeVisible(True);

  end
  else
  begin
    btnOK.Enabled:=False;
    btnAudit.Enabled:=False;
    selecting:='';
    DisableInfoBox;
  end;

  ListView1.Selected:=ListView1.Items[ListView1.ItemIndex];
  ListView1.Items.EndUpdate;

  StatusBar1.Panels[0].Text:= InttoStr(ListView1.Items.Count) + ' / '+
                              InttoStr(max_games);

  //Label4.Caption:=InttoStr(timeGetTime-Tick);
end;


// StatusBar Resizing
procedure TForm3.StatusBar1Resize(Sender: TObject);
const
  ResizePanelNumber=2;    //リサイズするStatusbarのパネル番号を指定
  MinSize=0;              //リサイズされても維持したい最小のWidthを指定
var
  BarWidth,i: Integer;
begin

  with StatusBar1 do
  begin
    BarWidth := 0;
    for i:=0 to Panels.Count-1 do
    begin
      if not(i=ResizePanelNumber) then
        BarWidth := BarWidth + Panels[i].Width;
    end;

    if (Width-BarWidth) <=MinSize then
      Panels[ResizePanelNumber].Width := MinSize
    else
      Panels[ResizePanelNumber].Width := Width - BarWidth;

    LayoutProgressBar;
  end;

end;

// リストビューとフォームサイズのリセット
procedure TForm3.popResetClick(Sender: TObject);
var
  i: integer;
  piOrderArray: Pinteger;
  iOrderArray: array of integer;
  
begin

  // フォームサイズ
  Form3.Width  := Scale96(830);
  Form3.Height := Scale96(650);

  ListView1.Items.BeginUpdate;

  // コラム順
  SetLength(iOrderArray,ListView1.Columns.Count);
  piOrderArray:=@iOrderArray[0];

  for i:=0 to ListView1.Columns.Count-1 do
  begin
    iOrderArray[i]:=i;
  end;
  ListView_SetColumnOrderArray(ListView1.Handle,
                               ListView1.Columns.Count,
                               piOrderArray);

  // コラム幅
  ListView_SetColumnWidth(ListView1.Handle, 0, Scale96(290));
  ListView_SetColumnWidth(ListView1.Handle, 1, Scale96(52));
  ListView_SetColumnWidth(ListView1.Handle, 2, Scale96(70));
  ListView_SetColumnWidth(ListView1.Handle, 3, Scale96(120));
  ListView_SetColumnWidth(ListView1.Handle, 4, Scale96(208));
  ListView_SetColumnWidth(ListView1.Handle, 5, Scale96(40));
  ListView1.Items.EndUpdate;
  
end;

procedure TForm3.cmbChipEnter(Sender: TObject);
begin
  // 選択項目が変わらない場合のための処理
  drop_index:=cmbChip.ItemIndex;
end;

procedure TForm3.cmbChipChange(Sender: TObject);
begin

  // CPU・サウンドチップでの絞り込み
  if cmbChip.ItemIndex<>drop_index then
  begin
    QueryChip:=cmbChip.Items[cmbChip.ItemIndex];
    UpdateListView;
    drop_index:=cmbChip.ItemIndex;
  end;

end;

procedure TForm3.ListView1AdvancedCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage;
  var DefaultDraw: Boolean);
begin

  Case Item.ImageIndex of
    0 : ListView1.Canvas.Font.Color := $808080;
    1 : ListView1.Canvas.Font.Color := ListView1.Font.Color;
    2 : ListView1.Canvas.Font.Color := clRed;
  end;

  if Item.Index mod 2 = 1 then
    ListView1.Canvas.Brush.Color:=$f9f9f9;

end;

procedure TForm3.ListView1DataFind(Sender: TObject; Find: TItemFind;
  const FindString: string; const FindPosition: TPoint;
  FindData: Pointer; StartIndex: Integer; Direction: TSearchDirection;
  Wrap: Boolean; var Index: Integer);
var
  i: Integer;
  Found: Boolean;
begin

  i := StartIndex;
  if (Find = ifExactString) or (Find = ifPartialString) then
  begin
    repeat
      
      // 一番下まで行ったら先頭から検索を続ける
      if (i = RLSub.Count) then
        if Wrap then i := 0 else Exit;

      Found := Pos(AnsiUpperCase(FindString), AnsiUpperCase(PRomList(RLSub[i])^.Title)) = 1;

      if not Found then Inc(i);
      
    until Found or (i = StartIndex);

    if Found then Index := i;
    
  end;
end;

procedure TForm3.edtSearchEnter(Sender: TObject);
begin

  edtSearch.SelectAll;

  actSetFocusToSearch.ShortCut:=ShortCut(0,[]);
  actResetSearch.ShortCut:=ShortCut(0,[]);
  btnOK.Default:=False;
  
end;

procedure TForm3.edtSearchExit(Sender: TObject);
begin
  actSetFocusToSearch.ShortCut:=ShortCut(8,[]);
  actResetSearch.ShortCut:=ShortCut(46,[]);
  btnOK.Default:=True;
end;

procedure TForm3.actSetFocusToSearchExecute(Sender: TObject);
begin
  if edtSearch.Enabled then
  begin
    edtSearch.SetFocus;
  end;
end;

// 検索リセット
procedure TForm3.actResetSearchExecute(Sender: TObject);
var Flag:Boolean;
begin

  Flag:=((cmbMaker.ItemIndex<>0) or (cmbSystem.ItemIndex<>0) or
         (cmbChip.ItemIndex<>0) or (edtSearch.Text<>'') );

  SearchReset:=True;

  cmbMaker.ItemIndex:=0;
  cmbSystem.ItemIndex:=0;
  cmbChip.ItemIndex:=0;
  edtSearch.Text:='';
  QueryWord:='';

  QueryMaker:='(Manufacturer)';
  QuerySystem:='(System)';
  QueryChip:='(Chip)';

  if Flag then UpdateListView;

  drop_index:=0;
  SearchReset:=False;
  
end;

procedure TForm3.edtSearchChange(Sender: TObject);
begin

  if not SearchReset then
    Timer1.Enabled:=True;

end;

procedure TForm3.Timer1Timer(Sender: TObject);
begin

  QueryWord:=Trim(edtSearch.Text);
  Timer1.Enabled:=False;
  UpdateListView;

end;

procedure TForm3.edtSearchKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    ListView1.SetFocus;
    key := #0;
  end;
  
end;

procedure TForm3.actAddFilterSystemUpdate(Sender: TObject);
begin

  if ListView1.Items.Count<>0 then
  begin
    actAddFilterSystem.Enabled:=True;
    actAddFilterSystem.Caption:='Filter by "'+ PRomList(RLSub[ListView1.ItemFocused.Index]).System +'"' ;//ListView1.ItemFocused.SubItems[3]+'"';
  end
  else
  begin
    actAddFilterSystem.Enabled:=False;
    actAddFilterSystem.Caption:='Filter by System';
  end;

end;

procedure TForm3.actAddFilterSystemExecute(Sender: TObject);
begin

  if ListView1.Items.Count=0 then exit;

  SearchReset:=True;

  cmbMaker.ItemIndex:=0;
  cmbSystem.ItemIndex:=0;
  cmbChip.ItemIndex:=0;
  edtSearch.Text:='"'+PRomList(RLSub[ListView1.ItemFocused.Index]).System+'"';
  QueryWord:='"'+PRomList(RLSub[ListView1.ItemFocused.Index]).System+'"';

  QueryMaker:='(Manufacturer)';
  QuerySystem:='(System)';
  QueryChip:='(Chip)';
  UpdateListView;

  drop_index:=0;
  SearchReset:=False;
  
end;

procedure TForm3.actHiddenExecute(Sender: TObject);
var i: integer;
var St: string;
begin

  St:='';
  for i:=0 to RL.Count-1 do
  begin

    St:=St+PRomList(RL[i]).RomName+#9+PRomList(RL[i]).Title+#9+PRomList(RL[i]).Kana+#13#10;

  end;

  ClipBoard.AsText:=St;

  beep;
  
end;

procedure TForm3.DisableInfoBox;
begin
  gbxInfo.Caption:='Game Info';
  gbxInfo.Enabled:=False;
  edtDesc.Text:='--';
  edtManu.Text:='--';
  edtSystem.Text:='--';
  edtHard.Text:='--';
end;

procedure TForm3.edtDescMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  edtDesc.SelStart:=0;
  edtDesc.SelLength:=Length(edtDesc.Text)*2;
end;

procedure TForm3.edtManuMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  edtManu.SelStart:=0;
  edtManu.SelLength:=Length(edtManu.Text)*2;
end;

procedure TForm3.edtSystemMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  edtSystem.SelStart:=0;
  edtSystem.SelLength:=Length(edtSystem.Text)*2;
end;

procedure TForm3.edtHardMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  edtHard.SelStart:=0;
  edtHard.SelLength:=Length(edtHard.Text)*2;
end;

procedure TForm3.actResetPlayCountUpdate(Sender: TObject);
begin

  if ListView1.Items.Count=0 then
  begin
    actResetPlayCount.Enabled:=False;
  end
  else
  begin
    actResetPlayCount.Enabled:=(PRomList(RLSub[ListView1.ItemFocused.Index]).NumPlay<>0);
  end;
end;

procedure TForm3.actResetPlayCountExecute(Sender: TObject);
begin

  if ListView1.Items.Count<>0 then
  begin
    PRomList(RLSub[ListView1.ItemFocused.Index]).NumPlay:=0;
    ListView1.Invalidate;
  end;

end;

procedure TForm3.actAuditRomExecute(Sender: TObject);
begin

  if ListView1.Items.Count=0 then exit;

  if Auditing then exit;
  

  ShowRomInfo(PRomList(RLSub[ListView1.ItemFocused.Index]).Idx);
  Form5.ShowModal;
  RefreshListView;

end;

procedure TForm3.actAuditRomUpdate(Sender: TObject);
begin

  if ListView1.Items.Count<>0 then
  begin
    actAuditRom.Enabled:=True;
    actAuditRom.Caption:='&Audit '+ PRomList(RLSub[ListView1.ItemFocused.Index]).RomName +'...';
  end
  else
  begin
    actAuditRom.Enabled:=False;
    actAuditRom.Caption:='&Audit ROM Set...';
  end;

end;

end.
