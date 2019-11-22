#!/bin/bash

if [ "$RUN_INTEGRATION" == "1" ]; then
  exec bin/validate_bentleyaudio.sh "$@"
else
  exit 0
fi
