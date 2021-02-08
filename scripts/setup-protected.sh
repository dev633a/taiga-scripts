#!/bin/bash

EVENTS_VERSION="stable"

pushd ~

cat > /tmp/.env-protected <<EOF
SECRET_KEY=$SECRET_KEY
MAX_AGE=300

EOF

if [ ! -e ~/taiga-protected ]; then
    # Initial clear
    git clone https://github.com/taigaio/taiga-protected.git taiga-protected
    pushd ~/taiga-protected
    git checkout $EVENTS_VERSION

    mv /tmp/.env-protected .
    # sudo chown -R $USER:$(id -gn $USER) /home/taiga/.config
    mkvirtualenv-if-needed taiga-protected
    source .venv/bin/activate
    pip install --upgrade pip wheel
    pip install -r requirements.txt
    popd
else
    pushd ~/taiga-protected
    git fetch
    git reset --hard origin/$EVENTS_VERSION

    sudo chown -R $USER:$(id -gn $USER) /home/taiga/.config

    popd
fi

popd
