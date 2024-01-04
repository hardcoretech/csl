#!/bin/sh

# Check if variable is set
if [ -z "$ELASTICSEARCH_URL" ] ; then
    echo "ELASTICSEARCH_URL variable is not set"
    exit 1
fi

# Remove http:// or https:// from ELASTICSEARCH_URL
ELASTICSEARCH_URL=${ELASTICSEARCH_URL#*//}

# Wait for Elasticsearch to start up before doing anything.
/usr/bin/wait-for-it.sh "$ELASTICSEARCH_URL" -t 30 -- echo "Elasticsearch server is ready"

# DB Migration
if [ "$RECREATE_DB" = "true" ] ; then
    bundle exec rake db:create
    /usr/bin/import.sh
fi

bundle exec rails s -b 0.0.0.0
