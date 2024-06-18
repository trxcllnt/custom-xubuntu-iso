#! /bin/bash

if ! echo "${SUDO_COMMAND:-}" | grep -qE '^\/usr\/bin\/apt (install|upgrade).*$'; then
    exit 0;
fi

echo "$(whoami) ($(id -u):$(id -g)): $0 $*" >> /var/log/apt/disable-startup-notify.stderr.log;
echo "$(whoami) ($(id -u):$(id -g)): $0 $*" >> /var/log/apt/disable-startup-notify.stdout.log;

disable_startup_notifers() {
    find /usr/share/ \
         /usr/local/share/ \
         /etc/xdg/autostart/ \
         /home/*/Desktop/ \
         /home/*/.gnome/apps/ \
         /home/*/.local/share/ \
         /home/*/.config/autostart/ \
         -type f \
         -iname '*.desktop' \
         -print0 2>/dev/null \
  | xargs -0 -P"$(nproc --ignore 2)" -n1 \
    sed -i 's/StartupNotify=true/StartupNotify=false/g';
}

disable_startup_notifers \
  2>>/var/log/apt/disable-startup-notify.stderr.log \
  1>>/var/log/apt/disable-startup-notify.stdout.log ;

echo "" >> /var/log/apt/disable-startup-notify.stderr.log;
echo "" >> /var/log/apt/disable-startup-notify.stdout.log;
echo "" > /etc/apt/apt.conf.d/20apt-esm-hook.conf;
