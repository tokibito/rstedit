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

def convert(content):
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
