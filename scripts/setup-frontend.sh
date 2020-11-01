#!/bin/bash

FRONTEND_VERSION="stable"

pushd ~

cat > /tmp/conf.json <<EOF
{
    "api": "/api/v1/",
    "eventsUrl": "$TAIGA_EVENTS_SCHEME://$TAIGA_DOMAIN/events",
    "eventsMaxMissedHeartbeats": 5,
    "eventsHeartbeatIntervalTime": 60000,
    "eventsReconnectTryInterval": 10000,
    "debug": "false",
    "publicRegisterEnabled": $TAIGA_PUBLIC_REGISTER_ENABLED_FRONT,
    "feedbackEnabled": false,
    "privacyPolicyUrl": null,
    "termsOfServiceUrl": null,
    "maxUploadFileSize": null,
    "gitHubClientId": null,
    "contribPlugins": [],
    "gravatar": false
}
EOF


if [ ! -e ~/taiga-front ]; then
    # Initial clear
    git clone https://github.com/taigaio/taiga-front-dist.git taiga-front
    pushd ~/taiga-front
    git checkout -f stable

    mv /tmp/conf.json dist/

    popd
else
    pushd ~/taiga-front
    git fetch
    git checkout -f stable
    git reset --hard origin/stable
    popd
fi

popd
