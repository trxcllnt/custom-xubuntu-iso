#! /usr/bin/env bash

###############################################################################
# Git and Github ##############################################################
###############################################################################

git_preinstall() {
    local -;
    set -euo pipefail;

    echo "Adding Git apt repository" \
 && curl -fsSL --compressed "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xE1DD270288B4E6030699E45FA1715D88E1DF1F24" | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/ubuntu-git-maintainers.gpg \
 && cat <<EOF >/etc/apt/sources.list.d/git-core-ppa.list
deb [arch=$(dpkg --print-architecture)] http://ppa.launchpad.net/git-core/ppa/ubuntu $(. /etc/os-release; echo ${VERSION_CODENAME}) main
EOF

    echo "Adding GitHub CLI apt repository" \
 && curl -fsSL --compressed "https://cli.github.com/packages/githubcli-archive-keyring.gpg" | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg \
 && cat <<EOF >/etc/apt/sources.list.d/github-cli.list
deb [arch=$(dpkg --print-architecture)] https://cli.github.com/packages stable main \
EOF

    echo "Adding GitHub Desktop apt repository" \
 && curl -fsSL --compressed https://mirror.mwt.me/shiftkey-desktop/gpgkey | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/mwt-github-desktop.gpg \
 && cat <<EOF >/etc/apt/sources.list.d/github-desktop.list
deb [arch=$(dpkg --print-architecture)] https://mirror.mwt.me/shiftkey-desktop/deb/ any main \
EOF
}

git_packages() {
    local -;
    set -euo pipefail;

    echo "git git-lfs gh github-desktop";
}

git_postinstall() {
    local -;
    set -euo pipefail;

    gh completion -s bash > /etc/bash_completion.d/gh;
}

add_to_installation git;
