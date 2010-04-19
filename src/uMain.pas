unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PythonEngine, StdCtrls, ActnList, StdActns, Menus, SpTBXItem,
  ExtCtrls, SynEdit, SynMemo, ToolWin, ActnMan, ActnCtrls, ActnMenus,
  PlatformDefaultStyleActnCtrls, OleCtrls, SHDocVw, SpTBXDkPanels, ActiveX,
  uConst;

type
  TfrmMain = class(TForm)
    pyeMain: TPythonEngine;
    pyioMain: TPythonInputOutput;
    xstMain: TSpTBXStatusBar;
    pnlWrapper: TPanel;
    synEditMain: TSynMemo;
    amMain: TActionManager;
    mmMain: TActionMainMenuBar;
    actExit: TFileExit;
    actCopy: TEditCopy;
    actCut: TEditCut;
    actPaste: TEditPaste;
    actSelectAll: TEditSelectAll;
    tbMain: TActionToolBar;
    xsplMain: TSpTBXSplitter;
    pnlPreview: TPanel;
    wbPreview: TWebBrowser;
    timPreview: TTimer;
    procedure pyeMainAfterInit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure pyioMainSendUniData(Sender: TObject; const Data: WideString);
    procedure synEditMainKeyPress(Sender: TObject; var Key: Char);
    procedure synEditMainChange(Sender: TObject);
    procedure timPreviewTimer(Sender: TObject);
  private
    sPyOut: string;
    function ExecString(Command: string): string;
    procedure SetPreviewContent(Content: string);
    procedure ImportModule(Module: string; Package: string = '');
    function ConvertHTML(Src: string): string;
  public
    { Public �錾 }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

function TfrmMain.ExecString(Command: string): string;
begin
  (*
  �X�N���v�g���s�͂������o�R����
  *)
  sPyOut := '';
  pyeMain.ExecString(UTF8Encode(Command));
  Result := sPyOut;
end;

procedure TfrmMain.ImportModule(Module: string; Package: string = '');
var
  cmd: string;
begin
  (*
  ���W���[�����C���|�[�g����
  *)
  if Package <> '' then
    cmd := 'from ' + Package + ' '
  else
    cmd := '';
  cmd := cmd + 'import ' + Module;
  ExecString(cmd);
end;

function TfrmMain.ConvertHTML(Src: string): string;
begin
  Result := ExecString('sys.stdout.write(_rstedit.convert("""'
      + StringReplace(Src, #13#10, '\n', [rfReplaceAll])
      + '"""))');
end;

procedure TfrmMain.SetPreviewContent(Content: string);
var
  slBuffer: TStringList;
  msBuffer: TMemoryStream;
begin
  (*
  �v���r���[�p�̃u���E�U�ɓ��e���Z�b�g����
  *)
  wbPreview.Navigate('about:blank') ;
  while wbPreview.ReadyState < READYSTATE_INTERACTIVE do
    Application.ProcessMessages;
  slBuffer := TStringList.Create;
  msBuffer := TMemoryStream.Create;
  try
    slBuffer.Text := Content;
    slBuffer.SaveToStream(msBuffer, TEncoding.UTF8);
    msBuffer.Seek(0, 0);
    (wbPreview.Document as IPersistStreamInit).Load(TStreamAdapter.Create(msBuffer));
  finally
    msBuffer.Free;
    slBuffer.Free;
  end;
end;

procedure TfrmMain.synEditMainChange(Sender: TObject);
begin
  (*
  �ҏW���ꂽ�Ƃ�
  *)
  timPreview.Enabled := True;
end;

procedure TfrmMain.synEditMainKeyPress(Sender: TObject; var Key: Char);
begin
  (*
  SynEdit�̃G���^�[�o�O�Ή�
  *)
  if Ord(Key) = VK_RETURN then
    if Length(SynEditMain.LineText) <> 0 then
      if SynEditMain.CaretX = Length(SynEditMain.LineText) + 1 then
        if StringReplace(SynEditMain.LineText, ' ', '', [rfReplaceAll]) <> '' then
          SynEditMain.CaretY := SynEditMain.CaretY + 1;
end;

procedure TfrmMain.timPreviewTimer(Sender: TObject);
begin
  timPreview.Enabled := False;
  SetPreviewContent(ConvertHTML(synEditMain.Text));
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  (*
  ������
  *)
  sPyOut := '';
  // �v���r���[�ɏ����e�L�X�g��ݒ�
  SetPreviewContent('<html><body>'
      + '<p>�����Ƀv���r���[���\������܂�</p>'
      + '</body></html>');
end;

procedure TfrmMain.pyeMainAfterInit(Sender: TObject);
begin
  (*
  sys.path��library.zip��ǉ�����
  ���{��p�X�͕s��
  *)
  ExecString('sys.path.append("'
      + StringReplace(ExtractFilePath(Application.ExeName), '\', '\\', [rfReplaceAll])
      + LIB_DIR
      + '".decode("utf-8"))');
  ImportModule('_rstedit');
end;

procedure TfrmMain.pyioMainSendUniData(Sender: TObject; const Data: WideString);
begin
  (*
  PythonEngine�̕W���o�͂ŌĂ΂��
  *)
  sPyOut := sPyOut + Data;
end;

end.
