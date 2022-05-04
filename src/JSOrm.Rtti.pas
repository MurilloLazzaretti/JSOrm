unit JSOrm.Rtti;

interface

uses
  Rtti,
  Data.DB,
  Generics.Collections,
  JSOrm.Entity.Attributes,
  JSOrm.Entity,
  System.JSON;

type
  TJSOrmRtti = class
  private
    class function FindClassType(const ClassName : string) : TRttiType;
    class function FindClassTypeList(const ClassName : string) : TRttiType;
    class function ParseJsonObject(const pSource : TJSONObject; const pEntityClassName : string) : TJSOrmEntity; overload;
    class function ParseJsonArray(const pSource : TJSONArray; const pEntityClassName : string; const pOwnsObjects: boolean) : TJSOrmEntityList<TJSOrmEntity>; overload;
    class function ParseJsonArray(const pSource : TJSONArray; const pTypeArray : TEntityFieldType) : TArray<TValue>; overload;
  public
    class function New<T : TJSOrmEntity> : T; overload;
    class procedure CreateFieldsObject(const pEntity : TJSOrmEntity);
    class procedure DestroyFieldsObject(const pEntity : TJSOrmEntity);
    class function ParseJsonObject<T : class>(const pSource : TJSONObject) : T; overload;
    class function ParseJsonArray<T : TJSOrmEntity>(const pSource : TJSONArray) : TJSOrmEntityList<T>; overload;
    class function ParseDataSet<T : TJSOrmEntity>(const pSource : TDataSet; const pOwnsObjects : boolean) : TJSOrmEntityList<T>;
    class function ParseRecordDataSet<T : class>(const pSource : TDataSet) : T; overload;
    class function ToJsonObject(const pEntity : TJSOrmEntity): TJSONObject;
    class function ToJsonArray(const pEntity : TJSOrmEntityList<TJSOrmEntity>) : TJSONArray;
  end;
  
implementation

uses
  System.SysUtils,
  System.StrUtils,
  System.TypInfo,
  JSOrm.Entity.Utils;

{ TEntityRtti }

class procedure TJSOrmRtti.CreateFieldsObject(const pEntity: TJSOrmEntity);
var
  Context : TRttiContext;
  TypObj, TypProp : TRttiType;
  Attribute: TCustomAttribute;
  Prop: TRttiProperty;
  Meth : TRttiMethod;
begin
  Context := TRttiContext.Create;
  try
    TypObj := Context.GetType(pEntity.ClassInfo);
    for Prop in TypObj.GetProperties do
    begin
      for Attribute in Prop.GetAttributes do
      begin
        if TEntityFieldAttributes(Attribute)._Type = tcObject then
        begin
          TypProp := FindClassType(Prop.PropertyType.ToString);
          Meth := TypProp.GetMethod('Create');
          Prop.SetValue(pEntity, Meth.Invoke(TypProp.AsInstance.MetaclassType, [True]));
        end
        else if TEntityFieldAttributes(Attribute)._Type = tcObjectList then
        begin
          TypProp := FindClassType(Prop.PropertyType.ToString);
          Meth := TypProp.GetMethod('Create');
          Prop.SetValue(pEntity, Meth.Invoke(TypProp.AsInstance.MetaclassType, [True]));
        end;
      end;
    end;
  finally
    Context.Free;
  end;
end;

class procedure TJSOrmRtti.DestroyFieldsObject(const pEntity: TJSOrmEntity);
var
  TypObj: TRttiType;
  Prop: TRttiProperty;
  ObjList : TObjectList<TJSOrmEntity>;
  Obj : TJSOrmEntity;
  Context : TRttiContext;
