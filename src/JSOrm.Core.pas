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
    class function TestDBConnection : boolean;
  end;


implementation

uses
  System.SysUtils,
  JSOrm.Params,
  JSOrm.Connection,
  FireDAC.Comp.Client,
  System.Generics.Collections;

{ TJSOrm }

class procedure TJSOrm.Start(const pIniFileName, pIniSection: string);
begin
  if not FStarted then
  begin
    if not Assigned(JSOrm.Connection.FConnList) then
      JSOrm.Connection.FConnList := TObjectList<TFDConnection>.Create;
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
  if Assigned(JSOrm.Connection.FConnList) then
    JSOrm.Connection.FConnList.Free;
  FStarted := False;
end;

class function TJSOrm.TestDBConnection: boolean;
begin
  if not FStarted then
    raise Exception.Create('JSOrm is not started')
  else
    Result := True;
end;

initialization
  TJSOrm.FStarted := False;

end.
