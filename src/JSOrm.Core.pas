unit JSOrm.Core;

interface

type
  TJSOrm = class
  private
    class var FStarted : boolean;
  public
    class procedure Start(const pIniFileName, pIniSection : string);
    class procedure Stop;
    class function Started : boolean;
    class procedure SetPasswordDB(const pPassword: string);
    class procedure SetUserDB(const pUser: string);
    class procedure SetServerDB(const pServer: string);
    class procedure SetDriverDB(const pDriver: string);
    class function TestDBConnection : boolean;
  end;


implementation

uses
  System.SysUtils,
  JSOrm.Params,
  JSOrm.Connection,
  System.Generics.Collections,

  FireDAC.UI.Intf, FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Intf, FireDAC.Comp.UI, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef;

{ TJSOrm }

class procedure TJSOrm.SetDriverDB(const pDriver: string);
begin
  JSOrm.Params.ConnectionParams.Driver := pDriver;
end;

class procedure TJSOrm.SetPasswordDB(const pPassword: string);
begin
  JSOrm.Params.ConnectionParams.Password := pPassword;
end;

class procedure TJSOrm.SetServerDB(const pServer: string);
begin
  JSOrm.Params.ConnectionParams.Server := pServer;
end;

class procedure TJSOrm.SetUserDB(const pUser: string);
begin
  JSOrm.Params.ConnectionParams.User := pPassword;
end;

class procedure TJSOrm.Start(const pIniFileName, pIniSection: string);
begin
  if not FStarted then
  begin
    if not Assigned(JSOrm.Params.ConnectionParams) then
      JSOrm.Params.ConnectionParams := TJSOrmConnectionParams.Create(pIniFileName, pIniSection);
    FStarted := True;
  end;
end;

class function TJSOrm.Started: boolean;
begin
  Result := FStarted;
end;

class procedure TJSOrm.Stop;
begin
  if Assigned(JSOrm.Params.ConnectionParams) then
    JSOrm.Params.ConnectionParams.Free;
  FStarted := False;
end;

class function TJSOrm.TestDBConnection: boolean;
begin
  if not FStarted then
    raise Exception.Create('JSOrm is not started')
  else
    Result := True;
end;

// Inicialização das dependencias do FireDac

var
  FDGuixWaitCursor : TFDGuixWaitCursor;

initialization
  TJSOrm.FStarted := False;
  FDGuixWaitCursor := TFDGuixWaitCursor.Create(nil);
  FDGuixWaitCursor.Provider := 'Console';
  FDGuixWaitCursor.GetGUID;

finalization
  FDGuixWaitCursor.Free

end.
