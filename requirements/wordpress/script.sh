#!/bin/bash

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
while ! nc -z "$DB_HOST" 3306; do
  sleep 1
done
echo "MariaDB is ready!"

cd /var/www/html

if [ ! -f wp-config.php ]; then
    echo "Setting up WordPress..."

    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar

    ./wp-cli.phar core download --allow-root

    ./wp-cli.phar config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$DB_HOST" \
        --allow-root

    ./wp-cli.phar core install \
        --url="$DOMAIN" \
        --title="testing" \
        --admin_user="$ADMIN_USER" \
        --admin_password="$ADMIN_PASSWORD" \
        --admin_email="$ADMIN_EMAIL" \
        --allow-root

    ./wp-cli.phar user create \ 
        "$WP_USER" \
        "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author \
        --allow-root

    echo "WordPress setup completed!"
else
    echo "WordPress already configured, skipping setup..."
fi

echo "Starting PHP-FPM..."
php-fpm8.2 -F
