unit JSOrm.Entity.Utils;

interface

uses
  JSON;

function ISOTimeStampToDateTime(const dateTime: string): TDateTime;
function ISODateToDate(const date: string): TDate;
function DateTimeToISOTimeStamp(const dateTime: TDateTime): string;
function DateToISODate(const date: TDateTime): string;
function ArrayToJSONArray(const pArray : TArray<string>) : TJSONArray; overload;
function ArrayToJSONArray(const pArray : TArray<integer>) : TJSONArray; overload;
function ArrayToJSONArray(const pArray : TArray<double>) : TJSONArray; overload;

implementation

uses
  System.SysUtils,
  System.Variants,
  System.DateUtils,
  System.Rtti;

function ArrayToJSONArray(const pArray : TArray<integer>) : TJSONArray; overload;
var
  I: Integer;
begin
  Result := TJSONArray.Create;
  for I := 0 to Length(pArray) -1 do
    Result.AddElement(TJSONNumber.Create(pArray[i]));
end;

function ArrayToJSONArray(const pArray : TArray<string>) : TJSONArray; overload;
var
  I: Integer;
begin
  Result := TJSONArray.Create;
  for I := 0 to Length(pArray) -1 do
    Result.AddElement(TJSONString.Create(pArray[i]));
end;

function ArrayToJSONArray(const pArray : TArray<double>) : TJSONArray; overload;
var
  I: Integer;
begin
  Result := TJSONArray.Create;
  for I := 0 to Length(pArray) -1 do
    Result.AddElement(TJSONNumber.Create(pArray[i]));
end;

function ISOTimeStampToDateTime(const dateTime: string): TDateTime;
begin
  if dateTime <> '' then
  begin
    Result := EncodeDateTime(StrToInt(Copy(dateTime, 1, 4)),
      StrToInt(Copy(dateTime, 6, 2)), StrToInt(Copy(dateTime, 9, 2)),
      StrToInt(Copy(dateTime, 12, 2)), StrToInt(Copy(dateTime, 15, 2)),
      StrToInt(Copy(dateTime, 18, 2)), 0);
  end
  else
    Result := 0;
end;

function ISODateToDate(const date: string): TDate;
begin
  if date <> '' then
  begin
    Result := EncodeDate(StrToInt(Copy(date, 1, 4)),
      StrToInt(Copy(date, 6, 2)), StrToInt(Copy(date, 9, 2)));
  end
  else
    Result := 0;
end;

function DateTimeToISOTimeStamp(const dateTime: TDateTime): string;
var
  fs: TFormatSettings;
begin
  fs.TimeSeparator := ':';
  if dateTime > 0 then
  begin
    Result := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', dateTime, fs);
    Result := Result.Replace(' ', 'T', [rfReplaceAll]);
  end
  else
    Result := '';
end;

function DateToISODate(const date: TDateTime): string;
begin
  if date > 0 then
  begin
    Result := FormatDateTime('YYYY-MM-DD', date);
  end
  else
    Result := '';
end;

end.
