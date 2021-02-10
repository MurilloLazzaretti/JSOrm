unit JSOrm.Dao;

interface

uses
  FireDAC.Comp.Client,
  FireDAC.DApt,
  Generics.Collections,
  JSOrm.Entity,
  System.JSON;

type
  TJSOrmDao<T : TJSOrmEntity> = class
  protected
    FIndexConn: integer;
    FQuery: TFDQuery;
  public
    function AsObject : T;
    function AsObjectList : TJSOrmEntityList<T>;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  JSOrm.Connection,
  JSOrm.Rtti;

{ TDaoBase }

function TJSOrmDao<T>.AsObject: T;
begin
  Result := TJSOrmRtti.ParseRecordDataSet<T>(FQuery);
end;

function TJSOrmDao<T>.AsObjectList: TJSOrmEntityList<T>;
begin
  Result := TJSOrmRtti.ParseDataSet<T>(FQuery);
end;

constructor TJSOrmDao<T>.Create;
begin
  FQuery := TFDQuery.Create(nil);
  FIndexConn := JSOrm.Connection.Connected;
  FQuery.Connection := JSOrm.Connection.FConnList.Items[FIndexConn];
end;

destructor TJSOrmDao<T>.Destroy;
begin
  FQuery.Free;
  JSOrm.Connection.Disconnected(FIndexConn);
  inherited;
end;

end.
