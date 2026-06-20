unit Unit6;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, M1, Common, ComCtrls, CommCtrl, Buttons, ShellAPI,
  ImgList, System.ImageList, ImageScaling;

const
  DEVICES = 16;

type
  TForm6 = class(TForm)
    btnDefault: TSpeedButton;
    ImageListMixer: TImageList;
    procedure btnDefaultClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TrackBarsChange(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnReloadClick(Sender: TObject);
  private
    { Private 宣言 }
    FDefaultGlyph: TBitmap;
    FpntMoveOrg,
    FpntMoveFit     : TPoint;

    procedure WMEnterSizeMove(var MSG: Tmessage); message WM_EnterSizeMove;
    procedure WMMoving(var MSG: Tmessage); message WM_Moving;

    function Scale96(Value: Integer): Integer;
    procedure BuildDefaultImages;
    procedure CheckDefault; // デフォルトの音量から変更があるか

  protected
    procedure ChangeScale(M, D: Integer; IsDpiChange: Boolean); override;

  public
    { Public 宣言 }
    destructor Destroy; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure ResetMixer;
    procedure DisableMixer;

end;

type
 TMyTrackBar = class(TTrackBar)
       procedure CreateParams(var Params: TCreateParams); override;
end;

var
  Form6: TForm6;
  TrackBars : array of TMyTrackBar;
  CheckBoxes: array of TCheckBox;
  Labels    : array of TLabel;
  Labels2   : array of TLabel;

implementation

uses Unit1;

{$R *.dfm}

procedure TMyTrackBar.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style and not TBS_ENABLESELRANGE;
end;

procedure TForm6.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := Form1.Handle;
end;

function TForm6.Scale96(Value: Integer): Integer;
begin
  Result := MulDiv(Value, CurrentPPI, 96);
end;

procedure TForm6.BuildDefaultImages;
var
  I, SourceWidth: Integer;
  SourceFrame, Frame: TBitmap;
  MaskColor: TColor;
begin
  // Temporary DPI scaling until native high-resolution images are added.
  // The three legacy glyph states are rebuilt into the ImageList per DPI.
  if (FDefaultGlyph = nil) or FDefaultGlyph.Empty then
    Exit;

  SourceWidth := FDefaultGlyph.Width div 3;
  if SourceWidth = 0 then
    Exit;

  ImageListMixer.Clear;
  ImageListMixer.Width := Scale96(SourceWidth);
  ImageListMixer.Height := Scale96(FDefaultGlyph.Height);

  SourceFrame := nil;
  Frame := nil;
  try
    SourceFrame := TBitmap.Create;
    Frame := TBitmap.Create;
    SourceFrame.PixelFormat := pf32bit;
    SourceFrame.SetSize(SourceWidth, FDefaultGlyph.Height);
    for I := 0 to 2 do
    begin
      SourceFrame.Canvas.CopyRect(
        Rect(0, 0, SourceWidth, FDefaultGlyph.Height),
        FDefaultGlyph.Canvas,
        Rect(I * SourceWidth, 0, (I + 1) * SourceWidth,
          FDefaultGlyph.Height));
      ScaleImageBicubicGDIPlus(SourceFrame, Frame,
        ImageListMixer.Width, ImageListMixer.Height);
      MaskColor := Frame.Canvas.Pixels[0, Frame.Height - 1];
      ImageListMixer.AddMasked(Frame, MaskColor);
    end;
  finally
    Frame.Free;
    SourceFrame.Free;
  end;

  btnDefault.Images := ImageListMixer;
  btnDefault.ImageIndex := 0;
  btnDefault.DisabledImageIndex := 1;
  btnDefault.PressedImageIndex := 2;
  btnDefault.SelectedImageIndex := 2;
end;

procedure TForm6.ChangeScale(M, D: Integer; IsDpiChange: Boolean);
begin
  inherited;
  BuildDefaultImages;
end;

destructor TForm6.Destroy;
begin
  FDefaultGlyph.Free;
  inherited;
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
  rectScreen:=Form6.Monitor.WorkareaRect;

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

procedure TForm6.WMEnterSizeMove(var MSG: Tmessage);
begin
  inherited;

  FpntMoveOrg.X := Self.Left;
  FpntMoveOrg.Y := Self.Top;
  FpntMoveFit   := FpntMoveOrg;
  
end;

procedure TForm6.WMMoving(var MSG: Tmessage);
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
// -----------------------------------------------------------------------------
// ミキサーのリセット
procedure TForm6.ResetMixer;
var
  i, j: Integer;
begin

  btnDefault.Enabled:=False;
  SetLength(Mixer,0);

  if CurrentGameID=-1 then exit;
  

  // コアからデフォルトレベルを取得
  for i:=0 to m1snd_get_info_int(M1_IINF_NUMSTREAMS, CurrentGameID)-1 do
  begin

    for j:=0 to m1snd_get_info_int(M1_IINF_NUMCHANS, i)-1 do
    begin

      // 多すぎる場合
      if Length(Mixer)=DEVICES then
        break;
        
      SetLength(Mixer, Length(Mixer)+1);

      Mixer[Length(Mixer)-1].Stream   := i;
      Mixer[Length(Mixer)-1].Channel  := j;
      Mixer[Length(Mixer)-1].Name     := M1String(m1snd_get_info_str(M1_SINF_CHANNAME, (i shl 16) or j));
      Mixer[Length(Mixer)-1].DefLev   := m1snd_get_info_int(M1_IINF_CHANLEVEL, (i shl 16) or j);
      Mixer[Length(Mixer)-1].Level    := m1snd_get_info_int(M1_IINF_CHANLEVEL, (i shl 16) or j);
      Mixer[Length(Mixer)-1].Enabled  := True;

    end;

  end;

  // デフォルト値で上書きする
  for i:=0 to Length(DefMixers)-1 do
  begin

    // System or ROM
    if (DefMixers[i].System = PROMList(RL[CurrentGameID]).System) or
       (DefMixers[i].ROM = PROMList(RL[CurrentGameID]).RomName) then
    begin

      for j:=0 to Length(Mixer)-1 do
      begin

        if ( DefMixers[i].Stream=Mixer[j].Stream ) and
           ( DefMixers[i].Channel=Mixer[j].Channel ) then
        begin
          Mixer[j].DefLev := DefMixers[i].DefLev;
          Mixer[j].Level  := DefMixers[i].DefLev;
        end;

      end;
    end;

  end;
  
  // CFGの値で上書きする
  for i:=0 to Length(CFGMixer)-1 do
  begin

    for j:=0 to Length(Mixer)-1 do
    begin
      
      if ( CFGMixer[i].Stream=Mixer[j].Stream ) and
         ( CFGMixer[i].Channel=Mixer[j].Channel ) then
      begin

        // Level指定が見つからなかった場合
        if CFGMixer[i].Level=-1 then
          Mixer[j].Level:=Mixer[i].DefLev
        else
          Mixer[j].Level:=CFGMixer[i].Level;

        Mixer[j].Enabled:=CFGMixer[i].Enabled;
        m1snd_set_info_int(M1_SIINF_CHANLEVEL,
                           CFGMixer[i].Stream,
                           CFGMixer[i].Channel,
                           CFGMixer[i].Level );
      end;
    end;

  end;
  

  for i:=0 to Length(Mixer)-1 do
  begin

    TrackBars[i].Enabled := True;
    TrackBars[i].Position := Mixer[i].Level;

    Labels[i].Enabled:=True;
    Labels2[i].Enabled := True;
    Labels2[i].Caption := Mixer[i].Name;

    Checkboxes[i].Enabled:= True;
    CheckBoxes[i].Checked:= Mixer[i].Enabled;

    
    // チェックボックスの変更を反映させる
    if Mixer[i].Enabled then
      m1snd_set_info_int(M1_SIINF_CHANLEVEL,Mixer[i].Stream, Mixer[i].Channel, Mixer[i].Level)
    else
      m1snd_set_info_int(M1_SIINF_CHANLEVEL,Mixer[i].Stream, Mixer[i].Channel, 0);

  end;

  for i:=Length(Mixer) to Length(Labels)-1 do
  begin

    TrackBars[i].Enabled:=False;
    TrackBars[i].Position:=100;

    Checkboxes[i].Enabled:= False;
    CheckBoxes[i].Checked:= True;

    Labels[i].Enabled:= False;
    Labels[i].Caption:= '100 %';
    Labels2[i].Enabled:= False;
    Labels2[i].Caption:= '--';
  
  end;

  CheckDefault;
  
end;


procedure TForm6.CheckDefault; // デフォルトの音量から変更があるか
var i: integer;
    flag: boolean;
begin

  if CurrentGameID=-1 then
  begin
    btnDefault.Enabled:=False;
    exit;
  end;

  flag:=False;
  
  for i:=0 to Length(Mixer)-1 do
  begin
    if (Mixer[i].Level<>Mixer[i].DefLev) or (Mixer[i].Enabled=False) then
    begin
      flag:=True;
      Break;
    end;
  end;

  btnDefault.Enabled:=flag;

end;

procedure TForm6.FormCreate(Sender: TObject);
var

  i : Integer;
begin

  FDefaultGlyph := TBitmap.Create;
  FDefaultGlyph.Assign(btnDefault.Glyph);
  btnDefault.Glyph := nil;
  BuildDefaultImages;

  SetLength(TrackBars,DEVICES);
  SetLength(CheckBoxes,DEVICES);
  SetLength(Labels,DEVICES);
  SetLength(Labels2,DEVICES);

  for i:=0 to DEVICES-1 do
  begin

    CheckBoxes[i] := TCheckBox.Create(Form6);
    CheckBoxes[i].Parent := Form6;
    CheckBoxes[i].Enabled:=False;
    CheckBoxes[i].Left := Scale96(10);
    CheckBoxes[i].Top := Scale96(9 + i*24);
    CheckBoxes[i].Width:= Scale96(16);
    CheckBoxes[i].Height:= Scale96(17);
    CheckBoxes[i].Checked:=True;
    CheckBoxes[i].OnClick:=CheckBoxClick;
    CheckBoxes[i].Tag:=i;

    
    TrackBars[i] := TMyTrackbar.Create(Form6);
    TrackBars[i].Parent := Form6;
    TrackBars[i].Enabled:=False; // 値変更の処理を防ぐ
    TrackBars[i].Left := Scale96(28);
    TrackBars[i].Top := Scale96(10 + i*24);
    TrackBars[i].Width := Scale96(200);
    TrackBars[i].Height := Scale96(22);
    TrackBars[i].Visible := true;
    TrackBars[i].PageSize := 1;
    TrackBars[i].ThumbLength := Scale96(12);
    TrackBars[i].TickMarks := tmBoth;
    TrackBars[i].TickStyle := tsNone;
    TrackBars[i].Max := 255;
    TrackBars[i].Position := 100;
    TrackBars[i].OnChange:=TrackBarsChange;
    TrackBars[i].Tag:=i;


    Labels[i] := TLabel.Create(Form6);
    Labels[i].Parent := Form6;
    Labels[i].AutoSize:= False;
    Labels[i].Left := Scale96(225);
    Labels[i].Top := Scale96(10 + i*24);
    Labels[i].Width := Scale96(40);
    Labels[i].Height := Scale96(13);
    Labels[i].Caption:= '100 %';
    Labels[i].Font.Size:=8;
    Labels[i].Font.Name:='Tahoma';
    Labels[i].Alignment:=taRightJustify;
    Labels[i].Enabled:=False;

    Labels2[i] := TLabel.Create(Form6);
    Labels2[i].Parent := Form6;
    Labels2[i].Left := Scale96(272);
    Labels2[i].Top := Scale96(10 + i*24);
    Labels2[i].Font.Size:=8;
    Labels2[i].Font.Name:='Tahoma';
    Labels2[i].Caption:='--';
    Labels2[i].ShowAccelChar:=False;
    Labels2[i].Enabled:=False;
  end;

  Form6.Left:=fm6.X;
  Form6.Top:=fm6.Y;

end;

// 音量バーの変更
procedure TForm6.TrackBarsChange(Sender: TObject);
var
  i: Integer;
begin
     //
  if TTrackbar(Sender).Enabled=False then
    exit;

  i:=TTrackbar(Sender).Tag;

  Labels[i].Caption:=InttoStr(TTrackbar(Sender).Position)+' %';

  Mixer[i].Level:=TTrackbar(Sender).Position;

  if CheckBoxes[i].Checked then
    m1snd_set_info_int(M1_SIINF_CHANLEVEL, Mixer[i].Stream, Mixer[i].Channel, TTrackbar(Sender).Position);

  CheckDefault;
  
end;


// 音量レベルを初期値に戻す
procedure TForm6.btnDefaultClick(Sender: TObject);
var
  i:Integer;
begin

  for i:=0 to Length(Mixer)-1 do
  begin

    CheckBoxes[i].Checked:= True;
    Mixer[i].Enabled:=True;
    TrackBars[i].Position := Mixer[i].DefLev;
                                 
  end;

  btnDefault.Enabled:=False;
  
end;

procedure TForm6.CheckBoxClick(Sender: TObject);
var
  i:Integer;
begin

  // リセットのときは処理しない
  if TCheckBox(Sender).Enabled=False then
    exit;

  i:=TCheckBox(Sender).Tag;

  if TCheckBox(Sender).Checked=False then
    m1snd_set_info_int(M1_SIINF_CHANLEVEL,Mixer[i].Stream, Mixer[i].Channel, 0)
  else
    m1snd_set_info_int(M1_SIINF_CHANLEVEL,Mixer[i].Stream, Mixer[i].Channel, Mixer[i].Level);

  Mixer[i].Enabled  := TCheckBox(Sender).Checked;
  CheckDefault;

end;

procedure TForm6.FormShow(Sender: TObject);
begin

  MixerWindow:=True;

  // フォームの位置チェック
  // デスクトップ外にあるときは戻す
  
  if not PtinRect(Screen.DesktopRect,fm6) then
  begin
    Form6.Left:=100;
    Form6.Top:=100;
  end;

end;

procedure TForm6.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MixerWindow:=False;
end;


procedure TForm6.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ssLeft in Shift then
  begin
    ReleaseCapture;
     SendMessage(Handle, WM_SYSCOMMAND, SC_MOVE or 2, MakeLong(X, Y));

  end;
end;

procedure TForm6.btnReloadClick(Sender: TObject);
var
  i:Integer;
begin

  for i:=0 to Length(Mixer)-1 do
  begin

    CheckBoxes[i].Checked:= True;
    Mixer[i].Enabled:=True;
    TrackBars[i].Position := Mixer[i].DefLev;
                                 
  end;

  btnDefault.Enabled:=False;
  
end;

procedure TForm6.DisableMixer;
var i:integer;
begin

  for i:=0 to Length(Labels)-1 do
  begin

    TrackBars[i].Enabled:=False;
    TrackBars[i].Position:=100;

    Checkboxes[i].Enabled:= False;
    CheckBoxes[i].Checked:= True;

    Labels[i].Enabled:= False;
    Labels[i].Caption:= '100 %';
    Labels2[i].Enabled:= False;
    Labels2[i].Caption:= '--';

  end;

  btnDefault.Enabled:=False;

end;

end.
