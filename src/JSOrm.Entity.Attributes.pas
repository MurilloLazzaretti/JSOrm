unit JSOrm.Entity.Attributes;

interface

uses
  JSOrm.Entity;

type
  TEntityFieldType = (tcString, tcInteger, tcFloat, tcDateTime, tcDate, tcObject, tcObjectList);

  TEntityFieldAttributes = class(TCustomAttribute)
  private
    FName: string;
    FType: TEntityFieldType;
    procedure SetFieldName(const Value: string);
    procedure SetFieldType(const Value: TEntityFieldType);
  public
    property _Name: string read FName write SetFieldName;
    property _Type: TEntityFieldType read FType write SetFieldType;
    constructor Create(const pName : string; const pType : TEntityFieldType); overload;
  end;

implementation

{ TEntityAttributes }

constructor TEntityFieldAttributes.Create(const pName : string;
  const pType : TEntityFieldType);
begin
  FName := pName;
  FType := pType;
end;

procedure TEntityFieldAttributes.SetFieldName(const Value: string);
begin
  FName := Value;
end;

procedure TEntityFieldAttributes.SetFieldType(const Value: TEntityFieldType);
begin
  FType := Value;
end;

end.
