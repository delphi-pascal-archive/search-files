program SearchFiles;

uses
  Forms,
  uMain in 'uMain.pas' {fMain},
  Search in 'Search.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '���������';
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
