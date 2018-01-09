unit mParser;

interface

uses
  API_MVC;

type
  TModel = class(TModelAbstract)
  public
    Counter: Integer;
    procedure Start; override;
  end;

implementation

uses
  System.SysUtils;

procedure TModel.Start;
begin
end;

end.
