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
    function GetDllDirectory: string;
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
  {$IFDEF HORSE_ISAPI}
    FileName := ExtractFilePath(GetDllDirectory) + pIniFileName;
  {$ELSE}
    FileName := ExtractFilePath(Application.ExeName) + pIniFileName;
  {$ENDIF}
  if FileExists(FileName) then
  begin
    IniFile := TIniFile.Create(FileName);
    try
      Driver := IniFile.ReadString(pIniSection, 'DATABASE', 'MSSQL');
      Server := IniFile.ReadString(pIniSection, 'SERVERNAME', 'LOCALHOST/SQLEXPRESS');
      DataBase := IniFile.ReadString(pIniSection, 'DATABASENAME', '');
      User := IniFile.ReadString(pIniSection, 'USERNAME', '');
      Password := IniFile.ReadString(pIniSection, 'PASSWORD', '');
    finally
      IniFile.Free;
    end;
  end
end;

function TJSOrmConnectionParams.GetDllDirectory: string;
var
  pName: PChar;
begin
  GetMem(pName, 200);
  windows.GetModuleFileName(HInstance, pName, 200);
  Result := string(pName);
  Result := Copy(Result , Pos(':', Result) - 1, Length(Result));
  FreeMem(pName);
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
