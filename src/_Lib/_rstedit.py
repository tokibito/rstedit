TEMPLATE = u"""<html><head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> 
</head><body>
%s
</body></html>"""

import os
MISC_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'misc')

def convert(content):
  from docutils.core import publish_parts
  parts = publish_parts(content.decode('utf-8'), writer_name='html4css1', settings_overrides={
      'stylesheet': os.path.join(MISC_DIR, 'html4css1.css'),
      'stylesheet_path': None,
      'template': os.path.join(MISC_DIR, 'template.txt'),
  })
  return TEMPLATE % parts['html_body']
