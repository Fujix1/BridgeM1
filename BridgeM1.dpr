program BridgeM1;

uses
  Forms,
  Windows,
  SysUtils,
  Dialogs,
  Messages,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Form2},
  Unit3 in 'Unit3.pas' {Form3},
  Unit4 in 'Unit4.pas' {Form4},
  Unit5 in 'Unit5.pas' {Form5},
  Unit6 in 'Unit6.pas' {Form6},
  Common in 'Common.pas',
  MT in 'MT.pas',
  M1 in 'M1.pas';

{$R *.res}
{$R manifest.res}

var
  hMutex: THandle;
  Wnd, AppWnd: HWnd;
  W: HWnd;
  F1: TextFile;
  St: String;
begin

  // Disable all fpu exceptions
  //Saved8087CW := Default8087CW;
  //Set8087CW($133F);

  MultiInstance := False;
  
  // 二重起動設定読み込み
  if FileExists(JoinPath(ExtractFilePath(Application.ExeName), 'bridge.ini')) then
  begin

    AssignFile(F1, JoinPath(ExtractFilePath(Application.ExeName), 'bridge.ini'));
    try
      Reset(F1);
      while not Eof(F1) do
      begin
        ReadLn(F1,St);

        if Copy(St,1,Length('ALLOW_MULTI_INSTANCE'))='ALLOW_MULTI_INSTANCE' then
        begin
          MultiInstance:=(pos('ON',St)<>0);
          break;
        end;
      end;

    finally
      Close(F1);
    end;
  end;

  // 二重起動防止
  if MultiInstance = False then
  begin
    hMutex := OpenMutex(MUTEX_ALL_ACCESS, False, APPNAME);
    if hMutex <> 0 then // 既に実行されている
    begin

      Wnd := FindWindow('TForm1', APPNAME);
      if Wnd <> 0 then // 見つかった！
      begin

        // ロードウィンドウ表示中?
        W:=FindWindow('TForm3',nil);
        if (W<>0) and (IsWindowVisible(W)) then
          Wnd := W;

        // オプションウィンドウ表示中?
        W:=FindWindow('TForm4',nil);
        if (W<>0) and (IsWindowVisible(W)) then
          Wnd := W;

        // Auditウィンドウ表示中?
        W:=FindWindow('TForm5',nil);
        if (W<>0) and (IsWindowVisible(W)) then
          Wnd := W;

        //
        SetForegroundWindow(Wnd); // 前面に移動してアクティブ化

        // TApplication のウィンドウハンドルを取得
        AppWnd := GetWindowLong(Wnd, GWL_HWNDPARENT);
        if AppWnd <> 0 then Wnd := AppWnd;
        if IsIconic(Wnd) then // アイコン状態なら元に戻す
          SendMessage(AppWnd, WM_SYSCOMMAND, SC_RESTORE, -1);

      end;
      //ミューテックスを閉じる
      CloseHandle(hMutex);
      exit;
    end;
  end;

  //ミューテックスを作成
    hMutex := CreateMutex(nil, False, APPNAME);
  // 二重起動防止ここまで

  Application.Initialize;
  Application.Title := 'BridgeM1';

  booting:=True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm5, Form5);
  Application.CreateForm(TForm6, Form6);
  booting:=False;

  Application.Run;

  //Set8087CW(Saved8087CW);

  ReleaseMutex(hMutex);
  CloseHandle(hMutex);


end.