begin
  Context := TRttiContext.Create;
  try
    TypObj := Context.GetType(pEntity.ClassInfo);
    for Prop in TypObj.GetProperties do
    begin
      if TEntityFieldAttributes(Prop.GetAttributes[0])._Type = tcObject then
      begin
        Obj := TJSOrmEntity(Prop.GetValue(pEntity).AsObject);
        if Assigned(Obj) then
          Obj.Free;
      end
      else if TEntityFieldAttributes(Prop.GetAttributes[0])._Type = tcObjectList then
      begin
        ObjList := TObjectList<TJSOrmEntity>(Prop.GetValue(pEntity).AsObject);
        if Assigned(ObjList) then
        begin
          ObjList.Clear;
          ObjList.Free;
        end;
      end;
    end;
  finally
    Context.Free;
  end;
end;

class function TJSOrmRtti.FindClassType(const ClassName: string): TRttiType;
var
  Context: TRttiContext;
  Typ: TRttiType;
  List: TArray<TRttiType>;
begin
  Result := nil;
  Context := TRttiContext.Create;
  try
    List := Context.GetTypes;
    for Typ in List do
    begin
      if Typ.IsInstance and (EndsText(ClassName, Typ.Name)) then
      begin
        Result := Typ;
        break;
      end;
    end;
  finally
    Context.Free;
  end;
end;

class function TJSOrmRtti.FindClassTypeList(
  const ClassName: string): TRttiType;
var
  Context: TRttiContext;
  ListClassName : string;
begin
  ListClassName := ClassName
                      .Replace('TJSOrmEntityList<', EmptyStr)
                      .Replace('>', EmptyStr);
  Context := TRttiContext.Create;
  try
    Result := Context.FindType(ListClassName);
  finally
    Context.Free;
  end;
end;

class function TJSOrmRtti.New<T>: T;
begin
  Result := T(GetTypeData(PTypeInfo(TypeInfo(T)))^.ClassType.Create);
end;

class function TJSOrmRtti.ParseDataSet<T>(const pSource: TDataSet; const pOwnsObjects : boolean): TJSOrmEntityList<T>;
var
  Context : TRttiContext;
  TypObj, TypProp: TRttiType;
  Prop: TRttiProperty;
  Attribute: TCustomAttribute;
  Entity : TJSOrmEntity;
  Meth: TRttiMethod;
begin
  Context := TRttiContext.Create;
  try
    TypObj := Context.GetType(T.ClassInfo);
    Result := TJSOrmEntityList<T>.Create(pOwnsObjects);
    while not pSource.Eof do
    begin
      Entity := T(GetTypeData(PTypeInfo(TypeInfo(T)))^.ClassType.Create);
      for Prop in TypObj.GetProperties do
      begin
        for Attribute in Prop.GetAttributes do
        begin
          case TEntityFieldAttributes(Attribute)._Type of
            tcString:
              if not pSource.FindField(TEntityFieldAttributes(Attribute)._Name).IsNull then
                Prop.SetValue(TObject(Entity), TValue.From<string>(pSource.FindField(TEntityFieldAttributes(Attribute)._Name).Value));
            tcInteger:
              if not pSource.FindField(TEntityFieldAttributes(Attribute)._Name).IsNull then
                Prop.SetValue(TObject(Entity), TValue.From<integer>(pSource.FindField(TEntityFieldAttributes(Attribute)._Name).Value));
            tcFloat:
              if not pSource.FindField(TEntityFieldAttributes(Attribute)._Name).IsNull then
                Prop.SetValue(TObject(Entity), TValue.From<double>(pSource.FindField(TEntityFieldAttributes(Attribute)._Name).Value));
            tcDateTime:
              if not pSource.FindField(TEntityFieldAttributes(Attribute)._Name).IsNull then
                Prop.SetValue(TObject(Entity), TValue.From<TDateTime>(pSource.FindField(TEntityFieldAttributes(Attribute)._Name).Value));
            tcDate:
              if not pSource.FindField(TEntityFieldAttributes(Attribute)._Name).IsNull then
                Prop.SetValue(TObject(Entity), TValue.From<TDate>(pSource.FindField(TEntityFieldAttributes(Attribute)._Name).Value));
            tcObject:
              if Prop.GetValue(TObject(Entity)).IsEmpty then
              begin
                TypProp := FindClassType(Prop.PropertyType.ToString);
                Meth := TypProp.GetMethod('Create');
                Prop.SetValue(TObject(Entity), Meth.Invoke(TypProp.AsInstance.MetaclassType, [True]));
              end;
            tcObjectList:
              if Prop.GetValue(TObject(Entity)).IsEmpty then
              begin
                TypProp := FindClassType(Prop.PropertyType.ToString);
                Meth := TypProp.GetMethod('Create');
                Prop.SetValue(TObject(Entity), Meth.Invoke(TypProp.AsInstance.MetaclassType, [True]));
              end;
          end;
        end;
      end;
      Result.Add(Entity);
      pSource.Next;
    end;
  finally
    Context.Free;
  end;
