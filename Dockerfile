FROM ruby:latest

ENV PORT 3000
ENV APP_DIR /app/

ADD . $APP_DIR
WORKDIR $APP_DIR

RUN bundle

EXPOSE 3000

CMD bundle exec puma -C config/puma.rb
