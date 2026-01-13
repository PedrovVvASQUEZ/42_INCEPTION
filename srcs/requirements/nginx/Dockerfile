FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y nginx openssl \
 && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf

VOLUME ["/var/www/html"]
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
