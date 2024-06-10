#! /usr/bin/env bash

# Ensure we're in this script's directory
cd "$( cd "$( dirname "$(realpath -m "${BASH_SOURCE[0]}")" )" && pwd )";

set -x;
set -euo pipefail;

###############################################################################
# Prerequisites ###############################################################
###############################################################################

export DEBIAN_FRONTEND=noninteractive;

apt update;

apt install -y --no-install-recommends \
    software-properties-common         \
    apt-transport-https                \
    ca-certificates                    \
    curl                               \
    wget                               \
    jq                                 ;

add-apt-repository -yn universe;
add-apt-repository -yn ppa:git-core/ppa;

install -m 0755 -d /usr/share/fonts;
install -m 0755 -d /usr/share/icons;
install -m 0755 -d /usr/share/keyrings;
install -m 0755 -d /etc/apt/trusted.gpg.d;

# shellcheck disable=SC2072
if [[ "$(. /etc/os-release;echo $VERSION_ID)" < "24.04" ]]; then
    # Make a temp user 999 so docker doesn't try to use this UID
    adduser --system --no-create-home --uid 999 --group temp_user;
fi

###############################################################################
# CUDA ########################################################################
###############################################################################
wget --no-hsts -qO /opt/cuda-keyring_1.1-1_all.deb \
    https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb;

###############################################################################
# Chromium ####################################################################
###############################################################################
echo "Downloading UnGoogled Chromium" \
 && curl -fsSL https://download.opensuse.org/repositories/home:ungoogled_chromium/Ubuntu_Jammy/Release.key \
  | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/ungoogled_chromium.gpg \
 && echo "deb [arch=$(dpkg --print-architecture)] http://download.opensuse.org/repositories/home:/ungoogled_chromium/Ubuntu_Jammy/ /" \
  | tee /etc/apt/sources.list.d/ungoogled_chromium.list >/dev/null;

###############################################################################
# Docker ######################################################################
###############################################################################
echo "Downloading Docker" \
 && curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" \
  | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/docker.gpg \
 `# && chmod a+r /etc/apt/trusted.gpg.d/docker.gpg` \
 && echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu jammy stable" \
  | tee /etc/apt/sources.list.d/docker.list >/dev/null;

# Install nvidia-container-toolkit
echo "Downloading nvidia-container-toolkit" \
 && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
  | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/nvidia-container-toolkit-keyring.gpg \
 && curl -s -L https://nvidia.github.io/libnvidia-container/$(. /etc/os-release;echo $ID$VERSION_ID)/libnvidia-container.list \
  | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null;

###############################################################################
# GitHub CLI + Desktop ########################################################
###############################################################################
echo "Downloading GitHub CLI" \
 && curl -fsSL "https://cli.github.com/packages/githubcli-archive-keyring.gpg" \
  | dd of=/etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg \
 `# && chmod go+r /etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg` \
 && echo "deb [arch=$(dpkg --print-architecture)] https://cli.github.com/packages stable main" \
  | tee /etc/apt/sources.list.d/github-cli.list > /dev/null;

echo "Downloading GitHub Desktop" \
 && wget --no-hsts -qO - https://apt.packages.shiftkey.dev/gpg.key \
  | gpg --dearmor --yes \
  | tee /etc/apt/trusted.gpg.d/shiftkey-packages.gpg > /dev/null \
 && echo "deb [arch=$(dpkg --print-architecture)] https://apt.packages.shiftkey.dev/ubuntu/ any main" \
  | tee /etc/apt/sources.list.d/shiftkey-packages.list >/dev/null;

###############################################################################
# node.js #####################################################################
###############################################################################
echo "Downloading yarn" \
 && curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg \
  | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/yarnpkg.gpg \
 `# && chmod a+r /etc/apt/trusted.gpg.d/yarnpkg.gpg` \
 && echo "deb [arch=$(dpkg --print-architecture)] https://dl.yarnpkg.com/debian/ stable main" \
  | tee /etc/apt/sources.list.d/yarn.list >/dev/null;

###############################################################################
# VSCode ######################################################################
###############################################################################
echo "Downloading VSCode" \
 && curl https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/packages.microsoft.gpg \
 `# && chmod a+r /etc/apt/trusted.gpg.d/packages.microsoft.gpg` \
 && echo "deb [arch=$(dpkg --print-architecture)] https://packages.microsoft.com/repos/vscode stable main" \
  | tee /etc/apt/sources.list.d/vscode.list >/dev/null;

###############################################################################
# Slack #######################################################################
###############################################################################
echo "Downloading Slack" \
 && wget --no-hsts -qO /opt/slack-desktop.deb \
    https://downloads.slack-edge.com/releases/linux/4.33.73/prod/x64/slack-desktop-4.33.73-amd64.deb;

###############################################################################
# UI ##########################################################################
###############################################################################
# Install sierra-gtk-theme and plank
add-apt-repository -yn ppa:ricotz/docky;
add-apt-repository -yn ppa:dyatlov-igor/sierra-theme || true;
rm /etc/apt/sources.list.d/dyatlov-igor-ubuntu-sierra-theme-*.list;

cat <<EOF >/etc/apt/sources.list.d/dyatlov-igor-ubuntu-sierra-theme-bionic.list
deb http://ppa.launchpad.net/dyatlov-igor/sierra-theme/ubuntu bionic main
# deb-src http://ppa.launchpad.net/dyatlov-igor/sierra-theme/ubuntu bionic main
EOF

