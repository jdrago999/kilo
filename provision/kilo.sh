#!/bin/bash

set -e

sudo apt-get update
sudo apt-get -y autoremove
sudo apt-get install -y \
  vim \
  wget \
  ruby2.0 \
  ruby2.0-dev \
  build-essential \
  curl \
  git \
  libffi-dev \
  libcrypto++-dev \
  nginx \
  libssl-dev \
  libmysql++-dev \
  nodejs \
  graphviz \
  nscd

# We need to update /etc/resolv.conf:
cat <<EOF | sudo tee /etc/resolv.conf
nameserver 8.8.8.8
EOF
sudo service nscd restart
sudo ln -sf /usr/bin/ruby2.0 /usr/bin/ruby && sudo ln -sf /usr/bin/gem2.0 /usr/bin/gem
if ! gem list | grep bundler; then
  sudo gem install bundler --no-ri --no-rdoc
fi

# Setup nginx default site config:
( echo '<% installation_path="/var/www/kilo" %>' && cat provision/templates/nginx.conf.erb) | erb | sudo tee /etc/nginx/sites-available/default > /dev/null

# Self-signed cert:
if [ ! -d /etc/nginx/certs/kilo ]; then
  sudo mkdir -p /etc/nginx/certs/kilo
  sudo openssl genrsa -out /etc/nginx/certs/kilo/server.key 2048
  sudo openssl req -new -key /etc/nginx/certs/kilo/server.key -subj "/C=US/ST=California/L=San Francisco/O=KILO/OU=Engineering/CN=kilo" -out /etc/nginx/certs/kilo/server.csr
  sudo openssl x509 -req -days 365 -in /etc/nginx/certs/kilo/server.csr -signkey /etc/nginx/certs/kilo/server.key -out /etc/nginx/certs/kilo/server.crt
fi

# Restart nginx:
sudo service nginx restart

echo "
MYSQL_HOSTNAME=$INFRA_PORT_3306_TCP_ADDR
MYSQL_USERNAME=root
MYSQL_PASSWORD=$MYSQL_PASSWORD
" > .env

bundle
