FROM python:3.6-slim-buster

WORKDIR /csl-python
COPY . /csl-python/

RUN pip install --no-cache-dir -r requirements.txt

ENV ELASTICSEARCH_HOST="elastic"
ENV ELASTICSEARCH_PORT=9200

COPY ./entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
COPY ./wait-for-it.sh /usr/bin/
RUN chmod +x /usr/bin/wait-for-it.sh

CMD ["/usr/bin/entrypoint.sh"]
