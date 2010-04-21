unit uConst;

interface

const
{$IFDEF DEBUG}
  LIB_DIR = '_Lib';
{$ELSE}
  LIB_DIR = 'library.zip';
{$ENDIF}

  TITLE_CAPTION = '%s%s - rstedit';

implementation

end.