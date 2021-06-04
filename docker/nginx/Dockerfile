FROM nginx:1.21.0-alpine
LABEL maintainer=hardcore
RUN apk add --no-cache --upgrade bash

RUN mkdir -p /ssl
COPY ssl-127.0.0.1/ssl.cert /ssl/ssl.cert
COPY ssl-127.0.0.1/ssl.key /ssl/ssl.key
COPY wait-for-it.sh /usr/bin/
RUN chmod +x /usr/bin/wait-for-it.sh
COPY docker-cmd.sh /usr/bin/
RUN chmod +x /usr/bin/docker-cmd.sh

CMD ["/usr/bin/docker-cmd.sh"]