# Download autokey
AUTOKEY_VERSION="$(curl -s https://api.github.com/repos/autokey/autokey/releases/latest | jq -r ".tag_name" | tr -d 'v')";
echo "Downloading autokey" \
 && wget --no-hsts -qO /opt/autokey-gtk_all.deb \
    "https://github.com/autokey/autokey/releases/download/v${AUTOKEY_VERSION}/autokey-gtk_${AUTOKEY_VERSION}_all.deb" \
 && wget --no-hsts -qO /opt/autokey-common_all.deb \
    "https://github.com/autokey/autokey/releases/download/v${AUTOKEY_VERSION}/autokey-common_${AUTOKEY_VERSION}_all.deb";

###############################################################################
# CMake #######################################################################
###############################################################################
echo "Downloading kitware apt sources" \
 && wget --no-hsts -qO - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null \
  | gpg --dearmor - \
  | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null \
 && echo -e "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" \
  | tee /etc/apt/sources.list.d/kitware.list >/dev/null;

chmod 0644 /etc/apt/trusted.gpg.d/*.gpg || true;

###############################################################################
# Installation ################################################################
###############################################################################

# Install debs
dpkg -i /opt/*.deb || true && rm /opt/*.deb;

apt update;

# Fix missing or broken dependencies from autokey debs
apt install -y --fix-broken --no-install-recommends;

rm /usr/share/keyrings/kitware-archive-keyring.gpg;
apt install -y --no-install-recommends \
    kitware-archive-keyring;

nvidia_kernel_ver="$(apt-cache search nvidia-kernel-open- | cut -sd' ' -f1 | sort -rh | head -n1 | cut -d'-' -f4)";

apt install -y --no-install-recommends      \
    `# NVIDIA Open GPU kernel module`       \
    nvidia-kernel-open-${nvidia_kernel_ver} \
    ;

apt install -y                              \
    cuda-drivers-${nvidia_kernel_ver}       \
    nvidia-container-toolkit                \
    `# utils `                              \
    openssh-client openssh-server libc6-dev \
    jq gpg shc gnupg-agent bash-completion  \
    `# git, Git LFS, Github CLI + Desktop`  \
    git git-lfs gh github-desktop           \
    `# Chromium`                            \
    ungoogled-chromium                      \
    `# Docker #`                            \
    docker-ce                               \
    docker-ce-cli                           \
    containerd.io                           \
    docker-buildx-plugin                    \
    docker-compose-plugin                   \
    docker-ce-rootless-extras               \
    `# CMake`                               \
    cmake                                   \
    `# Slack`                               \
    slack-desktop                           \
    `# yarn`                                \
    yarn                                    \
    `# b(uild)ear and VSCode`               \
    bear code                               \
    `# vpn`                                 \
    network-manager-openconnect-gnome       \
    `# UI things`                           \
    plank                                   \
    xarchiver                               \
    dconf-cli                               \
    dconf-editor                            \
    xfce4-goodies                           \
    humanity-icon-theme                     \
    sierra-gtk-theme-git                    \
    xfce4-appmenu-plugin                    \
    vala-panel-appmenu                      \
    `# unity-gtk2-module`                   \
    `# unity-gtk3-module`                   \
    `# unity-gtk-module-common`             \
    `# libdbusmenu-glib4`                   \
    `# libdbusmenu-gtk3-4`                  \
    `# libdbusmenu-gtk4`                    \
    `# appmenu-gtk2-module`                 \
    `# appmenu-gtk3-module`                 \
    `# appmenu-gtk-module-common`           \
    ;

# Install yarn completions
curl -fsSL --compressed \
    https://raw.githubusercontent.com/dsifford/yarn-completion/5bf2968493a7a76649606595cfca880a77e6ac0e/yarn-completion.bash \
  | sudo tee /etc/bash_completion.d/yarn >/dev/null;

# Install docker compose-switch plugin
curl -fsSL "https://raw.githubusercontent.com/docker/compose-switch/master/install_on_linux.sh" | sh;

# Install latest LLVM
devcontainers_version="$(curl -fsSL -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/rapidsai/devcontainers | jq -r '.default_branch')";
llvm_version="$(git ls-remote --tags https://github.com/llvm/llvm-project | grep -oP "tags/llvmorg-\\K[0-9]+(-init)$" | grep -oP '[0-9]+' | sort -rV | head -n1)";
curl -fsSL "https://raw.githubusercontent.com/rapidsai/devcontainers/$devcontainers_version/features/src/llvm/llvm.sh" | bash -s -- "$llvm_version";

# Install files
if test -f root.zip; then
    unzip -o root.zip -d /;
    rm -rf root.zip;
    # Update font cache
    fc-cache -f -v;
    # Install default cursor theme
    update-alternatives --install /usr/share/icons/default/index.theme x-cursor-theme /usr/share/icons/OSX-ElCap/cursor.theme 90;
    touch /var/log/xubuntu-postinstall.log && chmod 777 /var/log/xubuntu-postinstall.log;
fi

###############################################################################
# Clean up ####################################################################
###############################################################################

deluser --remove-all-files temp_user;
apt remove -y chromium-browser;
apt autoremove -y;

find /tmp/               \
     /var/tmp/           \
     /var/cache/apt/     \
     /var/lib/apt/lists/ \
    -mindepth 1 -prune   \
    -exec rm -rf {}     \;

if test -f customize.sh; then
    rm customize.sh;
fi
