unit cController;

interface

uses
  API_MVC_DB;

type
  TController = class(TControllerDB)
  protected
    procedure InitDB; override;
  published
    procedure GetJobList;
    procedure Test;
  end;

implementation

uses
  API_DB_SQLite,
  System.SysUtils,


  FireDAC.Comp.Client;

procedure TController.GetJobList;
var
  dsQuery: TFDQuery;
  s: string;
begin
  dsQuery := TFDQuery.Create(nil);
  try
    dsQuery.SQL.Text := 'select * from jobs';
    FDBEngine.OpenQuery(dsQuery);

    s := dsQuery.FieldByName('caption').AsString;
  finally
    dsQuery.Free;
  end;
end;

procedure TController.Test;
var
  dsQuery: TFDQuery;
  s: string;
begin
  dsQuery := TFDQuery.Create(nil);
  try
    dsQuery.SQL.Text := 'select * from jobs';
    FDBEngine.OpenQuery(dsQuery);

    s := dsQuery.FieldByName('caption').AsString;
  finally
    dsQuery.Free;
  end;
end;

procedure TController.InitDB;
begin
  FConnectOnCreate := True;
  FConnectParams.DataBase := GetCurrentDir + '\DB\local.db';
  FDBEngineClass := TSQLiteEngine;
end;

end.
