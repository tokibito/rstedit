TSynHilighterRST   {first Identifier is considered to be the Class Name }
tk              {second Identifier is considered to be the Identifier Prefix }
IdentStart '_', 'a'..'z', 'A'..'Z':: '_', '0'..'9', 'a'..'z', 'A'..'Z'::

TOKENTYPES
Identifier
Section Style=[fsBold]|Foreground=$00F7925B
Space
Strong Style=[fsBold]|Foreground=$00404000
Key Style=[fsBold]|Foreground=$000080FF
String Foreground=clBlue
|><|

KEYS
table
contents
|><|

CHARS

'A'..'Z', 'a'..'z', '_':: Ident
BeginProc
  fTokenID := IdentKind(fLine + Run);
  inc(Run, fStringLen);
  while IsIdentChar(fLine[Run]) do
    Inc(Run);
EndProc

|><|

ENCLOSEDBY

Section,FirstSection,==,==
Section,SecondSection,--,--
Section,ThirdSection,~,~
Strong,Strong,*,*
String,String,`,`_

|><|

