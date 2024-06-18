#! /usr/bin/env bash

###############################################################################
# CUDA ########################################################################
###############################################################################

nvidia_preinstall() {
    local -;
    set -euo pipefail;

    local -A os;
    get_os_info os;

    if test "${os[major]}" -ge 24; then
        get_os_info_jammy os;
    fi

    echo "Downloading cuda keyring" \
 && wget --no-hsts -qO /tmp/cuda-keyring.deb \
    "https://developer.download.nvidia.com/compute/cuda/repos/${os[id_and_ver]-}/$(uname -p)/cuda-keyring_1.1-1_all.deb";

    # Install nvidia-container-toolkit
    echo "Adding nvidia-container-toolkit apt repository" \
 && curl -fsSL --compressed https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/nvidia-container-toolkit-keyring.gpg \
 && curl -fsSL --compressed -o /etc/apt/sources.list.d/nvidia-container-toolkit.list "https://nvidia.github.io/libnvidia-container/${os[id_and_ver_and_dot]-}/libnvidia-container.list";
}

nvidia_install() {
    local -;
    set -euo pipefail;

    dpkg -i /tmp/cuda-keyring.deb || true;
}

nvidia_packages() {
    local -;
    set -euo pipefail;

    local nvidia_kernel_ver=;
    nvidia_kernel_ver="$(apt-cache search nvidia-kernel-open- | cut -sd' ' -f1 | sort -rh | head -n1 | cut -d'-' -f4)";
    echo "nvidia-driver-${nvidia_kernel_ver} nvidia-container-toolkit";
}

nvidia_postinstall() {
    local -;
    set -euo pipefail;

    rm -rf /tmp/cuda-keyring.deb;

    nvidia-ctk runtime configure --runtime=docker;
    systemctl restart docker;
}

add_to_installation nvidia;
