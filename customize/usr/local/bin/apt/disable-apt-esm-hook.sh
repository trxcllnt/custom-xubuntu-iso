#! /bin/bash

if ! echo "${SUDO_COMMAND:-}" | grep -qE '^\/usr\/bin\/apt (install|upgrade).*$'; then
    exit 0;
fi

echo | tee /etc/apt/apt.conf.d/20apt-esm-hook.conf 2>/dev/null || true;
