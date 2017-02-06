#!/bin/bash

echo "This script prepare a Titan Framework's deployment environment."

echo "Starting script..."

echo "Updating and upgrading..."

apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade

echo "Done!"

echo "Adding Dotdeb (http://dotdeb.org) to sources of APT..."

echo "deb http://packages.dotdeb.org jessie all" | tee -a /etc/apt/sources.list.d/dotdeb.list
echo "deb-src http://packages.dotdeb.org jessie all" | tee -a /etc/apt/sources.list.d/dotdeb.list

wget -qO - http://www.dotdeb.org/dotdeb.gpg | apt-key add -

apt-get -y update

echo "Done!"

echo "Install a lot of dependencies..."

echo "postfix postfix/mailname string localhost" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections

DEBIAN_FRONTEND=noninteractive apt-get install -y antiword aptitude build-essential bzip2 curl default-jdk git libav-tools locales locate mailutils memcached nginx ntpdate php7.0-fpm php7.0-cli php7.0-curl php7.0-dev php7.0-gd php7.0-imagick php7.0-ldap php7.0-mbstring php7.0-mcrypt php7.0-memcached php7.0-pgsql php7.0-sqlite php-pear postfix postgresql-9.4 subversion xpdf-utils unzip vim

echo "Done!"

echo "Configuring locales..."

locale-gen "en_US.UTF-8"
locale-gen "es_ES.UTF-8"
locale-gen "pt_BR.UTF-8"

echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale

dpkg-reconfigure --frontend=noninteractive locales

echo "Done!"

echo "Installing PHP Composer..."

curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

echo "Done!"

echo "Cleaning apt-get..."

apt-get autoremove
apt-get clean -y
apt-get autoclean -y

find /var/lib/apt -type f | xargs rm -f

find /var/lib/doc -type f | xargs rm -f

echo "Done!"

echo "Configuring services..."

echo "PostgreSQL..."

wget -qO http://www.titanframework.com/environment/settings/pg_hba.conf /etc/postgresql/9.4/main/pg_hba.conf

wget -qO http://www.titanframework.com/environment/settings/postgresql.conf /etc/postgresql/9.4/main/postgresql.conf

/etc/init.d/postgresql restart

echo "Done!"

echo "PHP 7.0 FPM..."

wget -qO http://www.titanframework.com/environment/settings/php-fpm.ini /etc/php/7.0/fpm/php.ini

wget -qO http://www.titanframework.com/environment/settings/php-cli.ini /etc/php/7.0/cli/php.ini

wget -qO http://www.titanframework.com/environment/settings/php-www.conf /etc/php/7.0/fpm/pool.d/www.conf

/etc/init.d/php7.0-fpm restart

echo "Done!"

echo "Nginx..."

rm -rf /var/www/html

mkdir -p /var/www/log

wget -qO http://www.titanframework.com/environment/settings/nginx-default /etc/nginx/sites-available/default

/etc/init.d/nginx restart

echo "Done!"

echo "SSH..."

wget -qO http://www.titanframework.com/environment/settings/sshd_config /etc/ssh/sshd_config

/etc/init.d/ssh restart

echo "Done!"

echo "CRON..."

wget -qO http://www.titanframework.com/environment/settings/cron /etc/cron.d/titan

/etc/init.d/cron reload
/etc/init.d/cron restart

echo "Done!"

echo "Getting Titan Framework..."

composer create-project titan-framework/install /var/www/titan

chown -R root:staff /var/www/titan
find /var/www/titan -type d -exec chmod 775 {} \;
find /var/www/titan -type f -exec chmod 664 {} \;

echo "Done!"

echo "Runnig 'updatedb' command (for locate)..."

updatedb

echo "All done!"

echo "Thanks for using Titan Framework! Enjoy it ;-)"

echo "http://titanframework.com"