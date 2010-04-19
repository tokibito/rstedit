program rstedit;

uses
  Windows,
  SysUtils,
  Forms,
  uMain in 'uMain.pas' {frmMain},
  uConst in 'uConst.pas';

{$R *.res}

var
  Path: string;

begin
  Application.Initialize;
  // PYTHONPATH�Ƀ��C�u�����̃f�B���N�g����ǉ�
  SetEnvironmentVariable('PYTHONPATH',
      PChar(ExtractFilePath(Application.ExeName) + 'modules;'
      + ExtractFilePath(Application.ExeName) + LIB_DIR));
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
