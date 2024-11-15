#! /usr/bin/env bash

if [ "$(id -u)" -eq 0 ]; then
    echo -e 'Script must not be run as root.'
    exit 1
fi

set -euo pipefail;

###############################################################################
# Post-install configuration ##################################################
###############################################################################

# Load plank config
if test -f ~/.config/plank.ini; then
    dconf load /net/launchpad/plank/docks/dock1/ < <(cat ~/.config/plank.ini);
    rm ~/.config/plank.ini;
fi

# These are in the XFCE config files
# https://gitlab.com/vala-panel-project/vala-panel-appmenu#desktop-environment-specific-settings
# xfconf-query -c xsettings -p /Gtk/ShellShowsMenubar -n -t bool -s true
# xfconf-query -c xsettings -p /Gtk/ShellShowsAppmenu -n -t bool -s true

# https://github.com/rilian-la-te/vala-panel-appmenu/blob/master/subprojects/appmenu-gtk-module/README.md#usage-instructions
# xfconf-query -c xsettings -p /Gtk/Modules -n -t string -s "unity-gtk-module"

# Set desktop background to those nice green trees
xfconf-query -c xfce4-desktop -p /desktop-menu/show -s true;
xfconf-query -c xsettings -p /Net/IconThemeName -s Humanity-Dark;

for path in $(xfconf-query -c xfce4-desktop -l | grep -P 'image-style$'); do
    xfconf-query -c xfce4-desktop -p "$path" -s 1;
done

for path in $(xfconf-query -c xfce4-desktop -l | grep -P '(image-path|last-image)$'); do
    xfconf-query -c xfce4-desktop -p "$path" -s /usr/share/backgrounds/Kyoto-Japan-Treetop-Temple-5120x3200.jpeg;
done

# Install fzf
if ! type fzf >/dev/null 2>&1; then
    ~/.fzf/install --xdg --completion --key-bindings --update-rc;
fi

if [ "$(id -u)" -lt 1000 ]; then exit 0; fi;

# Add user to the docker group
sudo usermod -aG docker "$USER";
systemctl --now enable docker;
sudo systemctl restart docker;

export DEBIAN_FRONTEND=noninteractive;

sudo apt update;
sudo apt upgrade -y -o Dpkg::Options::="--force-confnew";
echo "" | sudo tee /etc/apt/apt.conf.d/20apt-esm-hook.conf;

# Install the CUDA toolkit
if ! dpkg -s cuda > /dev/null 2>&1; then
    sudo apt install -y --no-install-recommends cuda nvidia-settings;
fi

cat <<"EOF" >> ~/.bashrc
export CUDA_HOME="/usr/local/cuda";
export PATH="$PATH:$CUDA_HOME/bin";
EOF

if test -f ~/.config/autostart/xubuntu-postinstall.desktop; then
    rm ~/.config/autostart/xubuntu-postinstall.desktop;
fi
