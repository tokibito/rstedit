unit uConst;

interface

const
{$IFDEF DEBUG}
  LIB_DIR = '_Lib';
{$ELSE}
  LIB_DIR = 'library.zip';
{$ENDIF}

  TITLE_CAPTION = '%s%s - rstedit';
  VERSION_NUMBER = '0.1.0';
  VERSION_STRING = 'rstedit %s';
  COPYRIGHT = 'Copyright (C) 2010- Shinya Okano';

implementation

end.