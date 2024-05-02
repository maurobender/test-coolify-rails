FROM ruby:3.0.1 AS base

ARG DEBIAN_FRONTEND=noninteractive

ENV SRCPATH=/usr/src/app
ENV USR=rails-app
ENV SHELL=/bin/bash

WORKDIR $SRCPATH
RUN useradd -m $USR

# Install NodeJS, Yarn, Cron, postgresql-client and Vim
RUN apt-get update -qq && apt-get install -y gnupg2
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN wget https://dl.yarnpkg.com/debian/pubkey.gpg 
RUN cat pubkey.gpg | apt-key add -
RUN rm pubkey.gpg 

RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y --allow-unauthenticated nodejs yarn cron vim postgresql-client-13 ffmpeg


RUN mkdir -p tmp/pids tmp/storage storage log
RUN chown -R $USR:$USR tmp storage log

USER $USR:$USR

COPY --chown=$USR:$USR . $SRCPATH

RUN gem update --system && \
    gem install bundler:2.4.22 &&\
    bundle config set force_ruby_platform true

RUN bundle install -j $(nproc)
RUN yarn install

EXPOSE 3000
CMD ["bundle", "exec", "rails", "s", "-p", "3000"]