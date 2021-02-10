## JSOrm

<p align="center">
  <b>JSOrm</b> is a framework for manipulating relational objects that can be provided by a data base connection (MSSSQL for now) and export / import to a <b>JSON<b> format.
</p><br>

## ⚙️ Installation

Installation is done using the [`boss install`](https://github.com/HashLoad/boss) command:
``` sh
$ boss install https://github.com/MurilloLazzaretti/jsorm.git
```
## ⚡️ First step

You need to <b>start</b> JSOrm providing "ini file name" and "section name" that contains informations about your database connection:
```delphi
uses JSOrm.Core;

begin  
  TJSOrm.Start('Your iniFileName', 'Your IniSectionName');    
end;

```
## 📐 IniFile template

Note: The ini file needs to be under your application`s path or in Windows Directory (Ex: "C:\Windows\iniFile.ini")

```iniFile
[SECTIONNAME]
DATABASE=MSSQL
SERVERNAME= Your database server (Ex: "localhost\SQLEXPRESS")
DATABASENAME= Your database name
USERNAME= Database username
PASSWORD= Database password
```

## ⚡️ Don`t forget

When you will terminate your application, dont`t forget to <b>stop</b> JSOrm
```delphi
uses JSOrm.Core;

begin  
  TJSOrm.Stop;    
end;  
```
## 🧬  Implementing your Entity`s

All of your entity`s need to inherits from TJSOrmEntity and your properties decorated by TEntityFieldAttributes.

_Simple entity :_

```delphi
uses
  JSOrm.Entity,
  JSOrm.Entity.Attributes;

type
  TPessoa = class(TJSOrmEntity)
  private
    FApelido: string;
    FIdade: integer;
    FNome: string;
    FDataNascimento: TDate;
    procedure SetApelido(const Value: string);
    procedure SetIdade(const Value: integer);
    procedure SetNome(const Value: string);
    procedure SetDataNascimento(const Value: TDate);
  public
    [TEntityFieldAttributes('C_NOME', tcString)]
    property Nome : string read FNome write SetNome;
    [TEntityFieldAttributes('C_IDADE', tcInteger)]
    property Idade : integer read FIdade write SetIdade;
    [TEntityFieldAttributes('C_APELIDO', tcString)]
    property Apelido : string read FApelido write SetApelido;
    [TEntityFieldAttributes('C_DATA_NASCIMENTO', tcDate)]
    property DataNascimento : TDate read FDataNascimento write SetDataNascimento;
  end;
```

_Complex entity`s relationship :_

```delphi
uses
  JSOrm.Entity,
  JSOrm.Entity.Attributes;

type
  TEndereco = class(TJSOrmEntity)
  private
    FBairro: string;
    FCEP: string;
    FNumero: integer;
    FRua: string;
    procedure SetBairro(const Value: string);
    procedure SetCEP(const Value: string);
    procedure SetNumero(const Value: integer);
    procedure SetRua(const Value: string);
  public
    [TEntityFieldAttributes('C_RUA', tcString)]
    property Rua : string read FRua write SetRua;
    [TEntityFieldAttributes('C_BAIRRO', tcString)]
    property Bairro : string read FBairro write SetBairro;
    [TEntityFieldAttributes('C_NUMERO', tcInteger)]
    property Numero : integer read FNumero write SetNumero;
    [TEntityFieldAttributes('C_CEP', tcString)]
    property CEP : string read FCEP write SetCEP;
  end;

  THabilidade = class(TJSOrmEntity)
  private
    FDescricao: string;
    FNome: string;
    procedure SetDescricao(const Value: string);
    procedure SetNome(const Value: string);
  public
    property Nome : string read FNome write SetNome;
    property Descricao : string read FDescricao write SetDescricao;
  end;

  TPessoa = class(TJSOrmEntity)
  private
    FApelido: string;
    FIdade: integer;
    FNome: string;
    FDataNascimento: TDate;
    FEndereco: TEndereco;
    FHabilidades: TJSOrmEntityList<THabilidade>;
    procedure SetApelido(const Value: string);
    procedure SetIdade(const Value: integer);
    procedure SetNome(const Value: string);
    procedure SetDataNascimento(const Value: TDate);
    procedure SetEndereco(const Value: TEndereco);
    procedure SetHabilidades(const Value: TJSOrmEntityList<THabilidade>);
  public
    [TEntityFieldAttributes('C_NOME', tcString)]
    property Nome : string read FNome write SetNome;
    [TEntityFieldAttributes('C_IDADE', tcInteger)]
    property Idade : integer read FIdade write SetIdade;
    [TEntityFieldAttributes('C_APELIDO', tcString)]
    property Apelido : string read FApelido write SetApelido;
    [TEntityFieldAttributes('C_DATA_NASCIMENTO', tcDate)]
    property DataNascimento : TDate read FDataNascimento write SetDataNascimento;
    [TEntityFieldAttributes('', tcObject)]
    property Endereco : TEndereco read FEndereco write SetEndereco;
    [TEntityFieldAttributes('', tcObjectList)]
    property Habilidades : TJSOrmEntityList<THabilidade> read FHabilidades write SetHabilidades;
  end;
```

TEntityFieldAttributes parameters are the name of your field in your database and the type of it.

| Supported Types | 
| --------------- | 
|  tcString       | 
|  tcInteger      | 
|  tcFloat        | 
|  tcDateTime     | 
|  tcDate         | 
|  tcObject       | 
|  tcObjectList   | 

## ⚠️ Atention

Note that in properties type of tcObject or tcObjectList, you don`t need to inform the entity field name because this is a virtual relationship

## 🌱 Implementing your DAO layer`s


