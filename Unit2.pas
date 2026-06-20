unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ComCtrls, Common, ExtCtrls, ValEdit, StdCtrls, Buttons, MMSystem, M1,
  Menus, ShellAPI, ImgList, System.ImageList, ImageScaling;


type
  TForm2 = class(TForm)
    PopupMenu1:   TPopupMenu;
    Edit1:        TMenuItem;
    MoveUp1:      TMenuItem;
    MoveDown1:    TMenuItem;
    Delete1:      TMenuItem;
    InsertText1:  TMenuItem;
    N1:           TMenuItem;
    Panel1: TPanel;
    ListBox1: TListBox;
    Bevel1: TBevel;
    Label2: TLabel;
    Label1: TLabel;
    btnReload: TSpeedButton;
    ImageListReload: TImageList;

    procedure MakeVisible(index : Integer);

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBox1DblClick(Sender: TObject);
    procedure btnReloadClick(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListBox1KeyPress(Sender: TObject; var Key: Char);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Label2Click(Sender: TObject);
//    procedure Button2Click(Sender: TObject);
  private
    { Private 宣言 }

    FReloadGlyph: TBitmap;

    FpntMoveOrg,
    FpntMoveFit     : TPoint;

    Procedure WMSizing(var MSG: Tmessage); message WM_Sizing;
    procedure WMEnterSizeMove(var MSG: Tmessage); message WM_EnterSizeMove;
    procedure WMMoving(var MSG: Tmessage); message WM_Moving;
    procedure BuildReloadImages;

  protected
    procedure ChangeScale(M, D: Integer; IsDpiChange: Boolean); override;

  public
    { Public 宣言 }
    destructor Destroy; override;
    procedure CreateParams(var Params: TCreateParams); override;
    function Scale96(Value: Integer): Integer;
    function DesignPixels(Value: Integer): Integer;
  end;

var
  Form2: TForm2;

 

implementation

uses Unit1;

{$R *.dfm}


procedure FormFitSizeToForms(frmTgt: TForm; var rectNew: TRect; iSide: integer);

  procedure Sub(const rectTgt: TRect; var rectForm: TRect;
    const FitThreshold: Integer);
  begin
    if ((rectForm.Bottom + FitThreshold >= rectTgt.Top   ) and
        (rectForm.Top    - FitThreshold <= rectTgt.Bottom)) then
    begin

      // 左辺同士
      if (Abs(rectForm.Left - rectTgt.Left) <= FitThreshold) then
      begin
        Inc(rectForm.Left, rectTgt.Left - rectForm.Left);
      end
      // 左辺と右辺
      else
      if (Abs(rectForm.Left - rectTgt.Right) <= FitThreshold) then
      begin
        Inc(rectForm.Left, rectTgt.Right - rectForm.Left);
      end;

      // 右辺同士
      if (Abs(rectForm.Right - rectTgt.Right) <= FitThreshold) then
      begin
        Inc(rectForm.Right, rectTgt.Right - rectForm.Right);
      end
      // 右辺と左辺
      else
      if (Abs(rectForm.Right - rectTgt.Left ) <= FitThreshold) then
      begin
        Inc(rectForm.Right, rectTgt.Left- rectForm.Right);
      end;
    end;

    if ((rectForm.Right + FitThreshold >= rectTgt.Left ) and
        (rectForm.Left  - FitThreshold <= rectTgt.Right)) then
    begin
     
      // 上辺同士
      if (Abs(rectForm.Top - rectTgt.Top) <= FitThreshold) then
      begin
        Inc(rectForm.Top, rectTgt.Top - rectForm.Top);
      end
      // 上辺と下辺
      else
      if (Abs(rectForm.Top  - rectTgt.Bottom) <= FitThreshold) then
      begin
        Inc(rectForm.Top, rectTgt.Bottom - rectForm.Top);
      end;

      // 下辺同士
      if (Abs(rectForm.Bottom - rectTgt.Bottom) <= FitThreshold) then
      begin
        Inc(rectForm.Bottom, rectTgt.Bottom - rectForm.Bottom);
      end
      // 下辺と上辺
      else
      if (Abs(rectForm.Bottom - rectTgt.Top ) <= FitThreshold) then
      begin
        Inc(rectForm.Bottom, rectTgt.Top - rectForm.Bottom);
      end;
    end;
  end;

var
  iCntr   : integer;
  FitThreshold: Integer;
  frmTmp  : TForm;
  rectScreen,
  rectTmp,
  rectBuf : TRect;
begin

  FitThreshold := MulDiv(ciFittingThreshold, frmTgt.CurrentPPI, 96);

  rectBuf := rectNew;

  rectScreen := Form2.Monitor.WorkareaRect;
  Sub(rectScreen, rectBuf, FitThreshold);

  for iCntr := 0 to Screen.FormCount - 1 do
  begin
    frmTmp  := Screen.Forms[iCntr];
    if (frmTmp <> frmTgt) and (frmTmp.Visible) then
    begin
      rectTmp := GetRealWindowRect(frmTmp.Handle);
      Sub(rectTmp, rectBuf, FitThreshold);
      end;
  end;

  case (iSide) of
    WMSZ_LEFT,
    WMSZ_TOPLEFT,
    WMSZ_BOTTOMLEFT  : rectNew.Left  := rectBuf.Left;
    WMSZ_RIGHT,
    WMSZ_TOPRIGHT,
    WMSZ_BOTTOMRIGHT : rectNew.Right := rectBuf.Right;
  end;

  case (iSide) of
    WMSZ_TOP,
    WMSZ_TOPLEFT,
    WMSZ_TOPRIGHT    : rectNew.Top    := rectBuf.Top;

    WMSZ_BOTTOM,
    WMSZ_BOTTOMLEFT,
    WMSZ_BOTTOMRIGHT : rectNew.Bottom := rectBuf.Bottom;
  end;
end;


procedure FormFitMoveToForms(frmTgt: TForm; var rectForm: TRect);

  function SubH(const rectTgt: TRect; const dsktop: Boolean): boolean;
  begin
    Result := FALSE;
    if ((rectForm.Bottom + ciFittingThreshold >= rectTgt.Top   ) and
        (rectForm.Top    - ciFittingThreshold <= rectTgt.Bottom)) then
    begin

      // 左辺同士と右辺同士は デスクトップとの比較とターゲット外の時のみ
      if (Abs(rectForm.Left - rectTgt.Left) <= ciFittingThreshold) and
         ((rectForm.Bottom <= rectTgt.Top + ciFittingThreshold) or
          (rectTgt.Bottom - ciFittingThreshold <= rectForm.Top ) or dsktop) then
      begin
        OffsetRect(rectForm, rectTgt.Left - rectForm.Left, 0);
        Result := TRUE;
      end
      else
      if (Abs(rectForm.Right - rectTgt.Right) <= ciFittingThreshold) and
         ((rectForm.Bottom <= rectTgt.Top + ciFittingThreshold) or
          (rectTgt.Bottom-ciFittingThreshold <= rectForm.Top ) or dsktop) then
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

  function SubV(const rectTgt: TRect; const dsktop: Boolean): boolean;
  begin
    Result := FALSE;
    if ((rectForm.Right + ciFittingThreshold >= rectTgt.Left ) and
        (rectForm.Left  - ciFittingThreshold <= rectTgt.Right)) then
    begin
    
      // 上辺同士と下辺同士は デスクトップとの比較とターゲット外にあるとき
      if (Abs(rectForm.Top - rectTgt.Top) <= ciFittingThreshold) and
         ((rectForm.Right <= rectTgt.Left + ciFittingThreshold) or
          (rectTgt.Right - ciFittingThreshold <= rectForm.Left) or dsktop) then
      begin
        OffsetRect(rectForm, 0, rectTgt.Top - rectForm.Top);
        Result := TRUE;
      end
      else
      if (Abs(rectForm.Bottom - rectTgt.Bottom) <= ciFittingThreshold) and
         ((rectForm.Right <= rectTgt.Left) or
          (rectTgt.Right  <= rectForm.Left) or dsktop) then
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
var
  iCntr       : integer;
  frmTmp      : TForm;
  rectTmp     : TRect;
  rectScreen  : TRect;
begin

  // いまある画面の領域
  rectScreen:=Form2.Monitor.WorkareaRect;

  // 左右辺を隣接させる
  SubH(rectScreen,True);
  for iCntr := 0 to Screen.FormCount - 1 do
  begin
    frmTmp  := Screen.Forms[iCntr];
    rectTmp := GetRealWindowRect(frmTmp.Handle);
    if (frmTmp <> frmTgt) and (frmTmp.Visible) then
    begin
      if (SubH(rectTmp,False)) then
      begin
        break;
      end;
    end;
  end;


  // 上下辺を隣接させる
  SubV(rectScreen,True);
  for iCntr := 0 to Screen.FormCount - 1 do
  begin
    frmTmp  := Screen.Forms[iCntr];
    rectTmp := GetRealWindowRect(frmTmp.Handle);
    if (frmTmp <> frmTgt) and (frmTmp.Visible) then
    begin
      if (SubV(rectTmp,False)) then
      begin
        break;
      end;
    end;
  end;


end;

procedure TForm2.WMSizing(var MSG: Tmessage);
var
  RectNew,
  RectFit,
  RectOuter,
  RectReal: TRect;
  OffsetLeft,
  OffsetTop,
  OffsetRight,
  OffsetBottom: Integer;
begin
  inherited;

  RectNew := PRect(Msg.LParam)^;

  // WM_SIZING supplies the outer window rectangle, while snap targets use
  // DWM extended-frame bounds. Convert to the visual rectangle first, just
  // as WMMoving does, then convert the snapped result back to the outer rect.
  Windows.GetWindowRect(Handle, RectOuter);
  RectReal := GetRealWindowRect(Handle);
  OffsetLeft := RectReal.Left - RectOuter.Left;
  OffsetTop := RectReal.Top - RectOuter.Top;
  OffsetRight := RectReal.Right - RectOuter.Right;
  OffsetBottom := RectReal.Bottom - RectOuter.Bottom;

  RectFit := RectNew;
  Inc(RectFit.Left, OffsetLeft);
  Inc(RectFit.Top, OffsetTop);
  Inc(RectFit.Right, OffsetRight);
  Inc(RectFit.Bottom, OffsetBottom);

  FormFitSizeToForms(Self, RectFit, Msg.WParam);

  RectNew.Left := RectFit.Left - OffsetLeft;
  RectNew.Top := RectFit.Top - OffsetTop;
  RectNew.Right := RectFit.Right - OffsetRight;
  RectNew.Bottom := RectFit.Bottom - OffsetBottom;

  PRect(Msg.LParam)^ := RectNew;
  
  Msg.Result := -1;
  
end;

procedure TForm2.WMEnterSizeMove(var MSG: Tmessage);
begin
  inherited;

  FpntMoveOrg.X := Self.Left;
  FpntMoveOrg.Y := Self.Top;
  FpntMoveFit   := FpntMoveOrg;
  
end;

procedure TForm2.WMMoving(var MSG: Tmessage);
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

  rectNew := PRect(Msg.LParam)^;

  FpntMoveOrg.X := FpntMoveOrg.X + rectNew.Left - FpntMoveFit.X;
  FpntMoveOrg.Y := FpntMoveOrg.Y + rectNew.Top  - FpntMoveFit.Y;

  iWidth  := rectNew.Right  - rectNew.Left;
  iHeight := rectNew.Bottom - rectNew.Top;

  rectNew.TopLeft := FpntMoveOrg;
  rectNew.Right   := FpntMoveOrg.X + iWidth;
  rectNew.Bottom  := FpntMoveOrg.Y + iHeight;

  rectOuter := Rect(Self.Left, Self.Top, Self.Left + Self.Width, Self.Top + Self.Height);
  rectReal := GetRealWindowRect(Self.Handle);
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

procedure TForm2.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := Form1.Handle;

end;

function TForm2.Scale96(Value: Integer): Integer;
begin
  Result := MulDiv(Value, CurrentPPI, 96);
end;

function TForm2.DesignPixels(Value: Integer): Integer;
begin
  Result := MulDiv(Value, 96, CurrentPPI);
end;

procedure TForm2.BuildReloadImages;
var
  I, SourceWidth: Integer;
  SourceFrame, Frame: TBitmap;
  MaskColor: TColor;
begin
  // Temporary DPI scaling until native high-resolution images are added.
  // Keep this in sync with TForm6.BuildDefaultImages.
  if (FReloadGlyph = nil) or FReloadGlyph.Empty then
    Exit;

  SourceWidth := FReloadGlyph.Width div 3;
  if SourceWidth = 0 then
    Exit;

  ImageListReload.Clear;
  ImageListReload.Width := Scale96(SourceWidth);
  ImageListReload.Height := Scale96(FReloadGlyph.Height);

  SourceFrame := nil;
  Frame := nil;
  try
    SourceFrame := TBitmap.Create;
    Frame := TBitmap.Create;
    SourceFrame.PixelFormat := pf32bit;
    SourceFrame.SetSize(SourceWidth, FReloadGlyph.Height);
    for I := 0 to 2 do
    begin
      SourceFrame.Canvas.CopyRect(
        Rect(0, 0, SourceWidth, FReloadGlyph.Height),
        FReloadGlyph.Canvas,
        Rect(I * SourceWidth, 0, (I + 1) * SourceWidth,
          FReloadGlyph.Height));
      ScaleImageBicubicGDIPlus(SourceFrame, Frame,
        ImageListReload.Width, ImageListReload.Height);
      MaskColor := Frame.Canvas.Pixels[0, Frame.Height - 1];
      ImageListReload.AddMasked(Frame, MaskColor);
    end;
  finally
    Frame.Free;
    SourceFrame.Free;
  end;

  btnReload.Images := ImageListReload;
  btnReload.ImageIndex := 0;
  btnReload.DisabledImageIndex := 1;
  btnReload.PressedImageIndex := 2;
  btnReload.SelectedImageIndex := 2;
end;

procedure TForm2.ChangeScale(M, D: Integer; IsDpiChange: Boolean);
begin
  inherited;
  BuildReloadImages;
end;

destructor TForm2.Destroy;
begin
  FReloadGlyph.Free;
  inherited;
end;

//-------------------------------------------------------------------------
procedure TForm2.FormCreate(Sender: TObject);
begin

  FReloadGlyph := TBitmap.Create;
  FReloadGlyph.Assign(btnReload.Glyph);
  btnReload.Glyph := nil;
  BuildReloadImages;

  Panel1.DoubleBuffered:=True;
  ListBox1.DoubleBuffered:=True;
  Form2.DoubleBuffered:=True;

  // フォームの位置チェック
  if PtinRect(Screen.DesktopRect,Point(fm2.X, fm2.Y)) then
  begin
    Form2.Left := fm2.X;
    Form2.Top  := fm2.Y;
  end;

  Form2.Width  := Scale96(fm2_w);
  Form2.Height := Scale96(fm2_h);

  ListBox1.Width  := Panel1.ClientWidth-Scale96(10);
  ListBox1.Height := Panel1.ClientHeight-Scale96(8);
  Panel1.Height   := Form2.ClientHeight-Scale96(31);
  Label1.Top      := Form2.ClientHeight - Scale96(17) - Label1.Height div 2;
  Label2.Top      := Form2.ClientHeight - Scale96(17) - Label2.Height div 2;
  // Position and DPI scaling are handled by akRight/akBottom anchors.
  btnReload.BringToFront;

  // 言語別のフォント設定
  ListBox1.Font.Name:=TLFont.Name;
  ListBox1.Font.Size:=TLFont.Size;
  ListBox1.Font.Style:=TLFont.Style;

  Case DispLang of

    LANG_JP : // Japanese
    begin
      //ListBox1.Font.Charset:=ANSI_CHARSET;
      ListBox1.ItemHeight:=Abs(ListBox1.Font.Height) + Scale96(3);
    end;

    LANG_EN : // English
    begin
      //ListBox1.Font.Charset:=ANSI_CHARSET;
      ListBox1.ItemHeight:=Abs(ListBox1.Font.Height) + Scale96(3);
    end;

  end;


  // Normalizeボタン設定
  Set_Normalize(UseNormalize);

end;

procedure TForm2.FormShow(Sender: TObject);
begin

  PlayList:=True;

end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  PlayList:=False;

end;


//--------------------------------------------------------------------
// リストダブルクリック
procedure TForm2.ListBox1DblClick(Sender: TObject);
var
  song_no : Integer;
begin

  // プレイリストが無効なら終了
  // ROMがきちんと読めてないなら終了
  // ロード中なら終了
  if ListLoaded = False then exit;
  if rom_loaded = False then exit;
  if loading then exit;

  song_no := PTrackList(TL[ListBox1.ItemIndex])^.Song_No;

  // クリックした行が曲番号じゃなければ終了
  if song_no=-1 then exit;

  {
  if (song_no <= max_song_num) and
     (song_no >= 0) then //m1snd_get_info_int(M1_IINF_MINSONG, 0)) then
  begin}

    CurrentIndex:= ListBox1.ItemIndex;
    CurrentSongNo := song_no;
    StartPlay(CurrentSongNo);
    ListBox1.Invalidate;

  //end;

end;

procedure TForm2.btnReloadClick(Sender: TObject);
begin

  // プレイリスト読み込み
  if rom_loaded then
  begin

    // リスト再読込
    ListLoaded:=LoadList(PRomList(RL[CurrentGameID]).RomName);

    // List Mode設定
    if not ListLoaded then // リストなし
    begin
      Set_ListMode(False);
      CurrentIndex:=-1;
    end;

    // リスト内選択位置の復元
    if ListLoaded then
    begin
      if ( CurrentIndex < TL.Count ) and ( CurrentIndex > -1) then
      begin
        // その位置に曲があれば
        if PTrackList(TL[CurrentIndex]).Song_No<>-1 then
        begin
          Listbox1.ItemIndex:=CurrentIndex;
          CurrentSongNo :=PTrackList(TL[CurrentIndex]).Song_No;
        end
        else
        begin
          ListBox1.ItemIndex := -1;
          CurrentIndex := -1;
        end;
      end
      else // リストが短いとき
      if (TL.Count-1 < CurrentIndex ) then
      begin
        ListBox1.ItemIndex := -1;
        CurrentIndex := -1;
      end;
      
    end;

    // max_song_num(リロード時にmaxsongnumが設定されてない場合）
    if max_song_num = -1 then
    begin
      max_song_num:=m1snd_get_info_int(M1_IINF_MAXSONG, 0);
    end;

    // Fixed Volume関係
    if FixedVolume=-1 then
      m1snd_setoption(M1_OPT_FIXEDVOLUME, 100)
    else
      m1snd_setoption(M1_OPT_FIXEDVOLUME, FixedVolume);

    if not Normalize then
    begin
      if FixedVolume <> -1 then
        Form2.Label1.Caption:='Fixed Volume: '+ InttoStr(FixedVolume) +' %'
      else
        Form2.Label1.Caption:='Fixed Volume: --- %';
    end;

  end;

end;

procedure TForm2.ListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  if Shift=[ssCtrl] then
  begin

    case Key of



      Ord('W'):   // Ctrl+W
      begin
        Application.Minimize;
      end;
      
    end;

  end;
  
  case Key of
      Ord('Q'):
      begin
        Form1.Close;
        Application.Terminate;
        Exit;
      end;

      Ord('O'):
      begin
        Form1.btnLoadClick(Sender);
        Exit;
      end;
    111:begin
      //Form1.Image2Click(Sender);
    end; // /

    106:begin
      //Form1.Image3Click(Sender);
    end; // *

    96 :begin // Keypad 0
      Form1.btnLoadClick(Sender);
    end;
    
  end;


  if Form1.btnPlay.Enabled then
  begin
    case Key of
    // Play
    Ord('X'),101:
    begin // X, keypad 5
      if Integer(TimeGetTime)-KeyTickCount>KEY_REPEAT then
      begin
        Form1.btnPlayClick(Sender); KeyTickCount:=TimeGetTime;
      end;
    end;

    // Next
    Ord('B'),107,102:
    begin  // B, keypad +,keypad 6
      if Integer(TimeGetTime)-KeyTickCount>KEY_REPEAT then
      begin
        Form1.btnNextClick(Sender); KeyTickCount:=TimeGetTime;
      end;
    end;

    // Stop
    Ord('V'): StopPlay;

    // Pause
    Ord('C') , 32:
    begin
      if Integer(TimeGetTime)-KeyTickCount>KEY_REPEAT then
      begin
        Form1.btnPauseClick(Sender); KeyTickCount:=TimeGetTime;
      end;
    end;

    // Previous
    Ord('Z'),109,100 :
    begin // Z,keypad -, keypad 4
      if Integer(TimeGetTime)-KeyTickCount>KEY_REPEAT then
      begin
        Form1.btnPrevClick(Sender); KeyTickCount:=TimeGetTime;
      end;
    end;

    VK_RETURN :begin
        if ListLoaded then
        begin
          if Integer(TimeGetTime)-KeyTickCount>KEY_REPEAT then
          begin
            ListBox1DblClick(Sender); KeyTickCount:=TimeGetTime;
          end;
        end
        else
        begin
          if Integer(TimeGetTime)-KeyTickCount>KEY_REPEAT then
          begin
            Form1.btnPlayClick(Sender); KeyTickCount:=TimeGetTime;
          end;
        end;
      end;
    end;

  end;
end;

procedure TForm2.ListBox1KeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
end;

// --------------------------------------------------------------------
// リストのオーナードロー

procedure TForm2.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  St  :WideString;
  Rct :TRect;
  uFormat : Integer;
  Offset : Integer;
  
begin

  uFormat:= DT_LEFT or DT_SINGLELINE or DT_NOPREFIX or DT_EXPANDTABS or DT_VCENTER;

  with (Control as TListBox).Canvas do
  begin
    Font.Style:=ListBox1.Font.Style;

    // 選択行
    if (odSelected in State) then
    begin
      Brush.Color := clrLWSelected;
      Font.Color  := ListBox1.Font.Color;
    end;

    // プレイ中の行
    if Index=CurrentIndex then
    begin
      Font.Color:=clrLWPlaying;
    end;

    FillRect(Rect);

    Rct:=Rect;
    Inc(Rct.Left,LEFT_MARGIN);

    // 曲番号の描画とオフセット
    if PTrackList(TL[index]).Song_No<>-1 then
    begin
      if Hexadecimal then
        St := AnsiLowerCase(Format('0x%.2x',[PTrackList(TL[index]).Song_No]))
      else
        St := PTrackList(TL[index]).Song_St;
     
      Offset := ListBox1.Canvas.TextWidth('8') * (Length(St)+1);

      Rct.Right:=Offset + LEFT_MARGIN;

      DrawTextW(Handle, PWideChar(St), Length(St), Rct, uFormat);
      Inc(Rct.Left,Offset);
      Rct.Right:=Rect.Right;
      
    end;

    // プレイ中の行
    if Index=CurrentIndex then
    begin
      Font.Style:=ListBox1.Font.Style + [fsBold];
    end;

    //PTrackList(TL[index]).Text:=TntEdit1.Text;
    St:=PTrackList(TL[index]).Text;

    DrawTextW(Handle, PWideChar(ST), Length(ST), Rct, uFormat);

    // フォーカス枠線消す
    if odFocused in State then
      DrawFocusRect(Rect);

  end;

end;


// ---------------------------------------------------------------------------
// ListBoxのMakeVisible
procedure TForm2.MakeVisible(Index : Integer);
var
  ItemCount : Integer;
begin

  if ListBox1.Items.Count=0 then exit;

  // 最大数より多い場合は最後の項目
  if Index > (ListBox1.Items.Count + 1) then
    Index := ListBox1.Items.Count+1; 

  // 今表示されている項目数
  ItemCount := (ListBox1.Height-Scale96(4)) div ListBox1.ItemHeight;

  // 表示範囲内かどうか
  if (Index >= ListBox1.TopIndex) and (Index <= ListBox1.TopIndex+ItemCount-1) then
    exit;

  // 画面上側にある場合
  if (Index < ListBox1.TopIndex) then
    ListBox1.TopIndex:=Index
  else
    ListBox1.TopIndex:=Index-ItemCount+1;

end;   


//----------------------------------------------------------------------------
// Right Click to select item
procedure TForm2.ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbRight then
    ListBox1.ItemIndex := ListBox1.ItemAtPos(point(x, y), true);
    
end;

// ---------------------------------------------------------------------------
// lst Editor (Popup Edit)
procedure TForm2.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ssLeft in Shift then
  begin
    ReleaseCapture;
     SendMessage(Handle, WM_SYSCOMMAND, SC_MOVE or 2, MakeLong(X, Y));

  end;
end;

procedure TForm2.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of

    8  :begin // BackSpace
      if Form1.Visible then
        Form1.SetFocus;
    end;

  end;
  
end;

procedure TForm2.Label2Click(Sender: TObject);
begin
  label2.Caption:='';
  label2.Cursor:=crDefault;
end;

end.
