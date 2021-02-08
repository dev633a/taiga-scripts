#!/bin/bash

cat > /tmp/taiga.service <<EOF
[Unit]
Description=taiga_back
After=network.target

[Service]
User=taiga
WorkingDirectory=/home/taiga/taiga-back
ExecStart=/home/taiga/taiga-back/.venv/bin/gunicorn --workers 4 --timeout 60 --log-level=info --access-logfile - --bind 0.0.0.0:8001 taiga.wsgi
Restart=always
RestartSec=3

Environment=PYTHONUNBUFFERED=true
Environment=DJANGO_SETTINGS_MODULE=settings.config

[Install]
WantedBy=default.target
EOF

cat > /tmp/taiga-events.service <<EOF
[Unit]
Description=taiga_events
After=network.target

[Service]
User=taiga
WorkingDirectory=/home/taiga/taiga-events
ExecStart=npm run start:production
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
EOF

cat > /tmp/taiga-async.service <<EOF
[Unit]
Description=taiga_async
After=network.target

[Service]
User=taiga
WorkingDirectory=/home/taiga/taiga-back
ExecStart=/home/taiga/taiga-back/.venv/bin/celery -A taiga.celery worker --concurrency 4 -l INFO
Restart=always
RestartSec=3
ExecStop=/bin/kill -s TERM $MAINPID

Environment=PYTHONUNBUFFERED=true
Environment=DJANGO_SETTINGS_MODULE=settings.config

[Install]
WantedBy=default.target
EOF

cat > /tmp/taiga-protected.service <<EOF
[Unit]
Description=taiga_protected
After=network.target

[Service]
User=taiga
WorkingDirectory=/home/taiga/taiga-protected
ExecStart=/home/taiga/taiga-protected/.venv/bin/gunicorn --workers 4 --timeout 60 --log-level=info --access-logfile - --bind 0.0.0.0:8003 server:app
Restart=always
RestartSec=3

Environment=PYTHONUNBUFFERED=true

[Install]
WantedBy=default.target
EOF

sudo mv /tmp/taiga.service /etc/systemd/system/
sudo mv /tmp/taiga-protected.service /etc/systemd/system/
sudo mv /tmp/taiga-async.service /etc/systemd/system/
sudo mv /tmp/taiga-events.service /etc/systemd/system/

sudo systemctl daemon-reload

sudo systemctl start taiga
sudo systemctl start taiga-async
sudo systemctl start taiga-protected
sudo systemctl start taiga-events

sudo systemctl enable taiga
sudo systemctl enable taiga-async
sudo systemctl enable taiga-protected
sudo systemctl enable taiga-events
