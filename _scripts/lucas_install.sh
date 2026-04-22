#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ALIAS_FILE_SRC="${SCRIPT_DIR}/bash_aliases.sh"
ALIAS_FILE_DST="${HOME}/.bash_aliases"
POTATOS_SRC="${PROJECT_ROOT}/Potatos/"
TOOLS_SRC="${SCRIPT_DIR}/tools"
POTATOS_DST="${HOME}/.potatos/"
DRY_RUN=false
ASSET_MODE="copy" # copy|link (link packages/ + tools/)
INIT_REPO=false
LUCASD_LABS_DIR="${HOME}/Lucas.D/Lucas.D-labs/"
IS_TERMUX=false
HAS_RSYNC=false

log() {
    printf '[install.sh] %s\n' "$*"
}

usage() {
    cat <<'EOF'
Usage: install.sh [--dry-run|-n] [--link-wa y]

Options:
  -n, --dry-run    Print planned actions without changing files
      --link-way
                  Don't copy Potatos/packages and Rice/tools.
                  Instead create symlinks under ~/.potatos/:
                    ~/.potatos/packages -> <repo>/Protect/Potatos/packages
                    ~/.potatos/tools    -> <repo>/Protect/Rice/tools
                  In this mode, install.sh is linked as ~/.potatos/install.sh
  -h, --help       Show this help message
  -i, --init       Initialize ${LUCASD_LABS_DIR} with repo init/sync
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n|--dry-run)
                DRY_RUN=true
                ;;
            -lw|--link-way)
                ASSET_MODE="link"
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -i|--init)
                INIT_REPO=true
                ;;
            *)
                log "unknown option: $1"
                usage
                exit 1
                ;;
        esac
        shift
    done
}

run_cmd() {
    if [[ "${DRY_RUN}" == true ]]; then
        log "[dry-run] $*"
    else
        "$@"
    fi
}

detect_platform() {
    if [[ -n "${TERMUX_VERSION:-}" ]] || [[ -d "/data/data/com.termux/files/home" ]]; then
        IS_TERMUX=true
    fi
}

has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

check_dependencies() {
    local required_cmds=(cp mkdir grep)
    local cmd

    for cmd in "${required_cmds[@]}"; do
        if ! has_cmd "${cmd}"; then
            log "missing required command: ${cmd}"
            exit 1
        fi
    done

    if has_cmd rsync; then
        HAS_RSYNC=true
    else
        HAS_RSYNC=false
        if [[ "${IS_TERMUX}" == true ]]; then
            log "rsync not found, will fallback to cp -a in Termux"
            log "tip: pkg install rsync"
        else
            log "rsync not found, will fallback to cp -a"
        fi
    fi
}

sync_dir() {
    local src="$1"
    local dst="$2"

    if [[ "${HAS_RSYNC}" == true ]]; then
        run_cmd rsync -a "${src}" "${dst}"
    else
        run_cmd cp -a "${src}/." "${dst}/"
    fi
}

sync_dir_excluding_packages() {
    local src="$1"
    local dst="$2"

    if [[ "${HAS_RSYNC}" == true ]]; then
        run_cmd rsync -a --exclude 'packages/' "${src}" "${dst}"
    else
        run_cmd cp -a "${src}/." "${dst}/"
        run_cmd rm -rf "${dst}/packages"
    fi
}

ensure_alias_loader_in_file() {
    local rc_file="$1"
    local snippet=$'if [ -f ~/.bash_aliases ]; then\n    . ~/.bash_aliases\nfi'
    local needs_leading_newline=false

    if [[ ! -f "${rc_file}" ]]; then
        run_cmd touch "${rc_file}"
    fi

    if [[ -f "${rc_file}" ]] && grep -Fq '. ~/.bash_aliases' "${rc_file}"; then
        log "bash_aliases loader already exists in ${rc_file}"
        return 0
    fi

    if [[ -f "${rc_file}" ]] && [[ -s "${rc_file}" ]]; then
        needs_leading_newline=true
    fi

    if [[ "${DRY_RUN}" == true ]]; then
        if [[ "${needs_leading_newline}" == true ]]; then
            log "[dry-run] append loader snippet (with leading newline) to ${rc_file}"
        else
            log "[dry-run] append loader snippet to ${rc_file}"
        fi
    else
        if [[ "${needs_leading_newline}" == true ]]; then
            printf '\n%s\n' "${snippet}" >> "${rc_file}"
        else
            printf '%s\n' "${snippet}" >> "${rc_file}"
        fi
        log "added bash_aliases loader to ${rc_file}"
    fi
}

ensure_alias_loader_for_non_ubuntu() {
    local rc_files=()

    if [[ "${IS_TERMUX}" == true ]]; then
        rc_files=("${HOME}/.bashrc" "${HOME}/.profile")
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        rc_files=("${HOME}/.zshrc")
    else
        rc_files=("${HOME}/.bashrc" "${HOME}/.zshrc")
    fi

    for rc in "${rc_files[@]}"; do
        ensure_alias_loader_in_file "${rc}"
    done

    if [[ "${DRY_RUN}" == true ]]; then
        log '[dry-run] skip sourcing rc files'
        return 0
    fi

    if [[ "${IS_TERMUX}" == true ]]; then
        # shellcheck disable=SC1090
        . "${HOME}/.bashrc"
        log 'sourced ~/.bashrc'
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        # shellcheck disable=SC1090
        . "${HOME}/.zshrc"
        log 'sourced ~/.zshrc'
    elif [[ -n "${SHELL:-}" ]] && [[ "${SHELL}" == *zsh* ]]; then
        # shellcheck disable=SC1090
        . "${HOME}/.zshrc"
        log 'sourced ~/.zshrc'
    else
        # shellcheck disable=SC1090
        . "${HOME}/.bashrc"
        log 'sourced ~/.bashrc'
    fi
}

