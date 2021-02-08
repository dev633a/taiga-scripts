#!/bin/bash

EVENTS_VERSION="stable"

pushd ~

cat > /tmp/.env <<EOF
RABBITMQ_URL="amqp://taiga:$EVENTS_PASS@127.0.0.1:5672/taiga"
SECRET="$SECRET_KEY"
WEB_SOCKET_SERVER_PORT=8888
APP_PORT=3023

EOF


curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g gulp coffeescript


if [ ! -e ~/taiga-events ]; then
    # Initial clear
    git clone https://github.com/taigaio/taiga-events.git taiga-events
    pushd ~/taiga-events
    git checkout $EVENTS_VERSION

    mv /tmp/.env .
    sudo chown -R $USER:$(id -gn $USER) /home/taiga/.config
    npm install
    popd
else
    pushd ~/taiga-events
    git fetch
    git reset --hard origin/$EVENTS_VERSION

    sudo chown -R $USER:$(id -gn $USER) /home/taiga/.config
    npm install --only=production

    popd
fi

popd
