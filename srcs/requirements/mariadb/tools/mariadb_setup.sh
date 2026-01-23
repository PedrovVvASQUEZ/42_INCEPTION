#!/bin/bash
set -e

DATADIR=/var/lib/mysql

if ! id -u mysql > /dev/null 2>&1; then
  useradd -r -s /bin/false mysql
fi

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "$DATADIR/mysql" ]; then
  echo "Initializing MariaDB data directory..."
  mysql_install_db --user=mysql --datadir=$DATADIR
  chown -R mysql:mysql $DATADIR
fi

chown -R mysql:mysql $DATADIR

mysqld --datadir=$DATADIR --skip-networking --user=mysql &
PID=$!

until mysqladmin ping --silent; do
  sleep 0.5
done

if [ -n "$MYSQL_DATABASE" ]; then
  mysql -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;" 2>/dev/null || true
fi

if [ -f /run/secrets/db_root_password ]; then
  ROOTPW="$(cat /run/secrets/db_root_password)"
else
  ROOTPW="$MYSQL_ROOT_PASSWORD"
fi

if [ -f /run/secrets/db_password ]; then
  USERPW="$(cat /run/secrets/db_password)"
else
  USERPW="$MYSQL_PASSWORD"
fi

if [ -n "$MYSQL_USER" ]; then
  mysql -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$USERPW';" 2>/dev/null || true
  mysql -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '$MYSQL_USER'@'%';" 2>/dev/null || true
  mysql -e "FLUSH PRIVILEGES;" 2>/dev/null || true
fi

if [ -n "$ROOTPW" ]; then
  mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOTPW'; FLUSH PRIVILEGES;" 2>/dev/null || true
fi

kill $PID || true
wait $PID 2>/dev/null || true

exec mysqld --user=mysql --datadir=$DATADIR --bind-address=0.0.0.0
