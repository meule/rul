# Gunicorn configuration
# invoke:  gunicorn -c gunicorn.cfg.py 'TileStache:WSGITileServer("tilestache.cfg")'

# Workaround for PYTHONPATH problem https://github.com/migurski/TileStache/issues/86
import sys
import os
import PIL.Image
sys.modules['Image'] = PIL.Image

bind='127.0.0.1:8000'


if not hasattr(os, "sysconf"):
  workers=1
else:
  os.sysconf("SC_NPROCESSORS_ONLN")


timeout=30
  
