#! /usr/bin/env bash

###############################################################################
# Docker ######################################################################
###############################################################################

docker_preinstall() {
    local -;
    set -euo pipefail;

    local -A os;
    get_os_info os;

    if test "${os[major]}" -lt 24; then
        # Make a temp user 999 so docker doesn't try to use this UID
        adduser --system --no-create-home --uid 999 --group temp_user;
    fi

    echo "Adding Docker apt repository" \
     && curl -fsSL --compressed https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/docker.gpg \
     && cat <<EOF >/etc/apt/sources.list.d/docker.list
deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(. /etc/os-release; echo ${VERSION_CODENAME}) stable
EOF
}

docker_packages() {
    local -;
    set -euo pipefail;

    echo docker-ce;
    echo docker-ce-cli;
    echo containerd.io;
    echo docker-buildx-plugin;
    echo docker-compose-plugin;
    echo docker-ce-rootless-extras;
}

docker_postinstall() {
    local -;
    set -euo pipefail;

    local -A os;
    get_os_info os;

    if test "${os[major]-}" -lt 24; then
        deluser --remove-all-files temp_user;
    fi

    echo "Installing docker compose-switch plugin" \
 && curl -fsSL --compressed "https://raw.githubusercontent.com/docker/compose-switch/master/install_on_linux.sh" | sh;

    cat <<"EOF" >> /etc/skel/.bashrc
export DOCKER_SCAN_SUGGEST=false
EOF
}

add_to_installation docker;
