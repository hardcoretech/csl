FROM ruby:2.6

RUN gem install bundler

WORKDIR /csl
COPY . /csl/

RUN bundle install

ENV ELASTICSEARCH_URL="elastic:9200"

COPY ./docker/csl/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
COPY ./docker/csl/import.sh /usr/bin/
RUN chmod +x /usr/bin/import.sh
COPY ./docker/csl/wait-for-it.sh /usr/bin/
RUN chmod +x /usr/bin/wait-for-it.sh
COPY ./docker/csl/development.rb /csl/config/environments/
EXPOSE 3000

CMD ["/usr/bin/entrypoint.sh"]
