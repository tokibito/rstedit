TEMPLATE = u"""<html><head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> 
<style>
%(stylesheet)s

%(stylesheet_user)s
</style>
</head><body>
%(body)s
</body></html>"""

import os
MISC_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'misc')

def readfile(path):
  f = open(path, 'rb')
  tmp = f.read()
  f.close()
  return tmp

def convert_html(content):
  from docutils.core import publish_parts
  stylesheet_path = os.path.join(MISC_DIR, 'html4css1.css')
  stylesheet_body = readfile(stylesheet_path)
  stylesheet_path_user = os.path.join(MISC_DIR, 'user.css')
  if os.path.exists(stylesheet_path_user):
    stylesheet_body_user = readfile(stylesheet_path_user)
  else:
    stylesheet_body_user = ''
  parts = publish_parts(content.decode('utf-8'), writer_name='html4css1', settings_overrides={
      'stylesheet': stylesheet_path,
      'stylesheet_path': None,
      'template': os.path.join(MISC_DIR, 'template.txt'),
  })
  return TEMPLATE % {
      'body': parts['html_body'],
      'stylesheet': stylesheet_body,
      'stylesheet_user': stylesheet_body_user
  }

def convert_pdf(path):
  import logging
  from rst2pdf import createpdf

  parser = createpdf.parse_commandline()
  options, args = parser.parse_args(None)

  # loglevel
  createpdf.log.setLevel(logging.CRITICAL)

  # infile
  filename = path.decode('utf-8').encode('mbcs')
  options.basedir=os.path.dirname(os.path.abspath(filename))
  options.infile = open(filename)
  if filename.endswith('.tmp'):
      outfile = filename[:-4] + '.pdf'
  else:
      outfile = filename + '.pdf'
  options.outfile = outfile

  # style
  options.style = ['ja.style']
#, 'ja.style''styles.style', 
  # stylepath
  options.stylepath = [os.path.join(MISC_DIR, 'styles')]

  # fontpath
  #options.fpath = [os.path.join(os.environ.get('windir', 'C:\\WINDOWS'), 'Fonts')]
  options.fpath = [os.path.join(MISC_DIR, 'Fonts')]

  if options.invariant:
      createpdf.patch_PDFDate()
      createpdf.patch_digester()

  createpdf.add_extensions(options)

  createpdf.RstToPdf(
      stylesheets=options.style,
      language=options.language,
      header=options.header, footer=options.footer,
      inlinelinks=options.inlinelinks,
      breaklevel=int(options.breaklevel),
      baseurl=options.baseurl,
      fit_mode=options.fit_mode,
      smarty=str(options.smarty),
      font_path=options.fpath,
      style_path=options.stylepath,
      repeat_table_rows=options.repeattablerows,
      footnote_backlinks=options.footnote_backlinks,
      inline_footnotes=options.inline_footnotes,
      def_dpi=int(options.def_dpi),
      basedir=options.basedir,
      show_frame=options.show_frame,
      splittables=options.splittables,
      blank_first_page=options.blank_first_page,
      breakside=options.breakside
      ).createPdf(text=options.infile.read(),
                  source_path=options.infile.name,
                  output=options.outfile,
                  compressed=options.compressed)

  options.infile.close()


##############
# inititalize
##############
from docutils.parsers.rst import directives
from rst2pdf import pygments_code_block_directive
directives.register_directive('code-block', pygments_code_block_directive.code_block_directive)
directives.register_directive('source-code', pygments_code_block_directive.code_block_directive)
