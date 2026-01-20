#!/bin/bash
set -e

# Initialize DB directory if empty, then create database and users from secrets/env
DATADIR=/var/lib/mysql

# Create mysql user if not exists
if ! id -u mysql > /dev/null 2>&1; then
  useradd -r -s /bin/false mysql
fi

# Create socket directory
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "$DATADIR/mysql" ]; then
  echo "Initializing MariaDB data directory..."
  mysql_install_db --user=mysql --datadir=$DATADIR
  chown -R mysql:mysql $DATADIR
fi

# Ensure correct ownership
chown -R mysql:mysql $DATADIR

# Start mysqld in background to allow initial SQL setup if needed
mysqld --datadir=$DATADIR --skip-networking --user=mysql &
PID=$!

# wait for socket
until mysqladmin ping --silent; do
  sleep 0.5
done

# Create DB and users if not present
if [ -n "$MYSQL_DATABASE" ]; then
  mysql -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;" 2>/dev/null || true
fi

# Get passwords from environment
ROOTPW="$MYSQL_ROOT_PASSWORD"
USERPW="$MYSQL_PASSWORD"

if [ -n "$MYSQL_USER" ]; then
  mysql -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$USERPW';" 2>/dev/null || true
  mysql -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '$MYSQL_USER'@'%';" 2>/dev/null || true
  mysql -e "FLUSH PRIVILEGES;" 2>/dev/null || true
fi

# If root password provided, set it
if [ -n "$ROOTPW" ]; then
  mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOTPW'; FLUSH PRIVILEGES;" 2>/dev/null || true
fi

# stop background server and exec final server in foreground
kill $PID || true
wait $PID 2>/dev/null || true

exec mysqld --user=mysql --datadir=$DATADIR --bind-address=0.0.0.0
