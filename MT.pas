unit MT;

interface

uses
  Windows,SysUtils,Classes,M1;

type
  TIdleThread = class(TThread)
  private
    { Private éŒ¾ }
  protected
    procedure Execute; override;
  end;

implementation
uses Unit1, Common;

{ TMyThread }

procedure TIdleThread.Execute;
begin

  //IDLE‚Ì‘—M
  while not Terminated do
  begin

    if IdleOn then
    begin
      m1snd_run(M1_CMD_IDLE, 0);
      Sleep(IDLE_FREQ);
    end
    else
    begin
      Sleep(20);

    end;

  end;

end;

end.

