program rstedit;

uses
  Windows,
  SysUtils,
  Forms,
  uMain in 'uMain.pas' {frmMain},
  uConst in 'uConst.pas',
  SynHighlighterRST in 'SynHighlighterRST.pas',
  uVersion in 'uVersion.pas' {frmVersion};

{$R *.res}

var
  Path: string;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmVersion, frmVersion);
  Application.Run;
end.
