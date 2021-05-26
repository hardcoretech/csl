#!/bin/sh

/usr/bin/wait-for-it.sh elastic:9200 -t 30  -- echo "Elasticsearch server is ready"

bundle exec rake db:create

bundle exec rake ita:import_synchronously[ScreeningList::SdnData]

bundle exec rails s -b 0.0.0.0
