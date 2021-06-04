#!/bin/sh

/usr/bin/wait-for-it.sh elastic:9200 -t 30  -- echo "Elasticsearch server is ready"

if [ "$RECREATE_DB" = "true" ] ; then
    bundle exec rake db:create
    /usr/bin/import.sh
fi

bundle exec rails s -b 0.0.0.0
