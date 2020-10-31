#!/bin/bash

pushd ~

cat > /tmp/config.json <<EOF
{
    "url": "amqp://taiga:$EVENTS_PASS@localhost:5672/taiga",
    "secret": "$SECRET_KEY",
    "webSocketServer": {
        "port": 8888
    }
}

EOF

cat > /tmp/taiga-events.ini <<EOF
[watcher:taiga-events]
working_dir = /home/taiga/taiga-events
cmd = /usr/bin/coffee
args = index.coffee
uid = taiga
numprocesses = 1
autostart = true
send_hup = true
stdout_stream.class = FileStream
stdout_stream.filename = /home/taiga/logs/taigaevents.stdout.log
stdout_stream.max_bytes = 10485760
stdout_stream.backup_count = 12
stderr_stream.class = FileStream
stderr_stream.filename = /home/taiga/logs/taigaevents.stderr.log
stderr_stream.max_bytes = 10485760
stderr_stream.backup_count = 12

EOF

# Replace node packages list with updates
cat > /tmp/package.json <<EOF
{
  "name": "TaigaIO-Events",
  "version": "0.0.1",
  "description": "Taiga project management system (events)",
  "main": "index.js",
  "keywords": [
    "Taiga",
    "Agile",
    "Project Management",
    "Github"
  ],
  "author": "Kaleidos OpenSource SL",
  "license": "AGPL-3.0",
  "repository": {
    "type": "git",
    "url": "https://github.com/taigaio/taiga-events.git"
  },
  "devDependencies": {
    "gulp": "^4.0.2",
    "gulp-cache": "^0.3.0",
    "gulp-coffee": "^2.3.3",
    "gulp-coffeelint": "^0.6.0",
    "gulp-nodemon": "^2.0.4",
    "gulp-plumber": "^1.0.1"
  },
  "dependencies": {
    "amqplib": "^0.5.1",
    "base64-url": "^2.3.3",
    "bluebird": "^2.9.10",
    "minimist": "^1.2.0",
    "node-uuid": "^1.4.2",
    "winston": "^3.0.0-rc5",
    "ws": "^7.3.1"
  }
}

EOF

curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y gcc g++ make nodejs
sudo npm install -g gulp coffeescript


if [ ! -e ~/taiga-events ]; then
    # Initial clear
    git clone https://github.com/taigaio/taiga-events.git taiga-events
    pushd ~/taiga-events

    mv /tmp/config.json .
    mv /tmp/package.json .
    sudo mv /tmp/taiga-events.ini /etc/circus/conf.d/
    sudo chown -R $USER:$(id -gn $USER) /home/taiga/.config
    npm install --only=production
    popd
else
    pushd ~/taiga-events
    git fetch
    git reset --hard origin/master

    mv /tmp/config.json .
    mv /tmp/package.json .
    sudo mv /tmp/taiga-events.ini /etc/circus/conf.d/
    sudo chown -R $USER:$(id -gn $USER) /home/taiga/.config
    npm install --only=production

    popd
fi

popd
