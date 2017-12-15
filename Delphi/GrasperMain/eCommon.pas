unit eCommon;

interface

uses
  API_ORM,
  cController;

type
  TCommonEntity = class abstract(TEntityFeatID)
  public
    constructor Create(aID: integer = 0);
  end;

  TCommonEntityList<T: TEntityAbstract> = class abstract(TEntityList<T>)
  public
    constructor Create(aFilterArr, aOrderArr: TArray<string>);
  end;

implementation

constructor TCommonEntityList<T>.Create(aFilterArr, aOrderArr: TArray<string>);
begin
  inherited Create(DBEngine, aFilterArr, aOrderArr);
end;

constructor TCommonEntity.Create(aID: integer = 0);
begin
  inherited Create(DBEngine, aID);
end;

end.