end;

class function TJSOrmRtti.ParseJsonArray(const pSource: TJSONArray;
  const pEntityClassName: string; const pOwnsObjects: boolean): TJSOrmEntityList<TJSOrmEntity>;
var
  TypResult, TypObj: TRttiType;
  Meth : TRttiMethod;
  Prop: TRttiProperty;
  I : integer;
  Entity : TObject;
begin
  TypResult := FindClassType(pEntityClassName);
  Meth := TypResult.GetMethod('Create');
  Result := TJSOrmEntityList<TJSOrmEntity>(Meth.Invoke(TypResult.AsInstance.MetaclassType, [pOwnsObjects]).AsObject);
  TypObj := FindClassTypeList(pEntityClassName);
  if pSource.Count > 0 then
  begin
    for I := 0 to Pred(pSource.Count) do
    begin
      Meth := TypObj.GetMethod('Create');
      Entity := Meth.Invoke(TypObj.AsInstance.MetaclassType, [False]).AsObject;
      Result.Add(TJSOrmEntity(Entity));
      for Prop in TypObj.GetProperties do
      begin
        if Assigned(TJSONObject(pSource.Items[i]).GetValue(Prop.Name)) then
        begin
          try
            case TEntityFieldAttributes(Prop.GetAttributes[0])._Type of
              tcString:
                Prop.SetValue(Entity, TValue.FromVariant(TJSONObject(pSource.Items[i]).GetValue(Prop.Name).Value));
              tcInteger:
                Prop.SetValue(Entity, TValue.FromVariant(StrToInt(TJSONObject(pSource.Items[i]).GetValue(Prop.Name).Value)));
              tcFloat:
                Prop.SetValue(Entity, TValue.FromVariant((TJSONObject(pSource.Items[i]).GetValue(Prop.Name) as TJSONNumber).AsDouble));
              tcDateTime:
                Prop.SetValue(Entity, TValue.FromVariant(ISOTimeStampToDateTime(TJSONObject(pSource.Items[i]).GetValue(Prop.Name).Value)));
              tcDate:
                Prop.SetValue(Entity, TValue.FromVariant(ISODateToDate(TJSONObject(pSource.Items[i]).GetValue(Prop.Name).Value)));
              tcArrayString:
                Prop.SetValue(Entity, TValue.FromArray(Prop.PropertyType.Handle, ParseJsonArray(TJSONObject(pSource.Items[i]).GetValue(Prop.Name) as TJSONArray, tcArrayString)));
              tcArrayInteger:
                Prop.SetValue(Entity, TValue.FromArray(Prop.PropertyType.Handle, ParseJsonArray(TJSONObject(pSource.Items[i]).GetValue(Prop.Name) as TJSONArray, tcArrayInteger)));
              tcArrayDouble:
                Prop.SetValue(Entity, TValue.FromArray(Prop.PropertyType.Handle, ParseJsonArray(TJSONObject(pSource.Items[i]).GetValue(Prop.Name) as TJSONArray, tcArrayDouble)));
              tcObject:
                Prop.SetValue(Entity, ParseJsonObject(TJSONObject(pSource.Items[i]).GetValue(Prop.Name) as TJSONObject, Prop.PropertyType.ToString));
              tcObjectList:
                Prop.SetValue(Entity, ParseJsonArray(TJSONObject(pSource.Items[i]).GetValue(Prop.Name) as TJSONArray, Prop.PropertyType.ToString, True));
            end;
          except
            FreeAndNil(Result);
            exit;
          end;
        end;
      end;
    end;
  end;
