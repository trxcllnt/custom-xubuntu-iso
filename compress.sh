#! /usr/bin/env bash

# Ensure we're in this script's directory
cd "$( cd "$( dirname "$(realpath -m "${BASH_SOURCE[0]}")" )" && pwd )";

set -x;
set -euo pipefail;

if test -d mnt; then
    (cd mnt; zip -r ../root .);
fi
