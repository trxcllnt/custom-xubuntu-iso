#! /usr/bin/env bash

# Ensure we're in this script's directory
cd "$( cd "$( dirname "$(realpath -m "${BASH_SOURCE[0]}")" )" && pwd )";

set -x;
set -euo pipefail;

if test -f customize/assets.zip; then
    unzip -o customize/assets.zip -d assets;
fi
