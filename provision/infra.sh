#!/bin/bash

set -e

[ -z "$DB_ROOT_PASSWORD" ] && echo "Need to set DB_ROOT_PASSWORD" && exit 1;

sudo apt-get update
sudo apt-get install -y psmisc vim

if [ -f /etc/init.d/redis-server ]; then
  echo "Redis is already installed"
  sudo service redis-server start
else
  sudo apt-get install -y redis-server
  cat <<EOF | sudo tee -a /etc/redis/redis.conf
bind 0.0.0.0
EOF
  sudo service redis-server restart
fi

if [ -f /etc/init.d/mysql ]; then
  echo "MySQL already installed"
  service mysql start
else
  debconf-set-selections <<< "mysql-server-5.5> mysql-server/root_password password $DB_ROOT_PASSWORD"
  debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password_again password $DB_ROOT_PASSWORD"
  apt-get install -y mysql-server
  service mysql stop

  mkdir -p /data/mysql
  chown -R mysql:mysql /data/mysql

  # Listen on all addresses:
  sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/my.cnf

  # Data dir is /data/mysql:
  sed -i 's#/var/lib/mysql#/data/mysql#' /etc/mysql/my.cnf

  # We have to disable apparmor in order for the /data directory to be used by MySQL:
  # TODO: Make it possible to run apparmor anyway:
  if [ -e /etc/init.d/apparmor ]; then
    ln -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/usr.sbin.mysqld
    service apparmor restart
  else
    echo "No apparmor -- skipping"
  fi
  mysql_install_db --user=mysql --basedir=/usr --datadir=/data/mysql

  export DEBIAN_FRONTEND=noninteractive
  debconf-set-selections <<< "mysql-server-5.5> mysql-server/root_password password $DB_ROOT_PASSWORD"
  debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password_again password $DB_ROOT_PASSWORD"
  dpkg-reconfigure mysql-server-5.5 && service mysql start
fi

# allow remote connections:
mysql -u root -p$DB_ROOT_PASSWORD mysql -e 'update user set host = "%" where user = "root" and host = "127.0.0.1"; flush privileges;'

