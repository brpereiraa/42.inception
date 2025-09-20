#!/bin/bash

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
while ! nc -z mariadb 3306; do
  sleep 1
done
echo "MariaDB is ready!"

cd /var/www/html

# Download and setup WordPress only if not already done
if [ ! -f wp-config.php ]; then
    echo "Setting up WordPress..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    ./wp-cli.phar core download --allow-root
    ./wp-cli.phar config create --dbname=wordpress --dbuser=wpuser --dbpass=password --dbhost=mariadb --allow-root
    ./wp-cli.phar core install --url=localhost --title=testing --admin_user=admin --admin_password=admin --admin_email=admin@admin.com --allow-root
	./wp-cli.phar user create "USER" "USERMAIL" --role=author --user_pass=pass --allow-root
    echo "WordPress setup completed!"
else
    echo "WordPress already configured, skipping setup..."
fi

# Start PHP-FPM
echo "Starting PHP-FPM..."
php-fpm8.2 -F
