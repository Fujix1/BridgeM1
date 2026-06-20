unit Unit5;

interface

uses
  Windows, SysUtils, Graphics, Controls, Forms,
  ComCtrls, M1, Commctrl, StdCtrls, Classes, Buttons, Menus, Clipbrd,
  System.Zip;


type
  TForm5 = class(TForm)
    BitBtn1: TBitBtn;
    ListView1: TListView;
    btnRescan: TButton;
    GroupBox1: TGroupBox;
    lblFileName: TLabel;
    Edit1: TEdit;
    GroupBox2: TGroupBox;
    lblParentName: TLabel;
    Edit2: TEdit;
    lblWarn: TLabel;
    PopupMenu1: TPopupMenu;
    Copytoclipboard1: TMenuItem;
    procedure BitBtn1Click(Sender: TObject);
    procedure btnRescanClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListView1AdvancedCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage;
      var DefaultDraw: Boolean);
    procedure Copytoclipboard1Click(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var
  Form5: TForm5;
  Target_RomNum : Integer;

procedure ShowRomInfo(RomNum: Integer);
function AuditRom(RomNum: Integer) : Integer;

implementation

uses Unit1, Unit3, Common;

{$R *.dfm}

type
  TZipEntryInfo = record
    FileName: string;
    CRC: Cardinal;
    UncompressedSize: UInt64;
  end;

procedure FillZipEntryInfo(Zip: TZipFile; Index: Integer; out Entry: TZipEntryInfo);
var
  Header: TZipHeader;
begin
  Header := Zip.FileInfo[Index];
  Entry.FileName := Zip.FileName[Index];
  Entry.CRC := Header.CRC32;
  Entry.UncompressedSize := Header.UncompressedSize64;
end;

function ZipFindByCRC(Zip: TZipFile; CRC: Cardinal; out Entry: TZipEntryInfo): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Zip.FileCount - 1 do
  begin
    if Zip.FileInfo[I].CRC32 = CRC then
    begin
      FillZipEntryInfo(Zip, I, Entry);
      Result := True;
      Exit;
    end;
  end;
end;

function ZipFindByFileName(Zip: TZipFile; const FileName: string; out Entry: TZipEntryInfo): Boolean;
var
  I: Integer;
  EntryName: string;
begin
  Result := False;
  for I := 0 to Zip.FileCount - 1 do
  begin
    EntryName := StringReplace(Zip.FileName[I], '/', PathDelim, [rfReplaceAll]);
    EntryName := StringReplace(EntryName, '\', PathDelim, [rfReplaceAll]);
    if SameText(EntryName, FileName) or SameText(ExtractFileName(EntryName), FileName) then
    begin
      FillZipEntryInfo(Zip, I, Entry);
      Result := True;
      Exit;
    end;
  end;
end;

procedure TForm5.FormCreate(Sender: TObject);
begin

  // 言語別のフォント設定
  Case DispLang of

    LANG_JP : // 日本語
    begin
      lblFileName.Font.Charset:=SHIFTJIS_CHARSET;
      //lblFileName.Font.Name:='MS PGothic';
      lblParentName.Font.Charset:=SHIFTJIS_CHARSET;
      //lblParentName.Font.Name:='MS PGothic';

      Edit1.Font.Charset:=SHIFTJIS_CHARSET;
      //Edit1.Font.Name:='MS PGothic';
      Edit2.Font.Charset:=SHIFTJIS_CHARSET;
      //Edit2.Font.Name:='MS PGothic';
    end;

    LANG_EN : // 英語
    begin
      lblFileName.Font.Charset:=ANSI_CHARSET;
      //lblFileName.Font.Name:='MS Sans Serif';
      lblParentName.Font.Charset:=ANSI_CHARSET;
      //lblParentName.Font.Name:='MS Sans Serif';

      Edit1.Font.Charset:=ANSI_CHARSET;
      //Edit1.Font.Name:='MS Sans Serif';
      Edit2.Font.Charset:=ANSI_CHARSET;
      //Edit2.Font.Name:='MS Sans Serif';
    end;

  end;


  // フォーム初期位置
  Form5.Top  := Form3.Top + (Form3.Height - Form5.Height) div 2;
  Form5.Left := Form3.Left+ (Form3.Width  - Form5.Width ) div 2;

end;

procedure TForm5.FormShow(Sender: TObject);
var Monitor:TMonitor;
begin

  Monitor := Form3.Monitor;
  
  // フォームのモニタが違っていたら移動
  if Monitor <> Form5.Monitor then
  begin
    Form5.Top  := Form3.Top + (Form3.Height - Form5.Height) div 2;
    Form5.Left := Form3.Left+ (Form3.Width  - Form5.Width ) div 2;
  end;

  // ウィンドウを最前面に
  // メインフォームだけ他アプリの背面に入るので手前に出す
  if AlwaysOnTop then
  begin
    SetWindowPos( Form1.Handle, HWND_TOPMOST,
                  0, 0, 0, 0,
                  SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
                  
    SetWindowPos( Form5.Handle, HWND_TOPMOST,
                  0, 0, 0, 0,
                  SWP_NOMOVE or SWP_NOSIZE);

  end
  else
  begin
    SetWindowPos( Form5.Handle, HWND_NOTOPMOST,
                  0, 0, 0, 0,
                  SWP_NOMOVE or SWP_NOSIZE);

    SetWindowPos( Form5.Handle, HWND_TOP,
                  0, 0, 0, 0,
                  SWP_NOMOVE or SWP_NOSIZE);

  end;
  
end;


procedure ShowRomInfo(RomNum: Integer);

type // ROM情報用
  TRomInfo = record
    FileName  : string;   // ROM file name
    CRC       : Integer;  // CRC
    FileSize  : Integer;  // File Size
    Checked   : Boolean;  // チェック済フラグ
    Status    : string;   // Status
  end;

var j : integer;

    RomName,ParentName : String;
    RN, PN  : String;
    Zip: TZipFile;
    ZipEntry: TZipEntryInfo;
    Has_Parent : Boolean; // 親ありか
    Found_Child, Found_Parent : boolean;
    ToBeChecked : Integer;

    ROM : Array of TRomInfo;

    Audit : Integer;

begin

  // Rescan用に番号を保持
  Target_RomNum:=RomNum;


  with Form5 do
  begin

    Found_Child :=False;
    Found_Parent:=False;
    lblWarn.Caption:='';

    // ファイル名と親名
    RomName :=M1String(m1snd_get_info_str(M1_SINF_ROMNAME, RomNum)) + '.zip';
    ParentName := M1String(m1snd_get_info_str(M1_SINF_PARENTNAME,RomNum)) + '.zip';
    Has_Parent:=(m1snd_get_info_int(M1_IINF_HASPARENT,RomNum) = 1);
    lblFileName.Caption := M1String(m1snd_get_info_str(M1_SINF_ROMNAME, RomNum));

    RN := RomName;
    PN := ParentName;

    if Has_Parent then
      lblParentName.Caption := M1String(m1snd_get_info_str(M1_SINF_PARENTNAME,RomNum))
    else
      lblParentName.Caption := 'None';


    /// 子ファイルのパス
    Edit1.Text:='Not found';
    for j:=0 to Length(rom_path)-1 do
    begin
      if (FileExists(JoinPath(rom_path[j], RomName))) then
      begin
        RomName:=JoinPath(rom_path[j], RomName);
        Found_Child:=True;
        Edit1.Text:=RomName;
        Break;
      end;
    end;

    // 親のパス
    Edit2.Text:='';
    if Has_Parent then
    begin
      Edit2.Text:='Not found';
      for j:=0 to Length(rom_path)-1 do
      begin
        if (FileExists(JoinPath(rom_path[j], ParentName))) then
        begin
          ParentName:=JoinPath(rom_path[j], ParentName);
          Found_Parent:=True;
          Break;
        end;
      end;
    end;

    if Found_Parent then Edit2.Text:=ParentName;
    if Found_Child  then Edit1.Text:=RomName;


    /// ROM情報
    // CRCチェック用
    ToBeChecked:=m1snd_get_info_int(M1_IINF_ROMNUM, RomNum);
    SetLength(ROM, ToBeChecked);

    for j:=0 to Length(ROM)-1 do
    begin
      ROM[j].FileName := M1String(m1snd_get_info_str(M1_SINF_ROMFNAME, RomNum or (j shl 16)));
      ROM[j].CRC      := m1snd_get_info_int(M1_IINF_ROMCRC, RomNum or (j shl 16));
      ROM[j].FileSize := m1snd_get_info_int(M1_IINF_ROMSIZE, RomNum or (j shl 16));
      ROM[j].Checked  := False;
      ROM[j].Status   := 'Not found';
    end;

    // Zip開く
    // 子セットをチェック
    if Found_Child then
    begin
      Zip := TZipFile.Create;
      try
        try
          Zip.Open(RomName, zmRead);

          for j:=0 to Length(ROM)-1 do
          begin

            if ZipFindByCRC(Zip, Cardinal(ROM[j].CRC), ZipEntry) then
            begin
              ROM[j].Checked := True; // フラグ
              ROM[j].Status := 'OK';
              Dec(ToBeChecked);     // 残チェック数-1
            end;

            // CRC一致が見つからないときはファイル名で探す
            if (ROM[j].Checked=False) and
               ZipFindByFileName(Zip, ROM[j].FileName, ZipEntry) then
            begin

              // CRCが0000000ならチェックOK
              if ROM[j].CRC=0 then
                ROM[j].Status:='OK'
              else
                ROM[j].Status := Format('Wrong CRC: %.8x',[ZipEntry.CRC]);

            end;

          end;

        except
          lblWarn.Caption:=RN+' may be corrupted!!';
        end;
      finally
        Zip.Free;
      end;
    end;
    // 親セットで残りをチェック
    if (ToBeChecked <> 0) and Found_Parent then
    begin
      Zip := TZipFile.Create;
      try
        try
          Zip.Open(ParentName, zmRead);
          for j:=0 to Length(ROM)-1 do
          begin

            if ROM[j].Checked=False then
            begin
              if ZipFindByCRC(Zip, Cardinal(ROM[j].CRC), ZipEntry) then
              begin
                ROM[j].Checked := True; // フラグ
                ROM[j].Status := 'OK in parent';
                //Dec(ToBeChecked,1);     // 残チェック数-1
              end;

              // CRC一致が見つからないときはファイル名で探す
              if (ROM[j].Checked=False) and
                 ZipFindByFileName(Zip, ROM[j].FileName, ZipEntry) then
              begin

              // CRCが0ならチェックOK
              if ROM[j].CRC=0 then
                ROM[j].Status:='OK'
              else
                ROM[j].Status := Format('Wrong CRC: %.8x in parent',[ZipEntry.CRC]);

              end;

            end;
          end;

        except
          lblWarn.Caption:=PN+' may be corrupted!!';
        end;
      finally
        Zip.Free;
      end;
    end;


    Audit:=ROM_STATUS_OK;

    // リストに結果表示

    ListView1.Items.BeginUpdate;
    ListView1.Items.Clear;
    for j:=0 to Length(ROM)-1 do
    begin
      ListView1.Items.Add.Caption := ROM[j].FileName;
      ListView1.Items[ListView1.Items.Count-1].Subitems.Add(InttoStr(ROM[j].FileSize));
      ListView1.Items[ListView1.Items.Count-1].Subitems.Add(Format('%.8x',[ROM[j].CRC]));
      ListView1.Items[ListView1.Items.Count-1].Subitems.Add(ROM[j].Status);
      if Pos('OK',ROM[j].Status)=0 then
        Audit:=ROM_STATUS_ERROR;
    end;

    ListView1.Items.EndUpdate;

    if (Found_Parent=False) and (Found_Child=False) then
      Audit:=ROM_STATUS_MISSING;
      
    // Available数の処理
    if (Audit=ROM_STATUS_OK) and (PRomList(RL[RomNum]).Rom_state<>ROM_STATUS_OK) then
      Inc(ava_games)
    else
    if (Audit<>ROM_STATUS_OK) and (PRomList(RL[RomNum]).Rom_state=ROM_STATUS_OK) then
      Dec(ava_games);

    PRomList(RL[RomNum]).Rom_state:=Audit;

    // listファイルの検索
    if FileExists(Exe_Path+List_Path+PRomList(RL[RomNum]).RomName+'.lst') then
      PRomList(RL[RomNum]).List  := 'Yes'
    else
      PRomList(RL[RomNum]).List  := '';

  end;

end;



function AuditRom(RomNum: Integer) : Integer;
var j : integer;
    RomName,ParentName : String;
    Zip: TZipFile;
    ZipEntry: TZipEntryInfo;

    CRC : Integer; // CRC
    Has_Parent : Boolean; // 親ありか
    St  : String;

    Found_Child, Found_Parent : boolean;
    CRC_Checked : Array of Boolean;
    ToBeChecked : Integer;


begin

  with Form5 do
  begin

    Found_Child :=False;
    Found_Parent:=False;

    // ファイル名と親名
    RomName :=M1String(m1snd_get_info_str(M1_SINF_ROMNAME, RomNum)) + '.zip';
    ParentName := M1String(m1snd_get_info_str(M1_SINF_PARENTNAME,RomNum)) + '.zip';
    Has_Parent:=(m1snd_get_info_int(M1_IINF_HASPARENT,RomNum) = 1);


    /// 子ファイルのパス
    for j:=0 to Length(rom_path)-1 do
    begin
      if (FileExists(JoinPath(rom_path[j], RomName))) then
      begin
        RomName:=JoinPath(rom_path[j], RomName);
        Found_Child:=True;
        Break;
      end;
    end;


    // 親のパス
    if Has_Parent then
    begin
      for j:=0 to Length(rom_path)-1 do
      begin
        if (FileExists(JoinPath(rom_path[j], ParentName))) then
        begin
          ParentName:=JoinPath(rom_path[j], ParentName);
          Found_Parent:=True;
          Break;
        end;
      end;
    end;

    // ROM不明のとき
    if (not Found_Parent) and (not Found_Child) then
    begin
      Result := ROM_STATUS_MISSING;
      exit;
    end;

    // CRCチェック用
    ToBeChecked:=m1snd_get_info_int(M1_IINF_ROMNUM, RomNum);
    SetLength(CRC_Checked, ToBeChecked);

    // Zip開く
    // 子
    if Found_Child then
    begin
      Zip := TZipFile.Create;
      try
        try
          Zip.Open(RomName, zmRead);

          for j:=0 to Length(CRC_Checked)-1 do
          begin

            // CRCでのチェック
            CRC := m1snd_get_info_int(M1_IINF_ROMCRC, RomNum or (j shl 16));

            if ZipFindByCRC(Zip, Cardinal(CRC), ZipEntry) then
            begin
              CRC_Checked[j]:=True; // フラグ
              Dec(ToBeChecked,1);   // 残チェック数-1
            end;

            // CRCがゼロの場合ファイル名で探す
            if (CRC_Checked[j]=False) and (CRC=0) then
            begin
              // 対象ROM名
              St:=M1String(m1snd_get_info_str(M1_SINF_ROMFNAME, RomNum or (j shl 16)));
              if ZipFindByFileName(Zip, St, ZipEntry) then
              begin
                CRC_Checked[j]:=True; // フラグ
                Dec(ToBeChecked,1);   // 残チェック数-1
              end;
            end;

          end;

        except
        end;
      finally
        Zip.Free;
      end;
    end;

    // 残チェック
    if ToBeChecked = 0 then
    begin
      Result := ROM_STATUS_OK;
      exit;
    end
    else
    // 親チェック
    if Found_Parent then
    begin
      Zip := TZipFile.Create;
      try
        try
          Zip.Open(ParentName, zmRead);

          for j:=0 to Length(CRC_Checked)-1 do
          begin

            if CRC_Checked[j]=False then
            begin
              CRC := m1snd_get_info_int(M1_IINF_ROMCRC, RomNum or (j shl 16));

              if ZipFindByCRC(Zip, Cardinal(CRC), ZipEntry) then
              begin
                CRC_Checked[j]:=True; // フラグ
                Dec(ToBeChecked);     // 残チェック数-1
              end;

              // CRCがゼロの場合ファイル名で探す
              if (CRC_Checked[j]=False) and (CRC=0) then
              begin
                // 対象ROM名
                St:=M1String(m1snd_get_info_str(M1_SINF_ROMFNAME, RomNum or (j shl 16)));
                if ZipFindByFileName(Zip, St, ZipEntry) then
                begin
                  CRC_Checked[j]:=True; // フラグ
                  Dec(ToBeChecked,1);   // 残チェック数-1
                end;
              end;

            end;

          end;

        except
        end;
      finally
        Zip.Free;
      end;
    end;

    if ToBeChecked = 0 then
    begin
      Result := ROM_STATUS_OK;
    end
    else
    begin
      Result := ROM_STATUS_ERROR;
    end;

  end;

end;

procedure TForm5.BitBtn1Click(Sender: TObject);
begin
  Form5.Close;
end;

procedure TForm5.btnRescanClick(Sender: TObject);
begin
  ShowRomInfo(Target_RomNum);
end;


{
// リストビューのオーナードロー
procedure TForm5.ListView1DrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
var
  Rct :TRect;
  i   :Integer;
  uFormat : Integer;
  ST  : String;
begin

  with (Sender as TListView).Canvas do
  begin

    Inc(Rect.Left,2);
    Rct:=Rect;

    // 文字色
    if Item.SubItems[2]='Not found' then
      Font.Color := $a0a0a0
    else
    if pos('OK',Item.SubItems[2])<>0 then
    else
      Font.Color:=clRed;


    // 選択行
    if (odSelected in State) then
    begin
      if Sender.Focused then
      begin
        Brush.Color:=clHighLight;
        Font.Color :=clHighLightText;
      end
      else
        Brush.Color:=clInactiveBorder;
    end;
    FillRect(Rct);

    ListView_GetSubItemRect(Sender.Handle, Item.Index,0, LVIR_LABEL, @Rct);
    Inc(Rct.Left,3);
    Dec(Rct.Right,6);
    ST:=Item.Caption;
    uFormat:= DT_LEFT or DT_NOPREFIX or DT_END_ELLIPSIS;
    DrawText(Handle, PChar(ST), Length(ST), Rct, uFormat);

    for i:=0 to 2 do
    begin

      if ListView1.Columns[i+1].Alignment = taRightJustify then
        uFormat:=DT_RIGHT
      else
        uFormat:=DT_LEFT;

      uFormat:= uFormat or DT_NOPREFIX or DT_END_ELLIPSIS;

      ListView_GetSubItemRect(Sender.Handle, Item.Index,
                                i+1, LVIR_LABEL, @Rct);
      FillRect(Rct);

      Inc(Rct.Left,6);
      Dec(Rct.Right,6);
      ST:=Item.SubItems[i];
      DrawText(Handle, PChar(ST), Length(ST), Rct, uFormat);

    end;

  end;
  
end;
}
procedure TForm5.ListView1AdvancedCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage;
  var DefaultDraw: Boolean);
begin

  // 文字色
  if Item.SubItems[2]='Not found' then
    ListView1.Canvas.Font.Color := $a0a0a0
  else
  if pos('OK',Item.SubItems[2])<>0 then
  else
    ListView1.Canvas.Font.Color:=clRed;

end;

procedure TForm5.Copytoclipboard1Click(Sender: TObject);
var i: Integer;
var st: String;
begin

  st:='';
  
  for i:=0 to ListView1.Items.Count-1 do
  begin

    st:=st+ListView1.Items[i].Caption+#9+ListView1.Items[i].SubItems[0]+
           #9+ListView1.Items[i].SubItems[1]+#9+ListView1.Items[i].SubItems[2]+#13#10;

  end;

  Clipboard.AsText:=st;

end;

end.
