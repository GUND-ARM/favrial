ARG APPROOT="/opt/app"

FROM ruby:3.1.2-slim-bullseye as base

ARG APPROOT
ENV DEBIAN_FRONTEND noninteractive
ENV RAILS_LOG_TO_STDOUT="1"

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install libpq5 libvips42 build-essential libpq-dev git curl && \
    apt-get clean

# install nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_19.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean

# enable yarn
RUN corepack enable

WORKDIR ${APPROOT}
COPY Gemfile ${APPROOT}
COPY Gemfile.lock ${APPROOT}
COPY .irbrc /root/
RUN gem install bundler && bundle install


#
# Stage for development
#
FROM base as development

ENV RAILS_ENV="development"


#
# Stage for production
#
FROM base as production

ARG APPROOT
ENV RAILS_ENV="production"

COPY . ${APPROOT}
# FIXME: precompileしたassetsを配信できるようになったらコメントをはずす
#RUN SECRET_KEY_BASE=$(rails secret) rails assets:precompile