end;

class function TJSOrmRtti.ParseJsonArray(
  const pSource: TJSONArray; const pTypeArray : TEntityFieldType): TArray<TValue>;
var
  I: Integer;
begin
  SetLength(Result, pSource.Count);
  if pTypeArray = tcArrayString then
  begin
    for I := 0 to Pred(pSource.Count) do
    begin
      Result[i] := TValue.FromVariant(pSource.Items[i].Value);
    end;
  end
  else if pTypeArray = tcArrayInteger then
  begin
    for I := 0 to Pred(pSource.Count) do
    begin
      Result[i] := TValue.FromVariant(StrToInt(pSource.Items[i].Value));
    end;
  end
  else if pTypeArray = tcArrayDouble then
  begin
    for I := 0 to Pred(pSource.Count) do
    begin
      Result[i] := TValue.FromVariant(StrToFloat(pSource.Items[i].Value));
    end;
  end
  else
  begin
    raise Exception.Create('pTypeArray invalid');
  end;
end;

class function TJSOrmRtti.ParseJsonArray<T>(
  const pSource: TJSONArray): TJSOrmEntityList<T>;
var
  Context : TRttiContext;
  TypObj : TRttiType;
  Meth : TRttiMethod;
  Prop: TRttiProperty;
  I : integer;
  Entity : TObject;
begin
  if not Assigned(pSource) then
    Exit;
  Context := TRttiContext.Create;
  try
    TypObj := Context.GetType(T.ClassInfo);
    Result := TJSOrmEntityList<T>.Create;
    if pSource.Count > 0 then
    begin
      for I := 0 to Pred(pSource.Count) do
      begin
        Meth := TypObj.GetMethod('Create');
        Entity := Meth.Invoke(TypObj.AsInstance.MetaclassType, [False]).AsObject;
        Result.Add(TJSOrmEntity(Entity));
        for Prop in TypObj.GetProperties do
        begin
          if Assigned(TJSONObject(pSource.Items[i]).GetValue(Prop.Name)) then
          begin
            try
              case TEntityFieldAttributes(Prop.GetAttributes[0])._Type of
                tcString:
                  Prop.SetValue(Entity, TValue.FromVariant(TJSONObject(pSource.Items[i]).GetValue(Prop.Name).Value));
                tcInteger:
                  Prop.SetValue(Entity, TValue.FromVariant(StrToInt(TJSONObject(pSource.Items[i]).GetValue(Prop.Name).Value)));
                tcFloat:
                  Prop.SetValue(Entity, TValue.FromVariant((TJSONObject(pSource.Items[i]).GetValue(Prop.Name) as TJSONNumber).AsDouble));
                tcDateTime:
                  Prop.SetValue(Entity, TValue.FromVariant(ISOTimeStampToDateTime(TJSONObject(pSource.Items[i]).GetValue(Prop.Name).Value)));
                tcDate:
                  Prop.SetValue(Entity, TValue.FromVariant(ISODateToDate(TJSONObject(pSource.Items[i]).GetValue(Prop.Name).Value)));
                tcArrayString:
                  Prop.SetValue(Entity, TValue.FromArray(Prop.PropertyType.Handle, ParseJsonArray(TJSONObject(pSource.Items[i]).GetValue(Prop.Name) as TJSONArray, tcArrayString)));
                tcArrayInteger:
                  Prop.SetValue(Entity, TValue.FromArray(Prop.PropertyType.Handle, ParseJsonArray(TJSONObject(pSource.Items[i]).GetValue(Prop.Name) as TJSONArray, tcArrayInteger)));
                tcArrayDouble:
                  Prop.SetValue(Entity, TValue.FromArray(Prop.PropertyType.Handle, ParseJsonArray(TJSONObject(pSource.Items[i]).GetValue(Prop.Name) as TJSONArray, tcArrayDouble)));
                tcObject:
                  Prop.SetValue(Entity, ParseJsonObject(TJSONObject(pSource.Items[i]).GetValue(Prop.Name) as TJSONObject, Prop.PropertyType.ToString));
                tcObjectList:
                  Prop.SetValue(Entity, ParseJsonArray(TJSONObject(pSource.Items[i]).GetValue(Prop.Name) as TJSONArray, Prop.PropertyType.ToString, True));
              end;
            except
              FreeAndNil(Result);
              exit;
            end;
          end;
        end;
      end;
    end;
  finally
    Context.Free;
  end;
