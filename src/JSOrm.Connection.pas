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
  FireDAC.Phys,
  Data.DB,
  FireDAC.Comp.Client,
  Firedac.DApt,
  FireDAC.Phys.MSSQL,
  System.Generics.Collections;

var
  FConnList : TObjectList<TFDConnection>;

function Connected : Integer;
procedure Disconnected(Index : Integer);

implementation

uses
  System.SysUtils,
  JSOrm.Params;

function Connected : Integer;
begin
  if not Assigned(JSOrm.Params.ConnectionParams) then
    raise Exception.Create('JSorm was not started.')
  else
  begin
    FConnList.Add(TFDConnection.Create(nil));
    Result := Pred(FConnList.Count);
    FConnList.Items[Result].Params.Add('DriverID=' + JSOrm.Params.ConnectionParams.Driver);
    FConnList.Items[Result].Params.Add('Server=' + JSOrm.Params.ConnectionParams.Server);
    FConnList.Items[Result].Params.Add('Database=' + JSOrm.Params.ConnectionParams.DataBase);
    FConnList.Items[Result].Params.Add('User_Name=' + JSOrm.Params.ConnectionParams.User);
    FConnList.Items[Result].Params.Add('Password=' + JSOrm.Params.ConnectionParams.Password);
    FConnList.Items[Result].Connected;
  end;
end;

procedure Disconnected(Index : Integer);
begin
  FConnList.Items[Index].Connected := False;
  FConnList.Delete(Index);
  FConnList.TrimExcess;
end;

end.
