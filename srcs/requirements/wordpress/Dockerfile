FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y php-fpm php-mysql php-xml php-curl php-mbstring php-gd mariadb-client wget unzip curl ca-certificates less \
 && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
 && chmod +x /usr/local/bin/wp

COPY tools/wp_setup.sh /usr/local/bin/wp_setup.sh

RUN chmod +x /usr/local/bin/wp_setup.sh

VOLUME ["/var/www/html"]

EXPOSE 9000

CMD ["/usr/local/bin/wp_setup.sh"]
