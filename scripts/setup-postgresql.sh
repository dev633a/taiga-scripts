# postgresql.sh

function createdb-if-needed {
    for dbname in $@; do
        $(psql -l | grep -q "$dbname") || createdb "$dbname"
    done
}

function dropdb-if-needed {
    for dbname in $@; do
        $(psql -l | grep -q "$dbname") && dropdb "$dbname"
    done
}

if [ ! -e ~/.setup/postgresql ]; then
    apt-install-if-needed postgresql-12 postgresql-contrib \
        postgresql-doc-12 postgresql-server-dev-12

    sudo pg_ctlcluster 12 main start
    sudo -u postgres createuser --superuser $USER &> /dev/null
    sudo -u postgres createdb taiga -O $USER --encoding='utf-8' --locale=en_US.utf8 --template=template0 &> /dev/null
    sudo -u postgres psql -c "ALTER USER $USER WITH PASSWORD 'taiga';"

    touch ~/.setup/postgresql
fi
