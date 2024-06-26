#! /usr/bin/env bash

set -x;

# Ensure we're in this script's directory
cd "$( cd "$( dirname "$(realpath -m "${BASH_SOURCE[0]}")" )" && pwd )" || exit;

_expand_assoc() {
    local -;
    local key;
    local -n ary=$1;
    for key in "${!ary[@]}"; do
        echo "[${key}]=${ary[${key}]@Q}";
    done
}

get_os_info() {
    local -;
    local out_="${1:-}";
    local NAME_="${2:-}";
    local MAJOR_="${3:-}";
    local MINOR_="${4:-}";
    # shellcheck disable=SC1090
source <(
. /etc/os-release;
major="${MAJOR_:-"$(cut -d'.' -f1 <<< "${VERSION_ID}")"}";
minor="${MINOR_:-"$(cut -d'.' -f2 <<< "${VERSION_ID}")"}";
major="$((major - (major % 2)))";
echo "os_name=${NAME_:-${VERSION_CODENAME}}";
echo "os_major=${major}";
echo "os_minor=${minor}";
echo "os_id_and_ver=${ID}${major}${minor}";
echo "os_id_and_ver_and_dot=${ID}${major}.${minor}";
);
    if test -n "${out_-}"; then
        eval "${out_}=(\
            [name]='${os_name-}' \
            [major]='${os_major-}' \
            [minor]='${os_minor-}' \
            [id_and_ver]='${os_id_and_ver-}' \
            [id_and_ver_and_dot]='${os_id_and_ver_and_dot-}' \
        )";
    fi
}

get_os_info_jammy() {
    local -;
    get_os_info "$1" jammy "22";
}

list_script_paths() {
    local -;
    local -A os;
    local -a files=("$@");
    set -- ;
    get_os_info os;
    local file;
    for file in "${files[@]}"; do
        if test -x "${os[name]}/${file}"; then
            realpath -m "${os[name]}/${file}";
        elif test -x "${file}"; then
            realpath -m "${file}";
        fi
    done
    return 0;
}

export pkgs_to_install=();

add_to_installation() {
    pkgs_to_install+=("$@");
}

install_packages() {
    local -;
    local name;
    local pkgs=();
    local list=("${pkgs_to_install[@]}");

    pkgs_to_install=();

    for name in "${list[@]}"; do
        if declare -F "${name}_preinstall" >/dev/null 2>&1; then
            "${name}_preinstall" || exit 1;
        fi
    done

    chmod 0644 /etc/apt/trusted.gpg.d/*.gpg || true;

    apt update;

    for name in "${list[@]}"; do
        if declare -F "${name}_install" >/dev/null 2>&1; then
            "${name}_install" || exit 1;
        fi
        if declare -F "${name}_packages" >/dev/null 2>&1; then
            readarray -O ${#pkgs[@]} -t pkgs < <("${name}_packages" | tr '[:blank:]' '\n' | tr -s '[:space:]');
        fi
    done

    apt update;

    if test ${#pkgs[@]} -gt 0; then
        apt install -y --no-install-recommends "${pkgs[@]}" || exit 1;
    fi

    for name in "${list[@]}"; do
        if declare -F "${name}_postinstall" >/dev/null 2>&1; then
            "${name}_postinstall" || exit 1;
        fi
    done
}

readarray -t script_paths < <(list_script_paths ./00*.sh);

for path in "${script_paths[@]}"; do
    # shellcheck disable=SC1090
    source "${path}";
done

install_packages;

find /tmp/               \
     /var/tmp/           \
     /var/cache/apt/     \
     /var/lib/apt/lists/ \
    -mindepth 1 -prune   \
    -exec rm -rf -- {}   \;

rm -rf "$(pwd)";
