#!/bin/bash

FRONTEND_VERSION="stable"

pushd ~

cat > /tmp/conf.json <<EOF
{
	"api": "$TAIGA_SCHEME://$TAIGA_DOMAIN/api/v1/",
	"eventsUrl": "$TAIGA_EVENTS_SCHEME://$TAIGA_DOMAIN/events",
	"debug": "false",
	"publicRegisterEnabled": true,
	"feedbackEnabled": true,
	"privacyPolicyUrl": null,
	"termsOfServiceUrl": null,
	"GDPRUrl": null,
	"maxUploadFileSize": null,
	"contribPlugins": [],
  "gravatar": false,
  "importers": []
}
EOF


if [ ! -e ~/taiga-front ]; then
    # Initial clear
    git clone https://github.com/taigaio/taiga-front-dist.git taiga-front
    pushd ~/taiga-front
    git checkout -f $FRONTEND_VERSION

    mv /tmp/conf.json dist/

    popd
else
    pushd ~/taiga-front
    git fetch
    git checkout -f $FRONTEND_VERSION
    git reset --hard origin/$FRONTEND_VERSION
    popd
fi

popd
