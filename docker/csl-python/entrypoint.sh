#!/bin/sh

/usr/bin/wait-for-it.sh elastic:9200 -t 30  -- echo "Elasticsearch server is ready"

echo "********** Start CSL-python import script **********"
python import_source.py
