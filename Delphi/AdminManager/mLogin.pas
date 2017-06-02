unit mLogin;

interface

uses
  API_MVC_DB;

type
  TModelLogin = class(TModelDB)
  public
    procedure Execute; override;
  end;

implementation

uses
  FireDAC.Comp.Client,
  IdIPWatch;

procedure TModelLogin.Execute;
var
  dsQuery: TFDQuery;
  IdIPWatch: TIdIPWatch;
begin
  dsQuery:=TFDQuery.Create(nil);
  try
    dsQuery.SQL.Text := 'select * from users where login = :login';
    dsQuery.ParamByName('login').AsString := FData.Items['login'];
    FDBEngine.OpenQuery(dsQuery);

    if dsQuery.FieldByName('password').AsString = FData.Items['password'] then
      begin
        FData.AddOrSetValue('user', dsQuery.FieldByName('login').AsString);

        IdIPWatch := TIdIPWatch.Create(nil);
        try
          FData.AddOrSetValue('ip', IdIPWatch.LocalIP);
        finally
          IdIPWatch.Free;
        end;

        CreateEvent('LoginDone');
      end
    else
      CreateEvent('LoginFail');
  finally
    dsQuery.Free;
  end;
end;

end.
