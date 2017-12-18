unit eJob;

interface

uses
  API_ORM,
  eCommon;

type
  PJob = ^TJob;
  TJob = class(TCommonEntity)
  private
    FCaption: string;
    FZeroLink: string;
  public
    class function GetStructure: TSructure; override;
  published
    property Caption: string read FCaption write FCaption;
    property ZeroLink: string read FZeroLink write FZeroLink;
  end;

  TJobList = TCommonEntityList<TJob>;

implementation

uses Data.DB;

class function TJob.GetStructure: TSructure;
begin
  Result.TableName := 'JOBS';
end;

end.
