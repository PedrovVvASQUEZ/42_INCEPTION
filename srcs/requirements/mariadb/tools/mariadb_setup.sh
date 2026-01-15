#!/bin/bash
set -e

# Initialize DB directory if empty, then create database and users from secrets/env
DATADIR=/var/lib/mysql

if [ ! -d "$DATADIR/mysql" ]; then
  echo "Initializing MariaDB data directory..."
  mysqld --initialize-insecure --datadir=$DATADIR || true
fi

# Start mysqld in background to allow initial SQL setup if needed
mysqld --datadir=$DATADIR --skip-networking &
PID=$!

# wait for socket
until mysqladmin ping --silent; do
  sleep 0.5
done

# Create DB and users if not present
if [ -n "$MYSQL_DATABASE" ]; then
  echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;" | mysql || true
fi

# Get passwords from environment
ROOTPW="$MYSQL_ROOT_PASSWORD"
USERPW="$MYSQL_PASSWORD"

if [ -n "$MYSQL_USER" ]; then
  SQL="CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$USERPW'; GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '$MYSQL_USER'@'%'; FLUSH PRIVILEGES;"
  echo "$SQL" | mysql || true
fi

# If root password provided, set it
if [ -n "$ROOTPW" ]; then
  echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOTPW'; FLUSH PRIVILEGES;" | mysql || true
fi

# stop background server and exec final server in foreground
kill $PID || true
wait $PID 2>/dev/null || true

exec mysqld --datadir=$DATADIR --bind-address=0.0.0.0
