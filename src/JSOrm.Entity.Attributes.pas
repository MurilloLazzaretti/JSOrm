unit JSOrm.Entity.Attributes;

interface

uses
  JSOrm.Entity;

type
  TEntityFieldType = (tcString, tcInteger, tcFloat, tcDateTime, tcDate,
    tcArrayString, tcArrayInteger, tcArrayDouble, tcObject, tcObjectList);

  TEntityFieldAttributes = class(TCustomAttribute)
  private
    FName: string;
    FType: TEntityFieldType;
    FExportToJson: boolean;
    procedure SetFieldName(const Value: string);
    procedure SetFieldType(const Value: TEntityFieldType);
    procedure SetExportToJson(const Value: boolean);
  public
    property _Name: string read FName write SetFieldName;
    property _Type: TEntityFieldType read FType write SetFieldType;
    property _ExportToJson : boolean read FExportToJson write SetExportToJson;
    constructor Create(const pName : string; const pType : TEntityFieldType;
      const pExportToJson: boolean = true); overload;
  end;

implementation

{ TEntityAttributes }

constructor TEntityFieldAttributes.Create(const pName : string;
  const pType : TEntityFieldType; const pExportToJson: boolean = true);
begin
  FName := pName;
  FType := pType;
  FExportToJson := pExportToJson;
end;

procedure TEntityFieldAttributes.SetFieldName(const Value: string);
begin
  FName := Value;
end;

procedure TEntityFieldAttributes.SetFieldType(const Value: TEntityFieldType);
begin
  FType := Value;
end;

procedure TEntityFieldAttributes.SetExportToJson(const Value: boolean);
begin
  FExportToJson := Value;
end;

end.
