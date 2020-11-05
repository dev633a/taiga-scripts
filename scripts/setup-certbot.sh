# setup-certbot.sh
# install certbot and configure nginx

if [ ! -e ~/.setup/certbot ]; then

  touch ~/.setup/certbot

  if [ "$TAIGA_ENCRYPT" == "True" ]; then
    sudo /usr/bin/snap install core; sudo snap refresh core
    sudo /usr/bin/snap install --classic certbot
    sudo ln -s /snap/bin/certbot /usr/bin/certbot
    sudo apt-get install  python3-certbot-nginx -y
    sudo certbot --non-interactive --nginx -d $TAIGA_DOMAIN --agree-tos --email $TAIGA_SSL_EMAIL
  fi

fi
