#! /usr/bin/env bash

###############################################################################
# CMake, VSCode, bear, Node, NPM, Yarn ########################################
###############################################################################

dev_preinstall() {
    local -;
    set -euo pipefail;

    local -A os;
    get_os_info os;

    if test "${os[major]}" -lt 24; then
        get_os_info_jammy os;
        echo "Adding Git apt repository" \
 && curl -fsSL --compressed https://apt.kitware.com/keys/kitware-archive-latest.asc | gpg --dearmor --yes -o /usr/share/keyrings/kitware-archive-keyring.gpg \
 && cat <<EOF >/etc/apt/sources.list.d/kitware.list
deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ ${os[name]} main
EOF
        if ! test -f /usr/share/doc/kitware-archive-keyring/copyright; then
            apt update;
            rm /usr/share/keyrings/kitware-archive-keyring.gpg;
            apt install -y --no-install-recommends kitware-archive-keyring;
        fi
    fi

    echo "Adding VSCode apt repository" \
 && curl -fsSL --compressed https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/packages.microsoft.gpg \
 && cat <<EOF >/etc/apt/sources.list.d/vscode.list
deb [arch=$(dpkg --print-architecture)] https://packages.microsoft.com/repos/vscode stable main
EOF

    echo "Adding yarn apt repository" \
 && curl -fsSL --compressed https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/yarnpkg.gpg \
 && cat <<EOF >/etc/apt/sources.list.d/yarn.list
deb [arch=$(dpkg --print-architecture)] https://dl.yarnpkg.com/debian/ stable main
EOF
}

# shellcheck disable=SC1091
dev_install() {
    local -;
    set -euo pipefail;

    # Download fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git /etc/skel/.fzf;

    # Install nvm and node
    export NVM_DIR=/etc/skel;
    curl -fsSL --compressed https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash;

    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"; # This loads nvm bash_completion

    nvm install node;

    cat <<"EOF" >> /etc/skel/.bashrc
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")";
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"; # This loads nvm bash_completion

if type nvm >/dev/null 2>&1; then
    export NODE_NO_WARNINGS=1;
    export NODE_PENDING_DEPRECATION=0;
    export NODE_BIN="$(nvm which current)";
    export NODE_BIN_PATH="$(dirname $NODE_BIN)";
    export NODE_HOME="$(cd $NODE_BIN_PATH/..; pwd)";
    export NODE_INCLUDE_PATH="$NODE_HOME/include/node";
fi
EOF

    cat <<"EOF" >> /etc/skel/.bashrc
if test -n "${SSH_CONNECTION:-}" && test -z "${SSH_AUTH_SOCK:-}" && type gnome-keyring-daemon >/dev/null 2>&1; then
    read -rsp "keyring password: " pass;
    export "$(echo -n "${pass}" | gnome-keyring-daemon --unlock --components=ssh,secrets,pkcs11)";
    echo "";
fi
EOF


    cp -ar etc/skel/.{npm,yarn}rc /etc/skel/;
}

dev_packages() {
    local -;
    set -euo pipefail;

    echo "bear cmake code yarn";
}

dev_postinstall() {
    local -;
    set -euo pipefail;

    # Install npm completions
    echo "Installing npm completions" \
 && npm completion > /etc/bash_completion.d/npm;

    # Install yarn completions
    echo "Installing yarn completions" \
 && curl -fsSL --compressed -o /etc/bash_completion.d/yarn "https://raw.githubusercontent.com/dsifford/yarn-completion/5bf2968493a7a76649606595cfca880a77e6ac0e/yarn-completion.bash";

    cat <<"EOF" >> /etc/skel/.bashrc
# VSCode envvars
export NO_UPDATE_NOTIFIER=true
export SHELL_SESSION_HISTORY=0
export DOTNET_CLI_TELEMETRY_OPTOUT=1
EOF
}

add_to_installation dev;
