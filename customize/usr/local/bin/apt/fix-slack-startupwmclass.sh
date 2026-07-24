#! /bin/bash

if ! echo "${SUDO_COMMAND:-}" | grep -qE '^\/usr\/bin\/apt (install|upgrade).*$'; then
    exit 0
fi

if test -f /usr/share/applications/slack.desktop; then
    sed -i 's/StartupWMClass=Slack/StartupWMClass=slack/g' /usr/share/applications/slack.desktop
fi
