unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImageButton3, StdCtrls;

type
  TForm1 = class(TForm)
    btnPlay: TImageButton;
    CheckBox1: TCheckBox;
    btnPrev: TImageButton;
    btnNext: TImageButton;
    btnPause: TImageButton;
    btnStop: TImageButton;
    btnLoad: TImageButton;
    btnRec: TImageButton;
    btnRepeat: TImageButton;
    btnList: TImageButton;
    btnMixer: TImageButton;
    procedure CheckBox1Click(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.CheckBox1Click(Sender: TObject);
begin

  ImageButton1.Enabled:=CheckBox1.Checked;
  ImageButton2.Enabled:=CheckBox1.Checked;
  ImageButton3.Enabled:=CheckBox1.Checked;
  ImageButton4.Enabled:=CheckBox1.Checked;
  ImageButton5.Enabled:=CheckBox1.Checked;
  ImageButton6.Enabled:=CheckBox1.Checked;
  ImageButton7.Enabled:=CheckBox1.Checked;

end;

end.
