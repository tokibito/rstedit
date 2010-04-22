unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PythonEngine, StdCtrls, ActnList, StdActns, Menus, SpTBXItem,
  ExtCtrls, SynEdit, SynMemo, ToolWin, ActnMan, ActnCtrls, ActnMenus,
  PlatformDefaultStyleActnCtrls, OleCtrls, SHDocVw, SpTBXDkPanels, ActiveX,
  uConst, ImgList, DragDrop, DropTarget, DragDropFile, ComCtrls, AppEvnts,
  TB2Item, SpTBXControls, SynHighlighterRST;

type
  TfrmMain = class(TForm)
    pyeMain: TPythonEngine;
    pyioMain: TPythonInputOutput;
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
    actSaveAsFile: TFileSaveAs;
    imlActionSmallIcon: TImageList;
    actNewFile: TAction;
    actSave: TAction;
    dlgOpenFile: TOpenDialog;
    actOpenFile: TAction;
    dndMain: TDropFileTarget;
    appevMain: TApplicationEvents;
    xsbMain: TSpTBXStatusBar;
    xpnlStatus: TSpTBXPanel;
    TBControlItem1: TTBControlItem;
    xlblStatus: TSpTBXLabel;
    procedure pyeMainAfterInit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure pyioMainSendUniData(Sender: TObject; const Data: WideString);
    procedure synEditMainKeyPress(Sender: TObject; var Key: Char);
    procedure synEditMainChange(Sender: TObject);
    procedure timPreviewTimer(Sender: TObject);
    procedure actSaveAsFileAccept(Sender: TObject);
    procedure actNewFileExecute(Sender: TObject);
    procedure actSaveAsFileBeforeExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actOpenFileExecute(Sender: TObject);
    procedure dndMainDrop(Sender: TObject; ShiftState: TShiftState;
      APoint: TPoint; var Effect: Integer);
    procedure appevMainHint(Sender: TObject);
  private
    sPyOut: string;
    sCurrentFile: string;
    Modified: Boolean;
    function ExecString(Command: string): string;
    procedure SetPreviewContent(Content: string);
    procedure ImportModule(Module: string; Package: string = '');
    function ConvertHTML(Src: string): string;
    procedure ReloadPreview;
    procedure Modify;
    procedure ClearModified;
    procedure SaveFile;
    procedure LoadFile;
    function CheckModifyAndSave: Boolean;
  public
    { Public �錾 }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

///////////////////////////////////////////////////////////
//
//  �v���C�x�[�g
//
///////////////////////////////////////////////////////////
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

