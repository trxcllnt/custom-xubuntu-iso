#! /usr/bin/env bash

###############################################################################
# CUDA ########################################################################
###############################################################################

nvidia_preinstall() {
    local -;
    set -euo pipefail;

    local -A os;
    get_os_info os;

    echo "Downloading cuda keyring" \
 && wget --no-hsts -qO /tmp/cuda-keyring.deb \
    "https://developer.download.nvidia.com/compute/cuda/repos/${os[id_and_ver]-}/$(uname -p)/cuda-keyring_1.1-1_all.deb";

    dpkg -i /tmp/cuda-keyring.deb || true;

    # Install nvidia-container-toolkit
    echo "Adding nvidia-container-toolkit apt repository" \
 && curl -fsSL --compressed https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/nvidia-container-toolkit-keyring.gpg \
 && curl -fsSL --compressed -o /etc/apt/sources.list.d/nvidia-container-toolkit.list "https://nvidia.github.io/libnvidia-container/${os[id_and_ver_and_dot]-}/libnvidia-container.list";
}

nvidia_packages() {
    local -;
    set -euo pipefail;

    echo cuda-drivers;
    echo nvidia-container-toolkit;
}

nvidia_postinstall() {
    local -;
    set -euo pipefail;

    rm -rf /tmp/cuda-keyring.deb;

    nvidia-ctk runtime configure --runtime=docker;
}

add_to_installation nvidia;
