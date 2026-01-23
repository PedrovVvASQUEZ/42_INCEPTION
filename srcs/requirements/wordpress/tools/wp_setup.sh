#!/bin/bash
set -e

WWW_DIR=/var/www/html

mkdir -p /run/php
chown -R www-data:www-data /run/php

if [ ! -f "$WWW_DIR/index.php" ]; then
  echo "Downloading WordPress..."
  rm -rf $WWW_DIR/*
  wget -q https://wordpress.org/latest.tar.gz -O /tmp/wp.tar.gz
  tar -xzf /tmp/wp.tar.gz -C /tmp
  mv /tmp/wordpress/* $WWW_DIR/
  rm -f /tmp/wp.tar.gz
  chown -R www-data:www-data $WWW_DIR
fi

if [ ! -f "$WWW_DIR/wp-config.php" ]; then
  DB_NAME=${WORDPRESS_DB_NAME}
  DB_USER=${WORDPRESS_DB_USER}
  if [ -f /run/secrets/db_password ]; then
    DB_PASSWORD="$(cat /run/secrets/db_password)"
  else
    DB_PASSWORD=${WORDPRESS_DB_PASSWORD}
  fi
  DB_HOST=${WORDPRESS_DB_HOST}

  cat > $WWW_DIR/wp-config.php <<EOF
<?php
define('DB_NAME', '${DB_NAME}');
define('DB_USER', '${DB_USER}');
define('DB_PASSWORD', '${DB_PASSWORD}');
define('DB_HOST', '${DB_HOST}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

// Authentication keys (generated securely)
EOF

  if [ -f /run/secrets/wp_keys ]; then
    WP_KEY=$(cat /run/secrets/wp_keys)
    cat >> $WWW_DIR/wp-config.php <<EOF
define('AUTH_KEY',         '${WP_KEY}');
define('SECURE_AUTH_KEY',  '${WP_KEY}');
define('LOGGED_IN_KEY',    '${WP_KEY}');
define('NONCE_KEY',        '${WP_KEY}');
define('AUTH_SALT',        '${WP_KEY}');
define('SECURE_AUTH_SALT', '${WP_KEY}');
define('LOGGED_IN_SALT',   '${WP_KEY}');
define('NONCE_SALT',       '${WP_KEY}');
EOF
  else
    cat >> $WWW_DIR/wp-config.php <<EOF
define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');
define('AUTH_SALT',        'put your unique phrase here');
define('SECURE_AUTH_SALT', 'put your unique phrase here');
define('LOGGED_IN_SALT',   'put your unique phrase here');
define('NONCE_SALT',       'put your unique phrase here');
EOF
  fi

  cat >> $WWW_DIR/wp-config.php <<EOF

if ( ! defined('ABSPATH') )
  define('ABSPATH', dirname(__FILE__) . '/');
require_once(ABSPATH . 'wp-settings.php');
EOF

  chown www-data:www-data $WWW_DIR/wp-config.php
fi

PHP_FPM_CONF="/etc/php/$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')/fpm/pool.d/www.conf"
if [ -f "$PHP_FPM_CONF" ]; then
  sed -i "s|^listen = .*|listen = 0.0.0.0:9000|" "$PHP_FPM_CONF" || true
fi

echo "Waiting for database ${DB_HOST}..."
until mysqladmin ping -hmariadb --silent; do
  sleep 0.5
done

if [ -x /usr/local/bin/wp ]; then
  cd $WWW_DIR
  if ! wp core is-installed --allow-root >/dev/null 2>&1; then
    ADMIN_USER=${WORDPRESS_ADMIN_USER}
    if [ -f /run/secrets/wp_admin_password ]; then
      ADMIN_PASS="$(cat /run/secrets/wp_admin_password)"
    else
      ADMIN_PASS=${WORDPRESS_ADMIN_PASSWORD}
    fi
    ADMIN_EMAIL=${WORDPRESS_ADMIN_EMAIL}
    SITE_URL="https://${DOMAIN_NAME}"
    
    wp core install --url="${SITE_URL}" --title="${WP_TITLE:-My WP Site}" --admin_user="${ADMIN_USER}" --admin_password="${ADMIN_PASS}" --admin_email="${ADMIN_EMAIL}" --allow-root

    if [ -n "${WORDPRESS_USER2}" ]; then
      if [ -f /run/secrets/wp_user1_password ]; then
        USER2_PASS="$(cat /run/secrets/wp_user1_password)"
      else
        USER2_PASS=${WORDPRESS_USER2_PASSWORD}
      fi
      USER2_EMAIL=${WORDPRESS_USER2_EMAIL}
      wp user create ${WORDPRESS_USER2} ${USER2_EMAIL} --user_pass=${USER2_PASS} --role=editor --allow-root || true
    fi
  fi
fi

PHP_FPM=$(which php-fpm || which php-fpm7.4 || which php-fpm8.1 || which php-fpm8.2)
exec $PHP_FPM -F
