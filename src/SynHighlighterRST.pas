{+-----------------------------------------------------------------------------+
 | Class:       TSynHilighterRST
 | Created:     2010-04-22
 | Last change: 2010-04-22
 | Author:      tokibito
 | Description: SynHighlighterRST/ReStructuredText highlighter
 | Version:     0.1
 |
 | Copyright (c) 2010 tokibito. All rights reserved.
 |
 | Generated with SynGen.
 +----------------------------------------------------------------------------+}

{$IFNDEF QSYNHIGHLIGHTERRST}
unit SynHighlighterRST;
{$ENDIF}

{$I SynEdit.inc}

interface

uses
{$IFDEF SYN_CLX}
  QGraphics,
  QSynEditTypes,
  QSynEditHighlighter,
  QSynUnicode,
{$ELSE}
  Graphics,
  SynEditTypes,
  SynEditHighlighter,
  SynUnicode,
{$ENDIF}
  SysUtils,
  Classes;

type
  TtkTokenKind = (
    tkIdentifier,
    tkKey,
    tkNull,
    tkSection,
    tkSpace,
    tkString,
    tkStrong,
    tkUnknown);

  TRangeState = (rsUnKnown, rsFirstSection, rsSecondSection, rsThirdSection, rsStrong, rsString);

  TProcTableProc = procedure of object;

  PIdentFuncTableFunc = ^TIdentFuncTableFunc;
  TIdentFuncTableFunc = function (Index: Integer): TtkTokenKind of object;

type
  TSynHilighterRST = class(TSynCustomHighlighter)
  private
    fRange: TRangeState;
    fTokenID: TtkTokenKind;
    fIdentFuncTable: array[0..2] of TIdentFuncTableFunc;
    fIdentifierAttri: TSynHighlighterAttributes;
    fKeyAttri: TSynHighlighterAttributes;
    fSectionAttri: TSynHighlighterAttributes;
    fSpaceAttri: TSynHighlighterAttributes;
    fStringAttri: TSynHighlighterAttributes;
    fStrongAttri: TSynHighlighterAttributes;
    function HashKey(Str: PWideChar): Cardinal;
    function FuncContents(Index: Integer): TtkTokenKind;
    function FuncTable(Index: Integer): TtkTokenKind;
    procedure IdentProc;
    procedure UnknownProc;
    function AltFunc(Index: Integer): TtkTokenKind;
    procedure InitIdent;
    function IdentKind(MayBe: PWideChar): TtkTokenKind;
    procedure NullProc;
    procedure SpaceProc;
    procedure CRProc;
    procedure LFProc;
    procedure FirstSectionOpenProc;
    procedure FirstSectionProc;
    procedure SecondSectionOpenProc;
    procedure SecondSectionProc;
    procedure ThirdSectionOpenProc;
    procedure ThirdSectionProc;
    procedure StrongOpenProc;
    procedure StrongProc;
    procedure StringOpenProc;
    procedure StringProc;
  protected
    function GetSampleSource: UnicodeString; override;
    function IsFilterStored: Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    class function GetFriendlyLanguageName: UnicodeString; override;
    class function GetLanguageName: string; override;
    function GetRange: Pointer; override;
    procedure ResetRange; override;
    procedure SetRange(Value: Pointer); override;
    function GetDefaultAttribute(Index: Integer): TSynHighlighterAttributes; override;
    function GetEol: Boolean; override;
    function GetKeyWords(TokenKind: Integer): UnicodeString; override;
    function GetTokenID: TtkTokenKind;
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetTokenKind: Integer; override;
    function IsIdentChar(AChar: WideChar): Boolean; override;
    procedure Next; override;
  published
    property IdentifierAttri: TSynHighlighterAttributes read fIdentifierAttri write fIdentifierAttri;
    property KeyAttri: TSynHighlighterAttributes read fKeyAttri write fKeyAttri;
    property SectionAttri: TSynHighlighterAttributes read fSectionAttri write fSectionAttri;
    property SpaceAttri: TSynHighlighterAttributes read fSpaceAttri write fSpaceAttri;
    property StringAttri: TSynHighlighterAttributes read fStringAttri write fStringAttri;
    property StrongAttri: TSynHighlighterAttributes read fStrongAttri write fStrongAttri;
  end;

implementation

uses
{$IFDEF SYN_CLX}
  QSynEditStrConst;
{$ELSE}
  SynEditStrConst;
{$ENDIF}

resourcestring
  SYNS_FilterReStructuredText = 'RST files(*.rst,*.txt)|*.rst,*.txt';
  SYNS_LangReStructuredText = 'ReStructuredText';
  SYNS_FriendlyLangReStructuredText = 'ReStructuredText';
  SYNS_AttrStrong = 'Strong';
  SYNS_FriendlyAttrStrong = 'Strong';

const
  // as this language is case-insensitive keywords *must* be in lowercase
  KeyWords: array[0..1] of UnicodeString = (
    'contents', 'table' 
  );

  KeyIndices: array[0..2] of Integer = (
    -1, 1, 0 
  );

procedure TSynHilighterRST.InitIdent;
var
  i: Integer;
