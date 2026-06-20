unit ImageScaling;

interface

uses
  Graphics;

procedure ScaleImageBicubicGDIPlus(ASource, ADest: TBitmap;
  NewWidth, NewHeight: Integer);

implementation

uses
  SysUtils, Winapi.GDIPAPI, Winapi.GDIPOBJ;

procedure ScaleImageBicubicGDIPlus(ASource, ADest: TBitmap;
  NewWidth, NewHeight: Integer);
var
  GPGraphic: TGPGraphics;
  GPBitmap: TGPBitmap;
begin
  if (ASource = nil) or (ADest = nil) then
    raise EArgumentNilException.Create('Source and destination bitmaps are required');
  if (NewWidth <= 0) or (NewHeight <= 0) then
    raise EArgumentOutOfRangeException.Create('Bitmap dimensions must be positive');

  ADest.PixelFormat := pf32bit;
  ADest.SetSize(NewWidth, NewHeight);

  GPGraphic := nil;
  GPBitmap := nil;
  try
    GPGraphic := TGPGraphics.Create(ADest.Canvas.Handle);
    GPBitmap := TGPBitmap.Create(ASource.Handle, ASource.Palette);
    GPGraphic.SetInterpolationMode(InterpolationModeHighQualityBicubic);
    GPGraphic.SetSmoothingMode(SmoothingModeHighQuality);
    GPGraphic.SetPixelOffsetMode(PixelOffsetModeHighQuality);
    GPGraphic.SetCompositingQuality(CompositingQualityHighQuality);
    GPGraphic.DrawImage(GPBitmap, 0, 0, NewWidth, NewHeight);
  finally
    GPBitmap.Free;
    GPGraphic.Free;
  end;
end;

end.
