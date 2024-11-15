#! /usr/bin/env bash

###############################################################################
# Slack #######################################################################
###############################################################################

slack_preinstall() {
    local -;
    set -euo pipefail;

    echo "Downloading Slack" \
 && wget --no-hsts -qO /tmp/slack-desktop.deb \
    https://downloads.slack-edge.com/releases/linux/4.33.73/prod/x64/slack-desktop-4.33.73-amd64.deb;

    dpkg -i /tmp/slack-desktop.deb || true;
}

slack_packages() {
    local -;
    set -euo pipefail;

    echo slack-desktop;
}

slack_postinstall() {
    local -;
    set -euo pipefail;

    rm /tmp/slack-desktop.deb;
}

add_to_installation slack;