procedure TfrmMain.ReloadPreview;
begin
  (*
  �v���r���[�X�V�̃^�C�}�[��L����
  *)
  timPreview.Enabled := True;
end;

function TfrmMain.ConvertHTML(Src: string): string;
begin
  Result := ExecString('sys.stdout.write(_rstedit.convert("""'
      + StringReplace(Src, #13#10, '\n', [rfReplaceAll])
      + '"""))');
end;

procedure TfrmMain.Modify;
begin
  (*
  �G�f�B�^���e��ύX�������̏���
  *)
  Modified := True;
  // �^�C�g���o�[�̕\����ς���
  Caption := Format(TITLE_CAPTION, [sCurrentFile, ' *']);
  // �㏑���ۑ���L���ɂ���
  actSave.Enabled := True;
end;

procedure TfrmMain.ClearModified;
begin
  (*
  �ύX��Ԃ��N���A����
  *)
  Modified := False;
  // �^�C�g���o�[�̕\����ς���
  Caption := Format(TITLE_CAPTION, [sCurrentFile, '']);
  // �㏑���ۑ��𖳌��ɂ���
  actSave.Enabled := False;
end;

procedure TfrmMain.SaveFile;
begin
  (*
  �G�f�B�^�̓��e���t�@�C���ɕۑ�
  *)
  // UTF8(BOM�Ȃ�)�ŕۑ�
  synEditMain.Lines.SaveToFile(sCurrentFile, TEncoding.GetEncoding(CP_UTF8));
end;

procedure TfrmMain.LoadFile;
begin
  (*
  �G�f�B�^�Ƀt�@�C����ǂݍ���
  *)
  // UTF8�t�@�C���Ƃ��ĊJ��
  synEditMain.Lines.LoadFromFile(sCurrentFile, TEncoding.UTF8);
end;

function TfrmMain.CheckModifyAndSave: Boolean;
var
  intDlgResult: Integer;
begin
  (*
  �ύX�̃`�F�b�N�ƕۑ�(�߂�l��False�̏ꍇ�͌Ăяo�����ŃL�����Z������)
  *)
  Result := True;
  if Modified then
  begin
    // �C��������ꍇ�͔j�����邩�m�F
    intDlgResult := MessageDlg(Format('%s �ւ̕ύX��ۑ����܂���?', [sCurrentFile]),
        mtWarning, [mbYes, mbNo, mbCancel], -1);
    case intDlgResult of
      mrYes:
      begin
        // �㏑���ۑ�����
        actSave.Execute;
        // �ύX���ꂽ�܂܂̏ꍇ(�ۑ����L�����Z��)�͒��f����
        if Modified then
        begin
          Result := False;
          Exit;
        end;
      end;
      mrCancel:
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
end;

///////////////////////////////////////////////////////////
//
// �C�x���g
//
///////////////////////////////////////////////////////////
procedure TfrmMain.actNewFileExecute(Sender: TObject);
begin
  (*
  �t�@�C��-�V�K�쐬
  *)
  if not CheckModifyAndSave then
    Exit;
  synEditMain.Clear;
  sCurrentFile := '����';
  ClearModified;
  // �v���r���[�ɏ����e�L�X�g��ݒ�
  timPreview.Enabled := False;
  SetPreviewContent('<html><body>'
      + '<p>�����Ƀv���r���[���\������܂�</p>'
      + '</body></html>');
end;

procedure TfrmMain.actOpenFileExecute(Sender: TObject);
begin
  (*
  �t�@�C��-�J��
  *)
  if not CheckModifyAndSave then
    Exit;
  if dlgOpenFile.Execute then
  begin
    sCurrentFile := dlgOpenFile.FileName;
    LoadFile;
    ClearModified;
    ReloadPreview;
  end;
end;

procedure TfrmMain.actSaveAsFileAccept(Sender: TObject);
begin
  (*
  �t�@�C��-���O��t���ĕۑ�
  *)
  sCurrentFile := actSaveAsFile.Dialog.FileName;
  SaveFile;
  ClearModified;
end;

procedure TfrmMain.actSaveAsFileBeforeExecute(Sender: TObject);
begin
  (*
  �t�@�C��-���O��t���ĕۑ�(���O����)
  *)
  actSaveAsFile.Dialog.FileName := sCurrentFile;
end;

procedure TfrmMain.actSaveExecute(Sender: TObject);
begin
  (*
  �t�@�C��-�㏑���ۑ�
  *)
  // �t�@�C�������݂��Ȃ��ꍇ�͖��O��t���ĕۑ�
  if not FileExists(sCurrentFile) then
  begin
    actSaveAsFile.Execute;
    Exit;
  end;
  SaveFile;
  ClearModified;
end;

procedure TfrmMain.appevMainHint(Sender: TObject);
begin
  (*
  �J�[�\���ʒu�̃q���g
  *)
  xlblStatus.Caption := Application.Hint;
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
  Modify;
  ReloadPreview;
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

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  (*
  �t�H�[��-����v��
  *)
  if not CheckModifyAndSave then
    CanClose := False;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  (*
  ������
  *)
  // PythonEngine�̎��s���ʂ�ێ�����ϐ�
  sPyOut := '';
  // �V���^�b�N�X�n�C���C�g
  synEditMain.Highlighter := TSynHilighterRST.Create(Self);
  // ���݊J���Ă���t�@�C��
  sCurrentFile := '';
  // �V�K�쐬
  actNewFileExecute(Sender);
end;

procedure TfrmMain.dndMainDrop(Sender: TObject; ShiftState: TShiftState;
  APoint: TPoint; var Effect: Integer);
begin
  (*
  �t�H�[���Ƀt�@�C����D&D
  *)
  if not CheckModifyAndSave then
    Exit;
  sCurrentFile := dndMain.Files[0];
  LoadFile;
  ClearModified;
  ReloadPreview;
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
