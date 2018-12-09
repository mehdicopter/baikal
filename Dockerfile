FROM debian:stable-slim AS builder

ENV VERSION 0.4.6

ADD https://github.com/sabre-io/Baikal/releases/download/$VERSION/baikal-$VERSION.zip /tmp/baikal.zip
RUN apt-get update && apt-get install -y unzip && unzip -q /tmp/baikal.zip -d /tmp

FROM nginx:latest
LABEL maintainer="contact@mahfoudi.me"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
      php7.0-fpm \
      php7.0-mbstring \
      php7.0-xml \
      php7.0-sqlite \
      && rm -rf /var/lib/apt/lists/* \
      && sed -i 's/www-data/nginx/' /etc/php/7.0/fpm/pool.d/www.conf

COPY --from=builder /tmp/baikal /var/www/baikal
RUN chown -R nginx:nginx /var/www/baikal
COPY files/nginx.conf /etc/nginx/conf.d/default.conf

VOLUME /var/www/baikal/Specific
CMD /etc/init.d/php7.0-fpm start && chown -R nginx:nginx /var/www/baikal/Specific && nginx -g "daemon off;"