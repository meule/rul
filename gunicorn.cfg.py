# Gunicorn configuration
# invoke:  gunicorn -c gunicorn.cfg.py 'TileStache:WSGITileServer("tilestache.cfg")'

# Workaround for PYTHONPATH problem https://github.com/migurski/TileStache/issues/86
import sys
import os
import PIL.Image
sys.modules['Image'] = PIL.Image

bind='127.0.0.1:8000'

# Number of worker processes: 2-4x number of CPU cores is recommended

if not hasattr(os, "sysconf"):
  workers=1
else:
  os.sysconf("SC_NPROCESSORS_ONLN")


timeout=30

# Worker class. The default "sync" is fine with nginx as a proxy
# gevent is a nice alternative if you want to serve the public from Gunicorn
# worker_class='gevent'
