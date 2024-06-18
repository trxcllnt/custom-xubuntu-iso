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

    echo "Adding Ubuntu High Sierra Theme" \
 && curl -fsSL --compressed -o /tmp/sierra-gtk-theme.zip "https://github.com/vinceliuice/Sierra-gtk-theme/archive/refs/tags/2019-12-16.zip" \
 && unzip -d /tmp -o /tmp/sierra-gtk-theme.zip \
 && rm -rf /tmp/sierra-gtk-theme \
 && mv /tmp/Sierra-gtk-theme-* /tmp/sierra-gtk-theme \
 && chmod +x /tmp/sierra-gtk-theme/install.sh;
}

desktop_packages() {
    local -;
    set -euo pipefail;

    echo openssh-{client,server};
    echo cifs-utils;
    echo efibootmgr;
    echo gnome-disk-utility;
    echo lightdm-gtk-greeter-settings;
    echo mousepad;
    echo network-manager-pptp;
    echo ristretto;
    echo network-manager-openconnect-gnome;
    echo ungoogled-chromium;
    echo plank;
    echo xarchiver;
    echo dconf-cli;
    echo dconf-editor;
    echo xfce4-goodies;
    echo humanity-icon-theme;
    echo xfce4-appmenu-plugin;
    echo xfce4-cpugraph-plugin;
    echo xfce4-netload-plugin;
    echo xfce4-taskmanager;
    echo vala-panel-appmenu;
    echo gtk2-engines-murrine;
    echo gtk2-engines-pixbuf;
    echo unity-gtk{2,3}-module;
}

desktop_postinstall() {
    local -;
    set -euo pipefail;

    /tmp/sierra-gtk-theme/install.sh --no-apple;

    cp -ar etc/skel/.config/autostart /etc/skel/.config/;
    cp -ar etc/skel/.config/plank /etc/skel/.config/;
    cp -ar etc/skel/.config/plank.ini /etc/skel/.config/;
    cp -ar etc/skel/.config/Thunar /etc/skel/.config/;
    cp -ar etc/skel/.config/xfce4 /etc/skel/.config/;

    git -C /etc/skel/.config/xfce4/ init;
    git -C /etc/skel/.config/xfce4/ config user.name "Anonymous";
    git -C /etc/skel/.config/xfce4/ config user.email "<>";
    git -C /etc/skel/.config/xfce4/ add .;
    git -C /etc/skel/.config/xfce4/ commit -m "skeleton";

    rm -rf /tmp/sierra-gtk-theme;

    curl -fsSL --compressed \
        -o /etc/apparmor.d/chromium_browser \
        https://gitlab.com/apparmor/apparmor/-/raw/master/profiles/apparmor/profiles/extras/chromium_browser?ref_type=heads;

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