begin
  for i := Low(fIdentFuncTable) to High(fIdentFuncTable) do
    if KeyIndices[i] = -1 then
      fIdentFuncTable[i] := AltFunc;

  fIdentFuncTable[2] := FuncContents;
  fIdentFuncTable[1] := FuncTable;
end;

{$Q-}
function TSynHilighterRST.HashKey(Str: PWideChar): Cardinal;
begin
  Result := 0;
  while IsIdentChar(Str^) do
  begin
    Result := Result + Ord(Str^);
    inc(Str);
  end;
  Result := Result mod 3;
  fStringLen := Str - fToIdent;
end;
{$Q+}

function TSynHilighterRST.FuncContents(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynHilighterRST.FuncTable(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynHilighterRST.AltFunc(Index: Integer): TtkTokenKind;
begin
  Result := tkIdentifier;
end;

function TSynHilighterRST.IdentKind(MayBe: PWideChar): TtkTokenKind;
var
  Key: Cardinal;
begin
  fToIdent := MayBe;
  Key := HashKey(MayBe);
  if Key <= High(fIdentFuncTable) then
    Result := fIdentFuncTable[Key](KeyIndices[Key])
  else
    Result := tkIdentifier;
end;

procedure TSynHilighterRST.SpaceProc;
begin
  inc(Run);
  fTokenID := tkSpace;
  while (FLine[Run] <= #32) and not IsLineEnd(Run) do inc(Run);
end;

procedure TSynHilighterRST.NullProc;
begin
  fTokenID := tkNull;
  inc(Run);
end;

procedure TSynHilighterRST.CRProc;
begin
  fTokenID := tkSpace;
  inc(Run);
  if fLine[Run] = #10 then
    inc(Run);
end;

procedure TSynHilighterRST.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end;

procedure TSynHilighterRST.FirstSectionOpenProc;
begin
  Inc(Run);
  if (fLine[Run] = '=') then
  begin
    Inc(Run, 1);
    fRange := rsFirstSection;
    FirstSectionProc;
    fTokenID := tkSection;
  end
  else
    fTokenID := tkIdentifier;
end;

procedure TSynHilighterRST.FirstSectionProc;
begin
  fTokenID := tkSection;
  repeat
    if (fLine[Run] = '=') and
       (fLine[Run + 1] = '=') then
    begin
      Inc(Run, 2);
      fRange := rsUnKnown;
      Break;
    end;
    if not IsLineEnd(Run) then
      Inc(Run);
  until IsLineEnd(Run);
end;

procedure TSynHilighterRST.SecondSectionOpenProc;
begin
  Inc(Run);
  if (fLine[Run] = '-') then
  begin
    Inc(Run, 1);
    fRange := rsSecondSection;
    SecondSectionProc;
    fTokenID := tkSection;
  end
  else
    fTokenID := tkIdentifier;
end;

procedure TSynHilighterRST.SecondSectionProc;
begin
  fTokenID := tkSection;
  repeat
    if (fLine[Run] = '-') and
       (fLine[Run + 1] = '-') then
    begin
      Inc(Run, 2);
      fRange := rsUnKnown;
      Break;
    end;
    if not IsLineEnd(Run) then
      Inc(Run);
  until IsLineEnd(Run);
end;

procedure TSynHilighterRST.ThirdSectionOpenProc;
begin
  Inc(Run);
  fRange := rsThirdSection;
  ThirdSectionProc;
  fTokenID := tkSection;
end;

procedure TSynHilighterRST.ThirdSectionProc;
begin
  fTokenID := tkSection;
  repeat
    if (fLine[Run] = '~') then
    begin
      Inc(Run, 1);
      fRange := rsUnKnown;
      Break;
    end;
    if not IsLineEnd(Run) then
      Inc(Run);
  until IsLineEnd(Run);
end;

procedure TSynHilighterRST.StrongOpenProc;
begin
  Inc(Run);
  fRange := rsStrong;
  StrongProc;
  fTokenID := tkStrong;
end;

procedure TSynHilighterRST.StrongProc;
begin
  fTokenID := tkStrong;
  repeat
    if (fLine[Run] = '*') then
    begin
      Inc(Run, 1);
      fRange := rsUnKnown;
      Break;
    end;
    if not IsLineEnd(Run) then
      Inc(Run);
  until IsLineEnd(Run);
end;

procedure TSynHilighterRST.StringOpenProc;
begin
  Inc(Run);
  fRange := rsString;
  StringProc;
  fTokenID := tkString;
end;

procedure TSynHilighterRST.StringProc;
begin
  fTokenID := tkString;
  repeat
    if (fLine[Run] = '`') and
       (fLine[Run + 1] = '_') then
    begin
      Inc(Run, 2);
      fRange := rsUnKnown;
      Break;
    end;
    if not IsLineEnd(Run) then
      Inc(Run);
  until IsLineEnd(Run);
end;

constructor TSynHilighterRST.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fCaseSensitive := False;

  fIdentifierAttri := TSynHighLighterAttributes.Create(SYNS_AttrIdentifier, SYNS_FriendlyAttrIdentifier);
  AddAttribute(fIdentifierAttri);

  fKeyAttri := TSynHighLighterAttributes.Create(SYNS_AttrReservedWord, SYNS_FriendlyAttrReservedWord);
  fKeyAttri.Style := [fsBold];
  fKeyAttri.Foreground := $000080FF;
  AddAttribute(fKeyAttri);

  fSectionAttri := TSynHighLighterAttributes.Create(SYNS_AttrSection, SYNS_FriendlyAttrSection);
  fSectionAttri.Style := [fsBold];
  fSectionAttri.Foreground := $00F7925B;
  AddAttribute(fSectionAttri);

  fSpaceAttri := TSynHighLighterAttributes.Create(SYNS_AttrSpace, SYNS_FriendlyAttrSpace);
  AddAttribute(fSpaceAttri);

  fStringAttri := TSynHighLighterAttributes.Create(SYNS_AttrString, SYNS_FriendlyAttrString);
  fStringAttri.Foreground := clBlue;
  AddAttribute(fStringAttri);

  fStrongAttri := TSynHighLighterAttributes.Create(SYNS_AttrStrong, SYNS_FriendlyAttrStrong);
  fStrongAttri.Style := [fsBold];
  fStrongAttri.Foreground := $00404000;
  AddAttribute(fStrongAttri);

  SetAttributesOnChange(DefHighlightChange);
  InitIdent;
  fDefaultFilter := SYNS_FilterReStructuredText;
  fRange := rsUnknown;
end;

procedure TSynHilighterRST.IdentProc;
begin
  fTokenID := IdentKind(fLine + Run);
  inc(Run, fStringLen);
  while IsIdentChar(fLine[Run]) do
    Inc(Run);
end;

procedure TSynHilighterRST.UnknownProc;
begin
  inc(Run);
  fTokenID := tkUnknown;
end;

procedure TSynHilighterRST.Next;
begin
  fTokenPos := Run;
  //case fRange of
  //else
    case fLine[Run] of
      #0: NullProc;
      #10: LFProc;
      #13: CRProc;
      '=': FirstSectionOpenProc;
      '-': SecondSectionOpenProc;
      '~': ThirdSectionOpenProc;
      '*': StrongOpenProc;
      '`': StringOpenProc;
      #1..#9, #11, #12, #14..#32: SpaceProc;
      'A'..'Z', 'a'..'z', '_': IdentProc;
    else
      UnknownProc;
    end;
  //end;
  inherited;
end;

function TSynHilighterRST.GetDefaultAttribute(Index: Integer): TSynHighLighterAttributes;
begin
  case Index of
    SYN_ATTR_IDENTIFIER: Result := fIdentifierAttri;
    SYN_ATTR_KEYWORD: Result := fKeyAttri;
    SYN_ATTR_STRING: Result := fStringAttri;
    SYN_ATTR_WHITESPACE: Result := fSpaceAttri;
  else
    Result := nil;
  end;
end;

function TSynHilighterRST.GetEol: Boolean;
begin
  Result := Run = fLineLen + 1;
end;

function TSynHilighterRST.GetKeyWords(TokenKind: Integer): UnicodeString;
begin
  Result := 
    'contents,table';
end;

function TSynHilighterRST.GetTokenID: TtkTokenKind;
begin
  Result := fTokenId;
end;

function TSynHilighterRST.GetTokenAttribute: TSynHighLighterAttributes;
begin
  case GetTokenID of
    tkIdentifier: Result := fIdentifierAttri;
    tkKey: Result := fKeyAttri;
    tkSection: Result := fSectionAttri;
    tkSpace: Result := fSpaceAttri;
    tkString: Result := fStringAttri;
    tkStrong: Result := fStrongAttri;
    tkUnknown: Result := fIdentifierAttri;
  else
    Result := nil;
  end;
end;

function TSynHilighterRST.GetTokenKind: Integer;
begin
  Result := Ord(fTokenId);
end;

function TSynHilighterRST.IsIdentChar(AChar: WideChar): Boolean;
begin
  case AChar of
    '_', '0'..'9', 'a'..'z', 'A'..'Z':
      Result := True;
    else
      Result := False;
  end;
end;

function TSynHilighterRST.GetSampleSource: UnicodeString;
begin
  Result := 
    'Sample source for: '#13#10 +
    'SynHighlighterRST/ReStructuredText highlighter';
end;

function TSynHilighterRST.IsFilterStored: Boolean;
begin
  Result := fDefaultFilter <> SYNS_FilterReStructuredText;
end;

class function TSynHilighterRST.GetFriendlyLanguageName: UnicodeString;
begin
  Result := SYNS_FriendlyLangReStructuredText;
end;

class function TSynHilighterRST.GetLanguageName: string;
begin
  Result := SYNS_LangReStructuredText;
end;

procedure TSynHilighterRST.ResetRange;
begin
  fRange := rsUnknown;
end;

procedure TSynHilighterRST.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

function TSynHilighterRST.GetRange: Pointer;
begin
  Result := Pointer(fRange);
end;

initialization
{$IFNDEF SYN_CPPB_1}
  RegisterPlaceableHighlighter(TSynHilighterRST);
{$ENDIF}
end.
