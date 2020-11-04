#!/bin/bash

BACKEND_VERSION="stable"

pushd ~

cat > /tmp/settings.py <<EOF
from .common import *

MEDIA_URL = "$TAIGA_SCHEME://$TAIGA_DOMAIN/media/"
STATIC_URL = "$TAIGA_SCHEME://$TAIGA_DOMAIN/static/"

# This should change if you want generate urls in emails
# for external dns.
SITES["front"]["domain"] = "$TAIGA_DOMAIN"

SECRET_KEY = "$SECRET_KEY"
DEBUG = False
PUBLIC_REGISTER_ENABLED = $TAIGA_PUBLIC_REGISTER_ENABLED

DEFAULT_FROM_EMAIL = "no-reply@example.com"
SERVER_EMAIL = DEFAULT_FROM_EMAIL

#EMAIL_BACKEND = "django.core.mail.backends.smtp.EmailBackend"
#EMAIL_USE_TLS = False
#EMAIL_HOST = "localhost"
#EMAIL_HOST_USER = ""
#EMAIL_HOST_PASSWORD = ""
#EMAIL_PORT = 25

EVENTS_PUSH_BACKEND = "taiga.events.backends.rabbitmq.EventsPushBackend"
EVENTS_PUSH_BACKEND_OPTIONS = {"url": "amqp://taiga:$EVENTS_PASS@localhost:5672/taiga"}


#########################################
## THROTTLING
#########################################

#REST_FRAMEWORK["DEFAULT_THROTTLE_RATES"] = {
#    "anon-write": "20/min",
#    "user-write": None,
#    "anon-read": None,
#    "user-read": None,
#    "import-mode": None,
#    "import-dump-mode": None,
#    "create-memberships": None,
#    "login-fail": None,
#    "register-success": None,
#    "user-detail": None,
#    "user-update": None,
#}

# This list should contain:
#  - Taiga users IDs
#  - Valid clients IP addresses (X-Forwarded-For header)
#REST_FRAMEWORK["DEFAULT_THROTTLE_WHITELIST"] = []

# LIMIT ALLOWED DOMAINS FOR REGISTER AND INVITE
# None or [] values in USER_EMAIL_ALLOWED_DOMAINS means allow any domain
#USER_EMAIL_ALLOWED_DOMAINS = None

# PUCLIC OR PRIVATE NUMBER OF PROJECT PER USER
#MAX_PRIVATE_PROJECTS_PER_USER = None # None == no limit
#MAX_PUBLIC_PROJECTS_PER_USER = None # None == no limit
#MAX_MEMBERSHIPS_PRIVATE_PROJECTS = None # None == no limit
#MAX_MEMBERSHIPS_PUBLIC_PROJECTS = None # None == no limit

#########################################
## FEEDBACK
#########################################

# Note: See config in taiga-front too
#FEEDBACK_ENABLED = True
#FEEDBACK_EMAIL = "support@taiga.io"

#########################################
## STATS
#########################################

#STATS_ENABLED = False
#STATS_CACHE_TIMEOUT = 60*60  # In second


#########################################
## CELERY
#########################################
# Set to True to enable celery and work in async mode or False
# to disable it and work in sync mode. You can find the celery
# settings in settings/celery.py and settings/celery-local.py
#CELERY_ENABLED = True


#########################################
## IMPORTERS
#########################################

# Configuration for the GitHub importer
# Remember to enable it in the front client too.
#IMPORTERS["github"] = {
#    "active": True, # Enable or disable the importer
#    "client_id": "XXXXXX_get_a_valid_client_id_from_github_XXXXXX",
#    "client_secret": "XXXXXX_get_a_valid_client_secret_from_github_XXXXXX"
#}

# Configuration for the Trello importer
# Remember to enable it in the front client too.
#IMPORTERS["trello"] = {
#    "active": True, # Enable or disable the importer
#    "api_key": "XXXXXX_get_a_valid_api_key_from_trello_XXXXXX",
#    "secret_key": "XXXXXX_get_a_valid_secret_key_from_trello_XXXXXX"
#}

# Configuration for the Jira importer
# Remember to enable it in the front client too.
#IMPORTERS["jira"] = {
#    "active": True, # Enable or disable the importer
#    "consumer_key": "XXXXXX_get_a_valid_consumer_key_from_jira_XXXXXX",
#    "cert": "XXXXXX_get_a_valid_cert_from_jira_XXXXXX",
#    "pub_cert": "XXXXXX_get_a_valid_pub_cert_from_jira_XXXXXX"
#}

# Configuration for the Asana importer
# Remember to enable it in the front client too.
#IMPORTERS["asana"] = {
#    "active": True, # Enable or disable the importer
#    "callback_url": "{}://{}/project/new/import/asana".format(SITES["front"]["scheme"],
#                                                              SITES["front"]["domain"]),
#    "app_id": "XXXXXX_get_a_valid_app_id_from_asana_XXXXXX",
#    "app_secret": "XXXXXX_get_a_valid_app_secret_from_asana_XXXXXX"
#}


EOF

if [ ! -e ~/taiga-back ]; then
  createdb-if-needed taiga
  git clone https://github.com/taigaio/taiga-back.git taiga-back

  pushd ~/taiga-back
  git checkout -f stable

  rabbit-create-user-if-needed taiga $EVENTS_PASS  # username, password
  rabbit-create-vhost-if-needed taiga
  rabbit-set-permissions taiga taiga ".*" ".*" ".*" # username, vhost, configure, read, write
  mkvirtualenv-if-needed taiga

  # Settings
  mv /tmp/settings.py settings/local.py
  workon taiga

  pip install -r requirements.txt
  python manage.py migrate --noinput
  python manage.py compilemessages
  python manage.py collectstatic --noinput
  python manage.py loaddata initial_user
  python manage.py loaddata initial_project_templates

  # Import sample projects unless explicitly set to "False" in setup-vars
  if [ "$TAIGA_SAMPLE_DATA" != "False" ] ; then
    python manage.py sample_data
    python manage.py rebuild_timeline --purge
  fi

  deactivate
  popd
else
  pushd ~/taiga-back
  git fetch
  git checkout -f stable
  git reset --hard origin/stable

  workon taiga
  pip install -r requirements.txt
  python manage.py migrate --noinput
  python manage.py compilemessages
  python manage.py collectstatic --noinput
  popd
fi

popd
