#!/bin/bash

if [ "$RUN_INTEGRATION" == "1" ]; then
  exec bin/validate_audio.sh "$@"
else
  exit 0
fi
