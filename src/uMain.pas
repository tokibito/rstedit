unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PythonEngine, StdCtrls, ActnList, StdActns, Menus, SpTBXItem,
  ExtCtrls, SynEdit, SynMemo, ToolWin, ActnMan, ActnCtrls, ActnMenus,
  PlatformDefaultStyleActnCtrls, OleCtrls, SHDocVw, SpTBXDkPanels, ActiveX,
  uConst, ImgList;

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
    actOpenFile: TFileOpen;
    actSaveAsFile: TFileSaveAs;
    imlActionSmallIcon: TImageList;
    actNewFile: TAction;
    procedure pyeMainAfterInit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure pyioMainSendUniData(Sender: TObject; const Data: WideString);
    procedure synEditMainKeyPress(Sender: TObject; var Key: Char);
    procedure synEditMainChange(Sender: TObject);
    procedure timPreviewTimer(Sender: TObject);
    procedure actOpenFileAccept(Sender: TObject);
    procedure actSaveAsFileAccept(Sender: TObject);
    procedure actNewFileExecute(Sender: TObject);
  private
    sPyOut: string;
    function ExecString(Command: string): string;
    procedure SetPreviewContent(Content: string);
    procedure ImportModule(Module: string; Package: string = '');
    function ConvertHTML(Src: string): string;
    procedure ReloadPreview;
  public
    { Public 宣言 }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

function TfrmMain.ExecString(Command: string): string;
begin
  (*
  スクリプト実行はここを経由する
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
  モジュールをインポートする
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
  プレビュー更新のタイマーを有効に
  *)
  timPreview.Enabled := True;
end;

procedure TfrmMain.actNewFileExecute(Sender: TObject);
begin
  (*
  ファイル-新規作成
  *)
  synEditMain.Clear;
  ReloadPreview;
end;

procedure TfrmMain.actOpenFileAccept(Sender: TObject);
begin
  (*
  ファイル-開く
  *)
  // UTF8ファイルとして開く
  synEditMain.Lines.LoadFromFile(actOpenFile.Dialog.FileName, TEncoding.UTF8);
  ReloadPreview;
end;

procedure TfrmMain.actSaveAsFileAccept(Sender: TObject);
begin
  (*
  ファイル-名前を付けて保存
  *)
  // UTF8(BOMなし)で保存
  synEditMain.Lines.SaveToFile(actSaveAsFile.Dialog.FileName, TEncoding.GetEncoding(CP_UTF8));
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
  プレビュー用のブラウザに内容をセットする
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
  編集されたとき
  *)
  ReloadPreview;
end;

procedure TfrmMain.synEditMainKeyPress(Sender: TObject; var Key: Char);
begin
  (*
  SynEditのエンターバグ対応
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
  初期化
  *)
  sPyOut := '';
  // プレビューに初期テキストを設定
  SetPreviewContent('<html><body>'
      + '<p>ここにプレビューが表示されます</p>'
      + '</body></html>');
end;

procedure TfrmMain.pyeMainAfterInit(Sender: TObject);
begin
  (*
  sys.pathにlibrary.zipを追加する
  日本語パスは不可
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
  PythonEngineの標準出力で呼ばれる
  *)
  sPyOut := sPyOut + Data;
end;

end.
