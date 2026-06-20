unit EditDateTime;

interface

uses
  Classes, ComCtrls, SysUtils;

type
  TEditDateTimeMode = (edmDateTime, edmDate, edmTime);
  TEditDateTimeLoop = (edlAll, edlLoop);

  TEditDateTime = class(TDateTimePicker)
  private
    FFormatDate: string;
    FFormatTime: string;
    FLoop: TEditDateTimeLoop;
    FMax: TDateTime;
    FMin: TDateTime;
    FMode: TEditDateTimeMode;
    FMSecStep: Integer;
    function GetValue: TDateTime;
    procedure SetFormatDate(const Value: string);
    procedure SetFormatTime(const Value: string);
    procedure SetMode(const Value: TEditDateTimeMode);
    procedure SetValue(const Value: TDateTime);
    function DateTimePickerFormat(const Value: string): string;
    procedure UpdateDisplayFormat;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property FormatDate: string read FFormatDate write SetFormatDate;
    property FormatTime: string read FFormatTime write SetFormatTime;
    property Loop: TEditDateTimeLoop read FLoop write FLoop default edlAll;
    property Max: TDateTime read FMax write FMax;
    property Min: TDateTime read FMin write FMin;
    property Mode: TEditDateTimeMode read FMode write SetMode default edmDateTime;
    property MSecStep: Integer read FMSecStep write FMSecStep default 1;
    property Value: TDateTime read GetValue write SetValue;
  end;

implementation

constructor TEditDateTime.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLoop := edlAll;
  FMode := edmDateTime;
  FMSecStep := 1;
end;

function TEditDateTime.DateTimePickerFormat(const Value: string): string;
begin
  Result := StringReplace(Value, 'nn', 'mm', [rfReplaceAll, rfIgnoreCase]);
end;

function TEditDateTime.GetValue: TDateTime;
begin
  Result := DateTime;
end;

procedure TEditDateTime.SetFormatDate(const Value: string);
begin
  FFormatDate := Value;
  UpdateDisplayFormat;
end;

procedure TEditDateTime.SetFormatTime(const Value: string);
begin
  FFormatTime := Value;
  UpdateDisplayFormat;
end;

procedure TEditDateTime.SetMode(const Value: TEditDateTimeMode);
begin
  FMode := Value;
  UpdateDisplayFormat;
end;

procedure TEditDateTime.SetValue(const Value: TDateTime);
begin
  DateTime := Value;
end;

procedure TEditDateTime.UpdateDisplayFormat;
begin
  case FMode of
    edmDate:
      begin
        Kind := dtkDate;
        Format := DateTimePickerFormat(FFormatDate);
      end;
    edmTime:
      begin
        Kind := dtkTime;
        Format := DateTimePickerFormat(FFormatTime);
      end;
  else
    Kind := dtkDateTime;
    if (FFormatDate <> '') and (FFormatTime <> '') then
      Format := DateTimePickerFormat(FFormatDate + ' ' + FFormatTime)
    else if FFormatDate <> '' then
      Format := FFormatDate
    else
      Format := DateTimePickerFormat(FFormatTime);
  end;
end;

initialization
  RegisterClasses([TEditDateTime]);

end.