end;

class function TJSOrmRtti.ParseJsonObject(const pSource: TJSONObject;
  const pEntityClassName: string): TJSOrmEntity;
var
  TypObj : TRttiType;
  Meth : TRttiMethod;
  Prop: TRttiProperty;
begin
  TypObj := FindClassType(pEntityClassName);
  Meth := TypObj.GetMethod('Create');
  Result := TJSOrmEntity(Meth.Invoke(TypObj.AsInstance.MetaclassType, []).AsObject);
  for Prop in TypObj.GetProperties do
  begin
    if Assigned(pSource.GetValue(Prop.Name)) then
    begin
      try
        case TEntityFieldAttributes(Prop.GetAttributes[0])._Type of
          tcString:
            Prop.SetValue(TObject(Result), TValue.FromVariant(pSource.GetValue(Prop.Name).Value));
          tcInteger:
            Prop.SetValue(TObject(Result), TValue.FromVariant(StrToInt(pSource.GetValue(Prop.Name).Value)));
          tcFloat:
            Prop.SetValue(TObject(Result), TValue.FromVariant((pSource.GetValue(Prop.Name) as TJSONNumber).AsDouble));
          tcDateTime:
            Prop.SetValue(TObject(Result), TValue.FromVariant(ISOTimeStampToDateTime(pSource.GetValue(Prop.Name).Value)));
          tcDate:
            Prop.SetValue(TObject(Result), TValue.FromVariant(ISODateToDate(pSource.GetValue(Prop.Name).Value)));
          tcArrayString:
            Prop.SetValue(TObject(Result), TValue.FromArray(Prop.PropertyType.Handle, ParseJsonArray(pSource.GetValue(Prop.Name) as TJSONArray, tcArrayString)));
          tcArrayInteger:
            Prop.SetValue(TObject(Result), TValue.FromArray(Prop.PropertyType.Handle, ParseJsonArray(pSource.GetValue(Prop.Name) as TJSONArray, tcArrayInteger)));
          tcArrayDouble:
            Prop.SetValue(TObject(Result), TValue.FromArray(Prop.PropertyType.Handle, ParseJsonArray(pSource.GetValue(Prop.Name) as TJSONArray, tcArrayDouble)));
          tcObject:
            Prop.SetValue(TObject(Result), ParseJsonObject(pSource.GetValue(Prop.Name) as TJSONObject, Prop.PropertyType.ToString));
          tcObjectList:
            Prop.SetValue(TObject(Result), ParseJsonArray(pSource.GetValue(Prop.Name) as TJSONArray, Prop.PropertyType.ToString, True));
        end;
      except
        FreeAndNil(Result);
        exit;
      end;
    end;
  end;
end;

class function TJSOrmRtti.ParseJsonObject<T>(const pSource : TJSONObject) : T;
var
  Context : TRttiContext;
  TypObj, TypProp: TRttiType;
  Prop: TRttiProperty;
