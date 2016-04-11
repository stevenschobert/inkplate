FROM ruby:2.3

# add dumb-init for entrypoint to apps
COPY support/docker/dumb-init_1.0.1_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

# set timezone on container
ENV TZ=America/Chicago
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/inkplate /usr/src/inkplate/config /usr/src/inkplate/log
WORKDIR /usr/src/inkplate

COPY app/ app/
COPY lib/ lib/
COPY db/ db/
COPY config/ config/
COPY bootstrap.rb config.ru Gemfile Gemfile.lock Rakefile ./

ENV RACK_ENV production
ENV HOST 0.0.0.0
ENV PORT 3000
ENV SSL_PORT 3001

EXPOSE 3000
EXPOSE 3001

RUN bundle install --without development test

ENTRYPOINT [ "dumb-init" ]
