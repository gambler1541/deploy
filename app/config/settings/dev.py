from .base import *
secrets = json.load(open(os.path.join(SECRET_DIR, 'dev.json')))
DEBUG = True

#static
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(ROOT_DIR, '.static')

MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(ROOT_DIR, '.media')

# WSGI
WSGI_APPLICATION = 'config.wsgi.dev.application'

# DB
DATABASES = secrets['DATABASES']
print(DATABASES)