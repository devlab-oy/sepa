FROM ruby:3.2

RUN gem install bundler

WORKDIR /app

COPY . .
RUN bundle install
