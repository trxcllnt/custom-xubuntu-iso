#! /bin/bash

if ! echo "${SUDO_COMMAND:-}" | grep -qE '^\/usr\/bin\/apt (install|upgrade).*$'; then
    exit 0
fi

mv /usr/share/applications/code-url-handler.desktop{,.orig}
cp /usr/{local,}/share/applications/code-url-handler.desktop
