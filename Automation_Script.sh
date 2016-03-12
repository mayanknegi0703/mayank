#!bin/bash 
sudo apt-get update
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password open' 
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password open' 
sudo apt-get -y install mysql-server
sudo apt-get -y install php5-gd libssh2-php php5-common php5-cli php5 php5-fpm nginx php5-mysql php5-mcrypt mysql-common mysql-client
mysql -u root -popen -e "create database wp;"
mysql -u root -popen -e "CREATE USER wpuser IDENTIFIED BY 'password';"
mysql -u root -popen -e "GRANT ALL PRIVILEGES ON wp.* TO wpuser;"
mysql -u root -popen -e "FLUSH PRIVILEGES;"
wget http://wordpress.org/latest.tar.gz
sudo tar xzvf latest.tar.gz
cd ./wordpress
sudo cp wp-config-sample.php wp-config.php
sudo sed -i 's/database_name_here/wp/' wp-config.php
sudo sed -i 's/username_here/wpuser/' wp-config.php
sudo sed -i 's/password_here/password/' wp-config.php
cd ..
sudo rsync -avP ./wordpress/ /usr/share/nginx/www/
sudo sed -i '/\s*#.*$/d' /etc/nginx/sites-enabled/default
sudo sed -i '/server {/a listen 80;' /etc/nginx/sites-enabled/default
sudo sed -i 's/server_name _/server_name localhost/' /etc/nginx/sites-enabled/default
sudo sed -i 's/index index.html /index index.php /' /etc/nginx/sites-enabled/default
sudo sed -i '15,21 d' /etc/nginx/sites-enabled/default
sudo sed -i '/location /a fastcgi_split_path_info ^(.+\.php)(/.+)$;\nfastcgi_pass unix:/var/run/php5-fpm.sock;\nfastcgi_index index.php;\ninclude fastcgi_params;' /etc/nginx/sites-enabled/default
sudo sed -i 's/location \/ {/location ~ \\.php$ {/ ' /etc/nginx/sites-enabled/default
sudo sed -i 's/listen = 127.0.0.1:9000/listen = \/var\/run\/php5-fpm.sock/' /etc/php5/fpm/pool.d/www.conf
sudo sed -i 's/;listen.group = www-data/listen.group = www-data/' /etc/php5/fpm/pool.d/www.conf
sudo sed -i 's/;listen.owner = www-data/listen.owner = www-data/' /etc/php5/fpm/pool.d/www.conf
sudo sed -i 's/;listen.mode = 0660/listen.mode = 0660/' /etc/php5/fpm/pool.d/www.conf
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php5/fpm/php.ini
sudo sed -i 's/try_files $uri $uri\/ \/index.html;/try_files $uri $uri\/ \/index.php;/' /etc/nginx/sites-enabled/default
sudo service php5-fpm restart
sudo service nginx restart

