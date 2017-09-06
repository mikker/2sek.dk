FROM ruby:2.4.1

ENV PORT 3000
ENV APP_DIR /app/

ADD . $APP_DIR
WORKDIR $APP_DIR

RUN bundle

EXPOSE $PORT

CMD bundle exec puma -C config/puma.rb