copy_aliases_file() {
    if [[ ! -f "${ALIAS_FILE_SRC}" ]]; then
        log "source file not found: ${ALIAS_FILE_SRC}"
        exit 1
    fi

    run_cmd cp "${ALIAS_FILE_SRC}" "${ALIAS_FILE_DST}"
    if [[ "${DRY_RUN}" == true ]]; then
        log "would copy ${ALIAS_FILE_SRC} -> ${ALIAS_FILE_DST}"
    else
        log "copied ${ALIAS_FILE_SRC} -> ${ALIAS_FILE_DST}"
    fi
}

ensure_symlink() {
    local src="$1"
    local dst="$2"

    if [[ "${DRY_RUN}" == true ]]; then
        log "[dry-run] ln -sfn ${src} ${dst}"
        return 0
    fi

    mkdir -p "$(dirname "${dst}")"
    ln -sfn "${src}" "${dst}"
    log "linked ${dst} -> ${src}"
}

sync_potatos_assets() {
    run_cmd mkdir -p "${POTATOS_DST}"

    if [[ -d "${POTATOS_SRC}" ]]; then
        if [[ "${ASSET_MODE}" == "link" ]]; then
            sync_dir_excluding_packages "${POTATOS_SRC}" "${POTATOS_DST}"
        else
            sync_dir "${POTATOS_SRC}" "${POTATOS_DST}"
        fi
        if [[ "${DRY_RUN}" == true ]]; then
            log "would sync ${POTATOS_SRC} -> ${POTATOS_DST}"
        else
            log "synced ${POTATOS_SRC} -> ${POTATOS_DST}"
        fi
    else
        log "skip missing directory: ${POTATOS_SRC}"
    fi

    if [[ "${ASSET_MODE}" == "link" ]]; then
        if [[ -d "${POTATOS_SRC}packages" ]]; then
            ensure_symlink "${POTATOS_SRC}packages" "${POTATOS_DST}packages"
        else
            log "skip missing directory: ${POTATOS_SRC}packages"
        fi

        if [[ -d "${TOOLS_SRC}" ]]; then
            ensure_symlink "${TOOLS_SRC}" "${POTATOS_DST}tools"
        else
            log "skip missing directory: ${TOOLS_SRC}"
        fi

        ensure_symlink "${SCRIPT_DIR}/install.sh" "${POTATOS_DST}install.sh"
    else
        if [[ -d "${TOOLS_SRC}" ]]; then
            sync_dir "${TOOLS_SRC}" "${POTATOS_DST}"
            if [[ "${DRY_RUN}" == true ]]; then
                log "would sync ${TOOLS_SRC} -> ${POTATOS_DST}"
            else
                log "synced ${TOOLS_SRC} -> ${POTATOS_DST}"
            fi
        else
            log "skip missing directory: ${TOOLS_SRC}"
        fi

        run_cmd mkdir -p "${POTATOS_DST}tools"
        run_cmd cp -a "${SCRIPT_DIR}/install.sh" "${POTATOS_DST}tools/"
        if [[ "${DRY_RUN}" == true ]]; then
            log "would copy ${SCRIPT_DIR}/install.sh -> ${POTATOS_DST}tools/"
        else
            log "copied ${SCRIPT_DIR}/install.sh -> ${POTATOS_DST}tools/"
        fi
    fi
}

init_lucasd_labs_repo() {
    if ! has_cmd repo; then
        log 'missing required command: repo'
        if [[ "${IS_TERMUX}" == true ]]; then
            log 'tip: install with `pkg install repo`'
        fi
        exit 1
    fi

    if [[ "${DRY_RUN}" == true ]]; then
        log "[dry-run] mkdir -p ${LUCASD_LABS_DIR}"
        log "[dry-run] cd ${LUCASD_LABS_DIR}"
        log "[dry-run] repo init --manifest-url git@github.com:KingofHubGit/lucas_manifests.git -b main -m github.xml --no-repo-verify"
        log "[dry-run] repo sync"
        return 0
    fi

    mkdir -p "${LUCASD_LABS_DIR}"
    log "ensured directory exists: ${LUCASD_LABS_DIR}"
    cd "${LUCASD_LABS_DIR}"
    log "entered directory: ${LUCASD_LABS_DIR}"

    repo init --manifest-url git@github.com:KingofHubGit/lucas_manifests.git -b main -m github.xml --no-repo-verify
    repo sync
    repo start --all main
    log "repo init/sync completed"
}

main() {
    parse_args "$@"
    detect_platform
    check_dependencies

    if [[ "${DRY_RUN}" == true ]]; then
        log 'running in dry-run mode'
    fi

    if [[ "${INIT_REPO}" == true ]]; then
        init_lucasd_labs_repo
        return 0
    fi

    copy_aliases_file

    if [[ "${IS_TERMUX}" == true ]]; then
        log 'detected Termux, ensuring rc loader snippets'
        ensure_alias_loader_for_non_ubuntu
    elif [[ -f /etc/os-release ]] && grep -qi '^ID=ubuntu$' /etc/os-release; then
        log 'detected Ubuntu, alias file copied only'
    else
        log 'detected non-Ubuntu system, ensuring rc loader snippets'
        ensure_alias_loader_for_non_ubuntu
    fi

    sync_potatos_assets

    log 'done'
}

main "$@"
