if [ ! -e ~/.setup/buildessential ]; then
    touch ~/.setup/buildessential

    apt-install-if-needed automake wget curl gettext \
    build-essential libgdbm-dev  binutils-doc autoconf flex gunicorn \
    bison libjpeg-dev libzmq3-dev libfreetype6-dev zlib1g-dev \
    libncurses5-dev libtool libxslt1-dev libxml2-dev libffi-dev \
    libssl-dev git pwgen tmux

fi
