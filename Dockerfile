ARG FEED_TAG=jhove-1.6
FROM hathitrust/feed:${FEED_TAG}

RUN apt-get update && apt-get install -y \
  autoconf \
  bison \
  build-essential \
  curl \
  default-libmysqlclient-dev \
  git \
  libffi-dev \
  libgdbm-dev \
  libncurses5-dev \
  libreadline-dev \
  libsqlite3-dev \
  libssl-dev \
  libyaml-dev \
  zlib1g-dev

RUN git clone https://github.com/rbenv/ruby-build.git
RUN PREFIX=/usr/local ./ruby-build/install.sh
ARG RUBY_VERSION=2.5.5
RUN ruby-build -v $RUBY_VERSION /usr/local

RUN gem install bundler

ENV APP_PATH /usr/src/app
RUN mkdir -p $APP_PATH
WORKDIR $APP_PATH
COPY Gemfile Gemfile.lock ./
RUN bundle install

ENV RUN_INTEGRATION 1
CMD ["bundle", "exec", "rspec"]
