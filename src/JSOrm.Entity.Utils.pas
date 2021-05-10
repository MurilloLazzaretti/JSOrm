unit JSOrm.Entity.Utils;

interface

uses
  JSON;

function ISOTimeStampToDateTime(const dateTime: string): TDateTime;
function ISODateToDate(const date: string): TDate;
function DateTimeToISOTimeStamp(const dateTime: TDateTime): string;
function DateToISODate(const date: TDateTime): string;
function VariantArrayToJSONArray(const pVariantArray : Variant) : TJSONArray;

implementation

uses
  System.SysUtils,
  System.Variants,
  System.DateUtils,
  System.Rtti;

function VariantArrayToJSONArray(const pVariantArray : Variant) : TJSONArray;
var
  Length : integer;
  I: Integer;
begin
  Result := TJSONArray.Create;
  Length := VarArrayHighBound(pVariantArray, 1);
  for I := 0 to Length -1 do
    Result.AddElement(TJSONString.Create(pVariantArray[i]));
end;

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
