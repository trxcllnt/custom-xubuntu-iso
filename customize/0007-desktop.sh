#! /usr/bin/env bash

###############################################################################
# XFCE Desktop Environment ####################################################
###############################################################################

desktop_preinstall() {
    local -;
    set -euo pipefail;

    echo "Adding plank apt repository" \
 && curl -fsSL --compressed "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x38AE4F60E356CE050312FA1775CFD31C9E5DB0C8" | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/ricotz-docky.gpg \
 && cat <<EOF >/etc/apt/sources.list.d/ricotz-docky.list
deb [arch=$(dpkg --print-architecture)] http://ppa.launchpadcontent.net/ricotz/docky/ubuntu $(. /etc/os-release; echo ${VERSION_CODENAME}) main
EOF

    echo "Adding Ungoogled Chromium apt repository" \
 && curl -fsSL --compressed "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x5301FA4FD93244FBC6F6149982BB6851C64F6880" | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/xtradeb.gpg \
 && cat <<EOF >/etc/apt/sources.list.d/ungoogled-chromium.list
deb [arch=$(dpkg --print-architecture)] https://ppa.launchpadcontent.net/xtradeb/apps/ubuntu $(. /etc/os-release; echo ${VERSION_CODENAME}) main
EOF

    mkdir -p /tmp/sierra-gtk-theme;

    echo "Adding Ubuntu High Sierra Theme" \
    curl -fsSL --compressed "https://github.com/vinceliuice/Sierra-gtk-theme/archive/refs/tags/2019-12-16.tar.gz" \
  | tar -C /tmp/sierra-gtk-theme -xzf - --strip-components=1;
}

desktop_install() {
    local -;
    set -euo pipefail;

    /tmp/sierra-gtk-theme/install.sh --no-apple --gdm;

    cp -ar etc/skel/.config/autostart /etc/skel/.config/;
    cp -ar etc/skel/.config/plank /etc/skel/.config/;
    cp -ar etc/skel/.config/plank.ini /etc/skel/.config/;
    cp -ar etc/skel/.config/Thunar /etc/skel/.config/;
    cp -ar etc/skel/.config/xfce4 /etc/skel/.config/;

    git -C /etc/skel/.config/xfce4/ init;
    git -C /etc/skel/.config/xfce4/ add .;
    git -C /etc/skel/.config/xfce4/ commit -m "skeleton";
}

desktop_packages() {
    local -;
    set -euo pipefail;

    echo "ungoogled-chromium plank xarchiver dconf-cli dconf-editor xfce4-goodies humanity-icon-theme xfce4-appmenu-plugin vala-panel-appmenu unity-gtk{2,3}-module";
}

desktop_postinstall() {
    local -;
    set -euo pipefail;

    curl curl -fsSL --compressed \
        -o /etc/apparmor.d/chromium_browser \
        https://gitlab.com/apparmor/apparmor/-/raw/master/profiles/apparmor/profiles/extras/chromium_browser?ref_type=heads;

    rm -rf /tmp/sierra-gtk-theme;

    # Install backgrounds, fonts, and cursors
    if test -f assets.zip; then
        unzip -o assets.zip -d /;
        rm -rf assets.zip;
        # Update font cache
        fc-cache -f -v;
        # Install default cursor theme
        update-alternatives --install /usr/share/icons/default/index.theme x-cursor-theme /usr/share/icons/OSX-ElCap/cursor.theme 90;
        touch /var/log/xubuntu-postinstall.log && chmod 777 /var/log/xubuntu-postinstall.log;
    fi
}

add_to_installation desktop;
