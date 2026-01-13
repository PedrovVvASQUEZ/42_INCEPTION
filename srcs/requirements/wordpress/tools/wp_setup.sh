#!/bin/bash
set -e

WWW_DIR=/var/www/html
if [ ! -d "$WWW_DIR/index.php" ] && [ -z "$(ls -A $WWW_DIR)" ]; then
  echo "Downloading WordPress..."
  wget -q https://wordpress.org/latest.tar.gz -O /tmp/wp.tar.gz
  tar -xzf /tmp/wp.tar.gz -C /tmp
  mv /tmp/wordpress/* $WWW_DIR/
  chown -R www-data:www-data $WWW_DIR
fi

if [ ! -f "$WWW_DIR/wp-config.php" ]; then
  DB_NAME=${WORDPRESS_DB_NAME}
  DB_USER=${WORDPRESS_DB_USER}
  DB_PASSWORD_FILE=${WORDPRESS_DB_PASSWORD_FILE}
  DB_HOST=${WORDPRESS_DB_HOST}
  if [ -f "$DB_PASSWORD_FILE" ]; then
    DB_PASSWORD=$(cat $DB_PASSWORD_FILE)
  else
    DB_PASSWORD=${WORDPRESS_DB_PASSWORD}
  fi

  cat > $WWW_DIR/wp-config.php <<EOF
<?php
define('DB_NAME', '${DB_NAME}');
define('DB_USER', '${DB_USER}');
define('DB_PASSWORD', '${DB_PASSWORD}');
define('DB_HOST', '${DB_HOST}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

// Authentication keys (placeholder)
define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');
define('AUTH_SALT',        'put your unique phrase here');
define('SECURE_AUTH_SALT', 'put your unique phrase here');
define('LOGGED_IN_SALT',   'put your unique phrase here');
define('NONCE_SALT',       'put your unique phrase here');

if ( ! defined('ABSPATH') )
  define('ABSPATH', dirname(__FILE__) . '/');
require_once(ABSPATH . 'wp-settings.php');
EOF

  chown www-data:www-data $WWW_DIR/wp-config.php
fi

# Ensure php-fpm listens on TCP 9000
PHP_FPM_CONF="/etc/php/$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')/fpm/pool.d/www.conf"
if [ -f "$PHP_FPM_CONF" ]; then
  sed -i "s|^listen = .*|listen = 0.0.0.0:9000|" "$PHP_FPM_CONF" || true
fi

# Wait for MariaDB to be reachable before running WP-CLI tasks
echo "Waiting for database ${DB_HOST}..."
until mysqladmin ping -hmariadb --silent; do
  sleep 0.5
done

# Use WP-CLI to install WordPress if not already installed
if [ -x /usr/local/bin/wp ]; then
  cd $WWW_DIR
  if ! wp core is-installed --allow-root >/dev/null 2>&1; then
    ADMIN_USER=${WORDPRESS_ADMIN_USER}
    ADMIN_PASS_FILE=${WORDPRESS_ADMIN_PASSWORD_FILE}
    ADMIN_EMAIL=${WORDPRESS_ADMIN_EMAIL}
    SITE_URL=${DOMAIN_NAME}
    if [ -f "$ADMIN_PASS_FILE" ]; then
      ADMIN_PASS=$(cat $ADMIN_PASS_FILE)
    else
      ADMIN_PASS=${WORDPRESS_ADMIN_PASSWORD}
    fi
    wp core install --url="${SITE_URL}" --title="My WP Site" --admin_user="${ADMIN_USER}" --admin_password="${ADMIN_PASS}" --admin_email="${ADMIN_EMAIL}" --allow-root

    # create second user
    if [ -n "${WORDPRESS_USER2}" ]; then
      USER2_PASS_FILE=${WORDPRESS_USER2_PASSWORD_FILE}
      USER2_EMAIL=${WORDPRESS_USER2_EMAIL}
      if [ -f "$USER2_PASS_FILE" ]; then
        USER2_PASS=$(cat $USER2_PASS_FILE)
      else
        USER2_PASS=${WORDPRESS_USER2_PASSWORD}
      fi
      wp user create ${WORDPRESS_USER2} ${USER2_EMAIL} --user_pass=${USER2_PASS} --role=editor --allow-root || true
    fi
  fi
fi

exec php-fpm -F