begin
  if not Assigned(pSource) then
    Exit;
  Context := TRttiContext.Create;
  try
    TypObj := Context.GetType(T.ClassInfo);
    Result := T(GetTypeData(PTypeInfo(TypeInfo(T)))^.ClassType.Create);
    for Prop in TypObj.GetProperties do
    begin
      if Assigned(pSource.GetValue(Prop.Name)) then
      begin
        try
          case TEntityFieldAttributes(Prop.GetAttributes[0])._Type of
            tcString:
              Prop.SetValue(TObject(Result), TValue.FromVariant(pSource.GetValue(Prop.Name).Value));
            tcInteger:
              Prop.SetValue(TObject(Result), TValue.FromVariant(StrToInt(pSource.GetValue(Prop.Name).Value)));
            tcFloat:
              Prop.SetValue(TObject(Result), TValue.FromVariant((pSource.GetValue(Prop.Name) as TJSONNumber).AsDouble));
            tcDateTime:
              Prop.SetValue(TObject(Result), TValue.FromVariant(ISOTimeStampToDateTime(pSource.GetValue(Prop.Name).Value)));
            tcDate:
              Prop.SetValue(TObject(Result), TValue.FromVariant(ISODateToDate(pSource.GetValue(Prop.Name).Value)));
            tcArrayString:
              Prop.SetValue(TObject(Result), TValue.FromArray(Prop.PropertyType.Handle, ParseJsonArray(pSource.GetValue(Prop.Name) as TJSONArray, tcArrayString)));
            tcArrayInteger:
              Prop.SetValue(TObject(Result), TValue.FromArray(Prop.PropertyType.Handle, ParseJsonArray(pSource.GetValue(Prop.Name) as TJSONArray, tcArrayInteger)));
            tcArrayDouble:
              Prop.SetValue(TObject(Result), TValue.FromArray(Prop.PropertyType.Handle, ParseJsonArray(pSource.GetValue(Prop.Name) as TJSONArray, tcArrayDouble)));
            tcObject:
              Prop.SetValue(TObject(Result), ParseJsonObject(pSource.GetValue(Prop.Name) as TJSONObject, Prop.PropertyType.ToString));
            tcObjectList:
              Prop.SetValue(TObject(Result), ParseJsonArray(pSource.GetValue(Prop.Name) as TJSONArray, Prop.PropertyType.ToString, True));
          end;
        except
          FreeAndNil(Result);
          exit;
        end;
      end;
    end;
  finally
    Context.Free;
  end;
end;

class function TJSOrmRtti.ParseRecordDataSet<T>(const pSource: TDataSet): T;
var
  Context : TRttiContext;
  TypObj, TypProp: TRttiType;
  Prop: TRttiProperty;
  Meth : TRttiMethod;
begin
  Context := TRttiContext.Create;
  try
    TypObj := Context.GetType(T.ClassInfo);
    if pSource.RecordCount > 0 then
    begin
      Result := T(GetTypeData(PTypeInfo(TypeInfo(T)))^.ClassType.Create);
      for Prop in TypObj.GetProperties do
      begin
        case TEntityFieldAttributes(Prop.GetAttributes[0])._Type of
          tcString:
            if not pSource.FindField(TEntityFieldAttributes(Prop.GetAttributes[0])._Name).IsNull then
              Prop.SetValue(TObject(Result), TValue.From<string>(pSource.FindField(TEntityFieldAttributes(Prop.GetAttributes[0])._Name).Value));
          tcInteger:
            if not pSource.FindField(TEntityFieldAttributes(Prop.GetAttributes[0])._Name).IsNull then
              Prop.SetValue(TObject(Result), TValue.From<integer>(pSource.FindField(TEntityFieldAttributes(Prop.GetAttributes[0])._Name).Value));
          tcFloat:
            if not pSource.FindField(TEntityFieldAttributes(Prop.GetAttributes[0])._Name).IsNull then
              Prop.SetValue(TObject(Result), TValue.From<double>(pSource.FindField(TEntityFieldAttributes(Prop.GetAttributes[0])._Name).Value));
          tcDateTime:
            if not pSource.FindField(TEntityFieldAttributes(Prop.GetAttributes[0])._Name).IsNull then
              Prop.SetValue(TObject(Result), TValue.From<TDateTime>(pSource.FindField(TEntityFieldAttributes(Prop.GetAttributes[0])._Name).Value));
          tcDate:
            if not pSource.FindField(TEntityFieldAttributes(Prop.GetAttributes[0])._Name).IsNull then
              Prop.SetValue(TObject(Result), TValue.From<TDate>(pSource.FindField(TEntityFieldAttributes(Prop.GetAttributes[0])._Name).Value));
          tcObject:
            if Prop.GetValue(TObject(Result)).IsEmpty then
            begin
              TypProp := FindClassType(Prop.PropertyType.ToString);
              Meth := TypProp.GetMethod('Create');
              Prop.SetValue(TObject(Result), Meth.Invoke(TypProp.AsInstance.MetaclassType, []));
            end;
          tcObjectList:
            if Prop.GetValue(TObject(Result)).IsEmpty then
            begin
              TypProp := FindClassType(Prop.PropertyType.ToString);
              Meth := TypProp.GetMethod('Create');
              Prop.SetValue(TObject(Result), Meth.Invoke(TypProp.AsInstance.MetaclassType, [True]));
            end;
        end;
      end;
    end
    else Result := nil;
  finally
    Context.Free;
  end;
