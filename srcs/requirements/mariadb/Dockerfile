FROM debian:12.6

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y mariadb-server procps \
 && rm -rf /var/lib/apt/lists/*

COPY tools/mariadb_setup.sh /usr/local/bin/mariadb_setup.sh
RUN chmod +x /usr/local/bin/mariadb_setup.sh

VOLUME ["/var/lib/mysql"]
EXPOSE 3306

CMD ["/usr/local/bin/mariadb_setup.sh"]
