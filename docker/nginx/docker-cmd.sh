#!/bin/sh

set -ex

/usr/bin/wait-for-it.sh rails:3000 -t 300  -- echo "CSL server is ready"
exec nginx -g "daemon off;"