unit JSOrm.Connection;

interface

uses
  System.JSON,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Stan.Param,
  FireDAC.Stan.StorageBin,
  FireDAC.Phys,
  Data.DB,
  FireDAC.Comp.Client,
  Firedac.DApt,
  FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef,
  FireDAC.Comp.UI,
  System.Generics.Collections;


function Connected : TFDConnection;

implementation

uses
  System.SysUtils,
  JSOrm.Params,
  FireDAC.ConsoleUI.Wait;

function Connected : TFDConnection;
begin
  if not Assigned(JSOrm.Params.ConnectionParams) then
    raise Exception.Create('JSorm was not started.')
  else
  begin
    Result := TFDConnection.Create(nil);
    Result.Params.Add('DriverID=' + JSOrm.Params.ConnectionParams.Driver);
    Result.Params.Add('Server=' + JSOrm.Params.ConnectionParams.Server);
    Result.Params.Add('Database=' + JSOrm.Params.ConnectionParams.DataBase);
    Result.Params.Add('User_Name=' + JSOrm.Params.ConnectionParams.User);
    Result.Params.Add('Password=' + JSOrm.Params.ConnectionParams.Password);
    Result.Connected := True;
  end;
end;

end.
