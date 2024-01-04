#!/bin/sh

/usr/local/bin/wait-for-it.sh elastic:9200 -t 30  -- echo "Elasticsearch server is ready"
/usr/local/bin/wait-for-it.sh rails:3000 -t 60  -- echo "DB migration is ready"

echo "********** Start CSL-python import script **********"
python import_source.py
