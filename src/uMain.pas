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
    { Public 宣言 }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

///////////////////////////////////////////////////////////
//
//  プライベート
//
///////////////////////////////////////////////////////////
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

function TfrmMain.ConvertHTML(Src: string): string;
begin
  Result := ExecString('sys.stdout.write(_rstedit.convert("""'
      + StringReplace(Src, #13#10, '\n', [rfReplaceAll])
      + '"""))');
end;

procedure TfrmMain.Modify;
begin
  (*
  エディタ内容を変更した時の処理
  *)
  Modified := True;
  // タイトルバーの表示を変える
  Caption := Format(TITLE_CAPTION, [sCurrentFile, ' *']);
  // 上書き保存を有効にする
  actSave.Enabled := True;
end;

procedure TfrmMain.ClearModified;
begin
  (*
  変更状態をクリアする
  *)
  Modified := False;
  // タイトルバーの表示を変える
  Caption := Format(TITLE_CAPTION, [sCurrentFile, '']);
  // 上書き保存を無効にする
  actSave.Enabled := False;
end;

procedure TfrmMain.SaveFile;
begin
  (*
  エディタの内容をファイルに保存
  *)
  // UTF8(BOMなし)で保存
  synEditMain.Lines.SaveToFile(sCurrentFile, TEncoding.GetEncoding(CP_UTF8));
end;

procedure TfrmMain.LoadFile;
begin
  (*
  エディタにファイルを読み込む
  *)
  // UTF8ファイルとして開く
  synEditMain.Lines.LoadFromFile(sCurrentFile, TEncoding.UTF8);
end;

function TfrmMain.CheckModifyAndSave: Boolean;
var
  intDlgResult: Integer;
begin
  (*
  変更のチェックと保存(戻り値がFalseの場合は呼び出し元でキャンセル処理)
  *)
  Result := True;
  if Modified then
  begin
    // 修正がある場合は破棄するか確認
    intDlgResult := MessageDlg(Format('%s への変更を保存しますか?', [sCurrentFile]),
        mtWarning, [mbYes, mbNo, mbCancel], -1);
    case intDlgResult of
      mrYes:
      begin
        // 上書き保存する
        actSave.Execute;
        // 変更されたままの場合(保存をキャンセル)は中断する
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
// イベント
//
///////////////////////////////////////////////////////////
procedure TfrmMain.actNewFileExecute(Sender: TObject);
begin
  (*
  ファイル-新規作成
  *)
  if not CheckModifyAndSave then
    Exit;
  synEditMain.Clear;
  sCurrentFile := '無題';
  ClearModified;
  // プレビューに初期テキストを設定
  timPreview.Enabled := False;
  SetPreviewContent('<html><body>'
      + '<p>ここにプレビューが表示されます</p>'
      + '</body></html>');
end;

procedure TfrmMain.actOpenFileExecute(Sender: TObject);
begin
  (*
  ファイル-開く
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
  ファイル-名前を付けて保存
  *)
  sCurrentFile := actSaveAsFile.Dialog.FileName;
  SaveFile;
  ClearModified;
end;

procedure TfrmMain.actSaveAsFileBeforeExecute(Sender: TObject);
begin
  (*
  ファイル-名前を付けて保存(事前処理)
  *)
  actSaveAsFile.Dialog.FileName := sCurrentFile;
end;

procedure TfrmMain.actSaveExecute(Sender: TObject);
begin
  (*
  ファイル-上書き保存
  *)
  // ファイルが存在しない場合は名前を付けて保存
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
  カーソル位置のヒント
  *)
  xlblStatus.Caption := Application.Hint;
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
  Modify;
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

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  (*
  フォーム-閉じる要求
  *)
  if not CheckModifyAndSave then
    CanClose := False;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  (*
  初期化
  *)
  // PythonEngineの実行結果を保持する変数
  sPyOut := '';
  // シンタックスハイライト
  synEditMain.Highlighter := TSynHilighterRST.Create(Self);
  // 現在開いているファイル
  sCurrentFile := '';
  // 新規作成
  actNewFileExecute(Sender);
end;

procedure TfrmMain.dndMainDrop(Sender: TObject; ShiftState: TShiftState;
  APoint: TPoint; var Effect: Integer);
begin
  (*
  フォームにファイルをD&D
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
