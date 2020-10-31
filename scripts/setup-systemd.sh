#!/bin/bash

cat > /tmp/taiga.service <<EOF
[Unit]
Description=taiga_back
After=network.target

[Service]
User=taiga
Environment=PYTHONUNBUFFERED=true
WorkingDirectory=/home/taiga/taiga-back
ExecStart=/home/taiga/.virtualenvs/taiga/bin/gunicorn --workers 4 --timeout 600 -b 127.0.0.1:8001 taiga.wsgi
Restart=always
RestartSec=3

[Install]
WantedBy=default.target

EOF

cat > /tmp/taiga_celery.service <<EOF
[Unit]
Description=taiga_celery
After=network.target

[Service]
User=taiga
Environment=PYTHONUNBUFFERED=true
WorkingDirectory=/home/taiga/taiga-back
ExecStart=/home/taiga/.virtualenvs/taiga/bin/celery -A taiga worker --concurrency 4 -l INFO
Restart=always
RestartSec=3
ExecStop=/bin/kill -s TERM $MAINPID

[Install]
WantedBy=default.target

EOF

cat > /tmp/taiga_events.service <<EOF
[Unit]
Description=taiga_events
After=network.target

[Service]
User=taiga
WorkingDirectory=/home/taiga/taiga-events
ExecStart=/usr/bin/coffee index.coffee
Restart=always
RestartSec=3

[Install]
WantedBy=default.target

EOF

sudo mv /tmp/taiga.service /etc/systemd/system/
sudo mv /tmp/taiga_celery.service /etc/systemd/system/
sudo mv /tmp/taiga_events.service /etc/systemd/system/

sudo systemctl daemon-reload

sudo systemctl start taiga
sudo systemctl start taiga_celery
sudo systemctl start taiga_events

sudo systemctl enable taiga
sudo systemctl enable taiga_celery
sudo systemctl enable taiga_events
