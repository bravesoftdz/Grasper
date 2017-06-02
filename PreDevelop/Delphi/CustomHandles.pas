unit CustomHandles;

interface

type
  TCustomProc = function(aValue: string): string; stdcall;

  function RomanParsers_procWikiContent(aValue: string): string; stdcall;

implementation

uses
  API_Files;

function RomanParsers_procWikiContent(aValue: string): string; stdcall;
begin
  TFilesEngine.SaveTextToFile('value.html', aValue);
end;
exports RomanParsers_procWikiContent;

end.
