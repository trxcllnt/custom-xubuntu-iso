#! /usr/bin/env bash

set -x;

# Ensure we're in this script's directory
cd "$( cd "$( dirname "$(realpath -m "${BASH_SOURCE[0]}")" )" && pwd )" || exit;

# Assign variable one scope above the caller
# Usage: local "$1" && _upvar $1 "value(s)"
# Param: $1  Variable name to assign value to
# Param: $*  Value(s) to assign.  If multiple values, an array is
#            assigned, otherwise a single value is assigned.
# See: http://fvue.nl/wiki/Bash:_Passing_variables_by_reference
_upvar() {
    if unset -v "$1"; then
        if (( $# == 2 )); then
            # shellcheck disable=SC2086
            eval $1=\"\$2\";
        else
            # shellcheck disable=SC1083
            # shellcheck disable=SC2086
            eval $1=\(\"\${@:2}\"\);
        fi;
    fi
}

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
echo "os_name=${NAME_:${VERSION_CODENAME}}";
echo "os_major=${major}";
echo "os_minor=${minor}";
echo "os_id_and_ver=${ID}${major}${minor}";
echo "os_id_and_ver_and_dot=${ID}${major}.${minor}";
);
    if test -n "${out_-}"; then
        _upvar                                                 \
            "${out_}"                                          \
            "[name]='${os_name-}'"                             \
            "[major]='${os_major-}'"                           \
            "[minor]='${os_minor-}'"                           \
            "[id_and_ver]='${os_id_and_ver-}'"                 \
            "[id_and_ver_and_dot]='${os_id_and_ver_and_dot-}'" ;
    fi
}

get_os_info_jammy() {
    local -;
    # shellcheck disable=SC2034
    local -A os_jammy;
    get_os_info os_jammy jammy "22";
    readarray -t os_jammy_values <(_expand_assoc os_jammy);
    _upvar "$1" "${os_jammy_values[@]}";
}

list_script_paths() {
    local -;
    local -A os;
    get_os_info os;
    local file;
    for file in "$@"; do
        if test -x "${os[name]}/${file}"; then
            echo "${os[name]}/${file}";
        elif test -x "${file}"; then
            echo "${file}";
        fi
    done
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
        if test -v "${name}_preinstall"; then
            "${name}_preinstall";
        fi
    done

    chmod 0644 /etc/apt/trusted.gpg.d/*.gpg || true;

    apt update;

    for name in "${list[@]}"; do
        if test -v "${name}_install"; then
            "${name}_install";
        fi
        if test -v "${name}_packages"; then
            readarray -O ${#pkgs[@]} -t pkgs <("${name}_packages" | tr -s '[:space:]' | tr '[:blank:]' '\n');
        fi
    done

    apt update;

    if test ${#pkgs[@]} -gt 0; then
        apt install -y --no-install-recommends "${pkgs[@]}";
    fi

    for name in "${list[@]}"; do
        if test -v "${name}_postinstall"; then
            "${name}_postinstall";
        fi
    done
}

readarray -t script_paths <(list_script_paths ./00*.sh);

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

if test -d /customize; then
    rm -rf /customize;
fi
