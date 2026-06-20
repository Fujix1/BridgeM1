unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ExtCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    btnPlay: TSpeedButton;
    btnNext: TSpeedButton;
    btnPrev: TSpeedButton;
    btnPause: TSpeedButton;
    btnStop: TSpeedButton;
    CheckBox1: TCheckBox;
    btnLoad: TSpeedButton;
    btnRec: TSpeedButton;
    Image10: TImage;
    pbVolume: TPaintBox;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Image20: TImage;
    procedure CheckBox1Click(Sender: TObject);
    procedure pbVolumeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbVolumeMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Button1Click(Sender: TObject);
    procedure pbVolumePaint(Sender: TObject);
  private
    { Private êÈåæ }
    VolPoint : TPoint;
    VolRect  : TRect;
    KnobRect : TRect;
    Volume   : Integer;
    procedure DrawVolume();
  public
    { Public êÈåæ }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.CheckBox1Click(Sender: TObject);
begin

  btnPrev.Enabled:=CheckBox1.Checked;
  btnPlay.Enabled:=CheckBox1.Checked;
  btnPause.Enabled:=CheckBox1.Checked;
  btnStop.Enabled:=CheckBox1.Checked;
  btnNext.Enabled:=CheckBox1.Checked;
  btnRec.Enabled:=CheckBox1.Checked;
  btnLoad.Enabled:=CheckBox1.Checked;
end;

procedure TForm1.pbVolumeMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  if (X<VolRect.Right) and (X>VolRect.Left) then
  begin
    VolPoint.X:=X-VolRect.Left;
  end
  else
    VolPoint.X:=5;

  VolRect.Left:=X-VolPoint.X;
  VolRect.Right:=VolRect.Left+10;

  DrawVolume();
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
    if VolRect.Left>60 then
    begin
      VolRect.Left:=60;
    end;

    VolRect.Right:=VolRect.Left+10;
    Volume:=VolRect.Left;

    DrawVolume();

  end;

end;

procedure TForm1.Button1Click(Sender: TObject);
begin

  // init
  VolRect:=Rect(0,0,10,19);
  KnobRect:=Rect(0,0,Image10.Width,Image10.Height);
  DrawVolume();
  
end;

procedure TForm1.DrawVolume();
var Buffer : TBitMap;
var Rct    : TRect;
begin

  Buffer := TBitMap.Create;
  Buffer.PixelFormat := pf24bit;
  Buffer.Width:=pbVolume.Width;
  Buffer.Height:=pbVolume.Height;
  Buffer.Canvas.Brush:=Form1.Canvas.Brush;
  Rct:=pbVolume.Canvas.ClipRect;

  Image20.Canvas.Lock;
  Image10.Canvas.Lock;

  Buffer.Canvas.FillRect(Rct);
  Buffer.Canvas.CopyRect(Rect(0,7,Image20.Width,7+Image20.Height),
                            Image20.Canvas,Image20.Canvas.ClipRect);
  Buffer.Canvas.CopyRect(VolRect,Image10.Canvas,KnobRect);
  Image20.Canvas.UnLock;
  Image10.Canvas.UnLock;

  pbVolume.Canvas.Lock;
  pbVolume.Canvas.CopyRect(Rct,Buffer.Canvas,Rct);
  pbVolume.Canvas.Unlock;

  Buffer.Free;
end;

procedure TForm1.pbVolumePaint(Sender: TObject);
begin
  DrawVolume;
end;

end.
