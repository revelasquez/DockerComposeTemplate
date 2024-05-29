FROM nginx:stable-alpine

ARG UID
ARG GID

ENV UID=1000
ENV GID=1000

# MacOS staff group's gid is 20, so is the dialout group in alpine linux. We're not using it, let's just remove it.
RUN delgroup dialout

RUN addgroup -g ${GID} --system laravel
RUN adduser -G laravel --system -D -s /bin/sh -u ${UID} laravel
RUN sed -i "s/user  nginx/user laravel/g" /etc/nginx/nginx.conf

ADD /default.conf /etc/nginx/conf.d/

RUN mkdir -p /var/www/html