end;

class function TJSOrmRtti.ToJsonArray(
  const pEntity : TJSOrmEntityList<TJSOrmEntity>): TJSONArray;
var
  I : integer;
begin
  Result := TJSONArray.Create;
  for I := 0 to Pred(pEntity.Count) do
    Result.AddElement(ToJsonObject(pEntity[i]));
end;

class function TJSOrmRtti.ToJsonObject(const pEntity : TJSOrmEntity): TJSONObject;
var
  Context : TRttiContext;
  TypObj: TRttiType;
  Prop: TRttiProperty;
begin
  Context := TRttiContext.Create;
  try
    Result := TJSONObject.Create;
    TypObj := Context.GetType(pEntity.ClassInfo);
    for Prop in TypObj.GetProperties do
    begin
      if TEntityFieldAttributes(Prop.GetAttributes[0])._ExportToJson then
      begin
        case TEntityFieldAttributes(Prop.GetAttributes[0])._Type of
          tcString:
            Result.AddPair(Prop.Name, TJSONString.Create(Prop.GetValue(pEntity).AsString));
          tcInteger:
            Result.AddPair(Prop.Name, TJSONNumber.Create(Prop.GetValue(pEntity).AsInteger));
          tcFloat:
            Result.AddPair(Prop.Name, TJSONNumber.Create(Prop.GetValue(pEntity).AsVariant));
          tcDateTime:
            Result.AddPair(Prop.Name, TJSONString.Create(DateTimeToISOTimeStamp(Prop.GetValue(pEntity).AsVariant)));
          tcDate:
            Result.AddPair(Prop.Name, TJSONString.Create(DateToISODate(Prop.GetValue(pEntity).AsVariant)));
          tcArrayString:
            Result.AddPair(Prop.Name, ArrayToJSONArray(Prop.GetValue(pEntity).AsType<TArray<string>>));
          tcArrayInteger:
            Result.AddPair(Prop.Name, ArrayToJSONArray(Prop.GetValue(pEntity).AsType<TArray<integer>>));
          tcArrayDouble:
            Result.AddPair(Prop.Name, ArrayToJSONArray(Prop.GetValue(pEntity).AsType<TArray<double>>));
          tcObject:
            Result.AddPair(Prop.Name, TJSOrmEntity(Prop.GetValue(pEntity).AsObject).ToJsonObject);
          tcObjectList:
            Result.AddPair(Prop.Name, TJSOrmEntityList<TJSOrmEntity>(Prop.GetValue(pEntity).AsObject).ToJsonArray);
        end;
      end;
    end;
  finally
    Context.Free;
  end;
end;

end.
