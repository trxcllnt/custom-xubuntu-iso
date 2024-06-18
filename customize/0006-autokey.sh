#! /usr/bin/env bash

###############################################################################
# Autokey #####################################################################
###############################################################################

autokey_preinstall() {
    local -;
    set -euo pipefail;

    local AUTOKEY_VERSION;
    AUTOKEY_VERSION="$(curl -s https://api.github.com/repos/autokey/autokey/releases/latest | jq -r ".tag_name" | tr -d 'v')";

    echo "Downloading autokey" \
 && wget --no-hsts -qO /tmp/autokey-gtk_all.deb \
    "https://github.com/autokey/autokey/releases/download/v${AUTOKEY_VERSION}/autokey-gtk_${AUTOKEY_VERSION}_all.deb" \
 && wget --no-hsts -qO /tmp/autokey-common_all.deb \
    "https://github.com/autokey/autokey/releases/download/v${AUTOKEY_VERSION}/autokey-common_${AUTOKEY_VERSION}_all.deb";
}

autokey_install() {
    local -;
    set -euo pipefail;

    dpkg -i /tmp/autokey-*.deb || true;
    apt install -y --fix-broken --no-install-recommends;
    cp -ar etc/skel/.config/autokey /etc/skel/.config/;
}

autokey_postinstall() {
    local -;
    set -euo pipefail;

    rm /tmp/autokey-*.deb;
}

add_to_installation autokey;
