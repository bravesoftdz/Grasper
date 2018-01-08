unit eCommon;

interface

uses
  API_Crypt,
  API_DB,
  API_ORM;

type
  TCommonEntity = class abstract(TEntityFeatID)
  public
    constructor Create(aID: integer = 0);
  end;

  TCommonEntityList<T: TEntityAbstract> = class abstract(TEntityList<T>)
  public
    constructor Create(aFilterArr, aOrderArr: TArray<string>); overload;
  end;

const
  BLANK_PAGE = 'about:blank';

var
  CryptEngine: TCryptEngine;
  DBEngine: TDBEngine;

implementation

constructor TCommonEntityList<T>.Create(aFilterArr, aOrderArr: TArray<string>);
begin
  FCryptEngine := CryptEngine;
  inherited Create(DBEngine, aFilterArr, aOrderArr);
end;

constructor TCommonEntity.Create(aID: integer = 0);
begin
  FCryptEngine := CryptEngine;
  inherited Create(DBEngine, aID);
end;

end.
