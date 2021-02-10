unit JSOrm.Entity.Utils;

interface

function ISOTimeStampToDateTime(const dateTime: string): TDateTime;
function ISODateToDate(const date: string): TDate;
function DateTimeToISOTimeStamp(const dateTime: TDateTime): string;
function DateToISODate(const date: TDateTime): string;

implementation

uses
  System.SysUtils,
  System.DateUtils;

function ISOTimeStampToDateTime(const dateTime: string): TDateTime;
begin
  Result := EncodeDateTime(StrToInt(Copy(dateTime, 1, 4)), StrToInt(Copy(dateTime, 6, 2)), StrToInt(Copy(dateTime, 9, 2)),
    StrToInt(Copy(dateTime, 12, 2)), StrToInt(Copy(dateTime, 15, 2)), StrToInt(Copy(dateTime, 18, 2)), 0);
end;

function ISODateToDate(const date: string): TDate;
begin
  Result := EncodeDate(StrToInt(Copy(date, 1, 4)), StrToInt(Copy(date, 6, 2)), StrToInt(Copy(date, 9, 2)));
end;

function DateTimeToISOTimeStamp(const dateTime: TDateTime): string;
var
  fs: TFormatSettings;
begin
  fs.TimeSeparator := ':';
  Result := FormatDateTime('yyyy-mm-dd hh:nn:ss', dateTime, fs);
end;

function DateToISODate(const date: TDateTime): string;
begin
  Result := FormatDateTime('YYYY-MM-DD', date);
end;

end.
