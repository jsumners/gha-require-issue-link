#!/usr/bin/env bash

## This script is used for local development of `script.sh`.
## It'll read in a .env file, make those variables available, and run
## the actual script.

if [ ! -e .env ]; then
  echo "Mising .env file. Copy .env.sample and adjust."
  exit 1
fi

set -a
source .env
./script.sh
set +a