FROM ruby:2.6

RUN git clone -b test https://github.com/hardcoretech/csl.git /csl

RUN gem install bundler

WORKDIR /csl
COPY Gemfile /csl/

RUN bundle install

ENV ELASTICSEARCH_URL="elastic:9200"

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
COPY import.sh /usr/bin/
RUN chmod +x /usr/bin/import.sh
COPY wait-for-it.sh /usr/bin/
RUN chmod +x /usr/bin/wait-for-it.sh
COPY development.rb /csl/config/environments/
EXPOSE 3000

CMD ["/usr/bin/entrypoint.sh"]
