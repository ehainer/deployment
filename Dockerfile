FROM ruby:2.5.1-alpine

LABEL maintainer="Eric Hainer <eric@commercekitchen.com>"

ENV APP_ROOT=/home/rails/app \
    NPM_ROOT=/home/rails/.npm \
    BUNDLE_JOBS=20 \
    RUN_DEPENDENCIES="nodejs nodejs-npm nginx gnupg grep ca-certificates sqlite-dev libressl tzdata bash bash-doc bash-completion" \
    BUILD_DEPENDENCIES="build-base ruby-dev git wget curl-dev linux-headers libxml2-dev libressl-dev" \
    RAILS_ENV=development

ENV NODE_PATH=$APP_ROOT/node_modules \
    NODE_BIN=$NPM_ROOT/bin \
    BUNDLE_PATH=$APP_ROOT/bundle \
    BUNDLE_BIN=$APP_ROOT/bundle/bin

ENV PATH="${BUNDLE_BIN}:${NODE_BIN}:${PATH}"

RUN addgroup -S rails && adduser -S -G rails rails \
 && addgroup -S nginx && adduser -S -G nginx nginx

COPY --chown=rails:rails . $APP_ROOT

WORKDIR $APP_ROOT

RUN apk update \
 && apk upgrade \
 && apk add --update $RUN_DEPENDENCIES \
 && apk add --virtual dependencies $BUILD_DEPENDENCIES \
 && npm config set prefix $NPM_ROOT \
 && npm config get prefix \
 && npm install -g yarn \
 && npm install -g heroku \
# && bundle install --deployment --no-cache --path=$BUNDLE_PATH --binstubs=$BUNDLE_BIN --jobs=$BUNDLE_JOBS --without=development test \
 && apk del dependencies \
 && rm -rf /usr/lib/ruby/gems/*/cache/* /var/cache/apk/* /tmp/* /var/tmp/* \
 && mkdir -p $APP_ROOT/shared/pids \
 && mkdir -p $APP_ROOT/shared/sockets \
 && mkdir -p /var/run
# && bundle exec rake assets:precompile

COPY docker/etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
COPY docker/etc/ssl/certs/localhost.crt /etc/ssl/certs/localhost.crt
COPY docker/etc/ssl/certs/localhost.key /etc/ssl/certs/localhost.key
# COPY .netrc.gpg /root/.netrc.gpg

RUN gpg --import $APP_ROOT/public.key
RUN gpg --import $APP_ROOT/private.key
RUN gpg --sign-key eric@commercekitchen.com
