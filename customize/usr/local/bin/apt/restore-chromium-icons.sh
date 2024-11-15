#! /bin/bash

if ! echo "${SUDO_COMMAND:-}" | grep -qE '^\/usr\/bin\/apt (install|upgrade).*$'; then
    exit 0;
fi

cp /usr/share/icons/hicolor/64x64/apps/{google-chrome,ungoogled-chromium}.png 2>/dev/null || true;
cp /usr/share/icons/hicolor/32x32/apps/{google-chrome,ungoogled-chromium}.png 2>/dev/null || true;
cp /usr/share/icons/hicolor/16x16/apps/{google-chrome,ungoogled-chromium}.png 2>/dev/null || true;
cp /usr/share/icons/hicolor/48x48/apps/{google-chrome,ungoogled-chromium}.png 2>/dev/null || true;
cp /usr/share/icons/hicolor/256x256/apps/{google-chrome,ungoogled-chromium}.png 2>/dev/null || true;
cp /usr/share/icons/hicolor/24x24/apps/{google-chrome,ungoogled-chromium}.png 2>/dev/null || true;
cp /usr/share/icons/hicolor/128x128/apps/{google-chrome,ungoogled-chromium}.png 2>/dev/null || true;
cp /usr/local/share/applications/ungoogled-chromium.desktop /usr/share/applications/ungoogled-chromium.desktop;
