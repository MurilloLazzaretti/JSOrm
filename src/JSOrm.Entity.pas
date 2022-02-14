unit JSOrm.Entity;

interface

uses
  Generics.Collections,
  System.JSON;

type
  TJSOrmEntity = class
  private
    procedure CreateFieldsObject;
    procedure DestroyFieldsObject;
  public
    function ToJsonObject : TJSONObject;
    class function New<T : TJSOrmEntity>(const pJsonObject : TJSONObject) : T; overload;
    class function New<T : TJSOrmEntity> : T; overload;
    constructor Create(const pCreateFieldsObject : boolean = True); overload;
    destructor Destroy; override;
  end;

  TJSOrmEntityList<T : TJSOrmEntity> = class(TObjectList<T>)
  public
    class function New(const pJsonObject : TJSONArray) : TJSOrmEntityList<T>; overload;
    function ToJsonArray : TJSONArray;
  end;

implementation

uses
  JSOrm.Rtti;

{ TJSOrmEntityBase }

constructor TJSOrmEntity.Create(const pCreateFieldsObject : boolean);
begin
  if pCreateFieldsObject then
    CreateFieldsObject;
end;

procedure TJSOrmEntity.CreateFieldsObject;
begin
  TJSOrmRtti.CreateFieldsObject(Self);
end;

destructor TJSOrmEntity.Destroy;
begin
  DestroyFieldsObject;
  inherited;
end;

procedure TJSOrmEntity.DestroyFieldsObject;
begin
  TJSOrmRtti.DestroyFieldsObject(Self);
end;

class function TJSOrmEntity.New<T>: T;
begin
  Result := TJSOrmRtti.New<T>;
end;

class function TJSOrmEntity.New<T>(const pJsonObject: TJSONObject): T;
begin
  Result := TJSOrmRtti.ParseJsonObject<T>(pJsonObject);
end;

function TJSOrmEntity.ToJsonObject: TJSONObject;
begin
  Result := TJSOrmRtti.ToJsonObject(Self);
end;

{ TJSOrmEntityList<T> }

class function TJSOrmEntityList<T>.New(
  const pJsonObject: TJSONArray): TJSOrmEntityList<T>;
begin
  Result := TJSOrmRtti.ParseJsonArray<T>(pJsonObject);
end;

function TJSOrmEntityList<T>.ToJsonArray: TJSONArray;
begin
  Result := TJSOrmRtti.ToJsonArray(TJSOrmEntityList<TJSOrmEntity>(Self));
end;

end.
