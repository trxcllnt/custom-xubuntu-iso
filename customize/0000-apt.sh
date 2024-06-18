#! /usr/bin/env bash

###############################################################################
# Prerequisites ###############################################################
###############################################################################

export DEBIAN_FRONTEND=noninteractive;

cp -ar usr/local/bin/* /usr/local/bin/;
cp -ar etc/apt/apt.conf.d/* /etc/apt/apt.conf.d/;
echo "" > /etc/apt/apt.conf.d/20apt-esm-hook.conf;

echo "Installing apt utilities"             \
&& apt update                               \
&& apt install -y --no-install-recommends   \
    apt-transport-https                     \
    bash-completion                         \
    ca-certificates                         \
    curl                                    \
    dirmngr                                 \
    gpg                                     \
    gpg-agent                               \
    jq                                      \
    software-properties-common              \
    wget                                    \
    ;

add-apt-repository -yn universe;

install -m 0755 -d /usr/share/fonts;
install -m 0755 -d /usr/share/icons;
install -m 0755 -d /usr/share/keyrings;
install -m 0755 -d /etc/skel/.config;
install -m 0755 -d /etc/apt/trusted.gpg.d;
