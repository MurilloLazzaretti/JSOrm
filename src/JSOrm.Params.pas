unit JSOrm.Params;

interface

type
  TJSOrmConnectionParams = class
  private
    FDriver: string;
    FDataBase: string;
    FPassword: string;
    FUser: string;
    FServer: string;
    procedure SetDataBase(const Value: string);
    procedure SetDriver(const Value: string);
    procedure SetPassword(const Value: string);
    procedure SetServer(const Value: string);
    procedure SetUser(const Value: string);
    function Cript(const pValue : string) : string;
  public
    property Driver : string read FDriver write SetDriver;
    property Server : string read FServer write SetServer;
    property DataBase : string read FDataBase write SetDataBase;
    property User : string read FUser write SetUser;
    property Password : string read FPassword write SetPassword;
    constructor Create(const pIniFileName : string; const pIniSection : string);
  end;

  var ConnectionParams : TJSOrmConnectionParams;

implementation

uses
  System.SysUtils,
  Vcl.Forms,
  Windows,
  IniFiles;

{ TConnectionParams }

constructor TJSOrmConnectionParams.Create(const pIniFileName : string; const pIniSection : string);
var
  IniFile : TIniFile;
  DirWin : PChar;
  FileName : string;
begin
  FileName := ExtractFilePath(Application.ExeName) + pIniFileName;
  if not FileExists(FileName) then
  begin
    DirWin := PChar(StringofChar(' ', 255));
    GetWindowsDirectory(dirwin, 255);
    FileName := DirWin + pIniFileName + '\';
  end;
  if FileExists(FileName) then
  begin
    IniFile := TIniFile.Create(FileName);
    try
      Driver := IniFile.ReadString(pIniSection, 'DATABASE', 'MSSQL');
      Server := IniFile.ReadString(pIniSection, 'SERVERNAME', 'LOCALHOST/SQLEXPRESS');
      DataBase := IniFile.ReadString(pIniSection, 'DATABASENAME', '');
      User := Cript(IniFile.ReadString(pIniSection, 'USERNAME', 'sa'));
      Password := Cript(IniFile.ReadString(pIniSection, 'PASSWORD', ''));
    finally
      IniFile.Free;
    end;
  end
  else
    raise Exception.Create('Inifile not found');
end;

function TJSOrmConnectionParams.Cript(const pValue: string): string;
var
  i: integer;
begin
	Result := '';
  for i := 1 to length(pValue) do
  begin
    result := result + char(byte(11010) xor byte(pValue[i]));
  end;
end;

procedure TJSOrmConnectionParams.SetDataBase(const Value: string);
begin
  FDataBase := Value;
end;

procedure TJSOrmConnectionParams.SetDriver(const Value: string);
begin
  FDriver := Value;
end;

procedure TJSOrmConnectionParams.SetPassword(const Value: string);
begin
  FPassword := Value;
end;

procedure TJSOrmConnectionParams.SetServer(const Value: string);
begin
  FServer := Value;
end;

procedure TJSOrmConnectionParams.SetUser(const Value: string);
begin
  FUser := Value;
end;

end.
