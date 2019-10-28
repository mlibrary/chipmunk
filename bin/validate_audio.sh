#!/bin/bash

# Give FEED_HOME env var a default value if unset.
#
if [ -z "$FEED_HOME" ]; then
  FEED_HOME=/usr/local/feed
fi

export HTFEED_CONFIG=$FEED_HOME/etc/config_audio.yaml

# Append 'data' to given directory (which is the root of the bag) and redirect
# STDERR to STDOUT, since we aren't currently saving STDOUT

EXTERNAL_ID=$1
BAG_DIRECTORY=$2
perl $FEED_HOME/bin/validate_vendoraudio_chipmunk.pl "$EXTERNAL_ID" "$BAG_DIRECTORY/data" -level INFO -file - 1>&2
