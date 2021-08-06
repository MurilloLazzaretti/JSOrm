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
    FDbConn : TFDConnection;
    FIndexConn: integer;
    FQuery: TFDQuery;
  public
    function AsObject : T;
    function AsObjectList(const pOwnsObjects: boolean = true) : TJSOrmEntityList<T>;
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

function TJSOrmDao<T>.AsObjectList(const pOwnsObjects: boolean = true): TJSOrmEntityList<T>;
begin
  Result := TJSOrmRtti.ParseDataSet<T>(FQuery, pOwnsObjects);
end;

constructor TJSOrmDao<T>.Create;
begin
  FQuery := TFDQuery.Create(nil);
  FDbConn := JSOrm.Connection.Connected;
  FQuery.Connection := FDbConn;
end;

destructor TJSOrmDao<T>.Destroy;
begin
  FQuery.Free;
  FDbConn.Connected := False;
  FDbConn.Free;
  inherited;
end;

end.
