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
  // PYTHONPATHにライブラリのディレクトリを追加
  SetEnvironmentVariable('PYTHONPATH',
      PChar(ExtractFilePath(Application.ExeName) + 'modules;'
      + ExtractFilePath(Application.ExeName) + LIB_DIR));
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmVersion, frmVersion);
  Application.Run;
end.
