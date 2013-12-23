#!/bin/bash

echo "Updating apt repositories"
sudo apt-get update -qq

echo "Installing vim, make"
sudo apt-get install -qq -y --force-yes vim make python-software-properties

echo "Installing postgres"
if [ ! -e "/etc/apt/sources.list.d/postgres.list" ] ; then
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" >> /etc/apt/sources.list.d/postgres.list'
    wget -q -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    sudo apt-get update -qq
    sudo apt-get install -qq -y --force-yes postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3 libpq-dev
    echo "postgres:postgres" | sudo chpasswd
    sudo -u postgres -s psql -d template1 -c "ALTER USER postgres WITH PASSWORD 'postgres';"
    sudo -su postgres createdb --template=template0 --encoding='UTF-8' --lc-collate='en_US.UTF-8' --lc-ctype='en_US.UTF-8' project_dev
    sudo -su postgres createdb --template=template0 --encoding='UTF-8' --lc-collate='en_US.UTF-8' --lc-ctype='en_US.UTF-8' project_test
    sudo sh -c 'echo "host    all    all    0.0.0.0/0    md5" >> /etc/postgresql/9.3/main/pg_hba.conf'
    sudo sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/9.3/main/postgresql.conf
    sudo service postgresql restart
fi

echo "Installing rabbitmq"
if [ ! -e "/etc/apt/sources.list.d/rabbitmq.list" ] ; then
    sudo sh -c 'echo "deb http://www.rabbitmq.com/debian/ testing main" >> /etc/apt/sources.list.d/rabbitmq.list'
    wget -q -O - http://www.rabbitmq.com/rabbitmq-signing-key-public.asc | sudo apt-key add -
    sudo apt-get update -qq
    sudo apt-get install -y --force-yes rabbitmq-server
fi

echo "Adding dotdeb repo"
if [ ! -e "/etc/init.d/redis-server" ] ; then
    sudo add-apt-repository ppa:chris-lea/redis-server
    sudo apt-get update -qq
    sudo apt-get install -y --force-yes redis-server
    sudo sed -i 's/bind 127.0.0.1/#bind 127.0.0.1/g' /etc/redis/redis.conf
    sudo /etc/init.d/redis-server restart
fi

exit
