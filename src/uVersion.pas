unit uVersion;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uConst, StdCtrls;

type
  TfrmVersion = class(TForm)
    btnOk: TButton;
    lblVersionString: TLabel;
    lblCopyright: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private éŒ¾ }
  public
    { Public éŒ¾ }
  end;

var
  frmVersion: TfrmVersion;

implementation

{$R *.dfm}

procedure TfrmVersion.FormCreate(Sender: TObject);
begin
  (*
  ‰Šú‰»
  *)
  lblCopyright.Caption := COPYRIGHT;
  lblVersionString.Caption := Format(VERSION_STRING, [VERSION_NUMBER]);
end;

end.
