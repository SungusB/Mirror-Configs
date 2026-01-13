#!/bin/bash
# Diretório local onde o repositório será armazenado
target="/mnt/mirror/voidlinux"

# Lockfile para evitar execuções simultâneas
lock="/mnt/mirror/voidlinux_sync.lck"

# Limite de banda em KiB/s (0 = sem limite)
bwlimit=0

# Fonte oficial do Void Linux
source_url="rsync://repo-sync.voidlinux.org/voidlinux"
#source_url=""

#### END CONFIG ####

[ ! -d "${target}" ] && mkdir -p "${target}"

exec 9>"${lock}"
flock -n 9 || exit

# Função para rodar o rsync com opções seguras
rsync_cmd() {
    local -a cmd=(rsync -rlptH --safe-links --delete-delay --fuzzy --delay-updates
        "--timeout=3600" "--contimeout=120" --no-motd --partial --partial-dir=.rsync-partial )

    if stty &>/dev/null; then
        cmd+=(-h -v --progress)
    else
        cmd+=(--quiet)
    fi

    if ((bwlimit>0)); then
        cmd+=("--bwlimit=$bwlimit")
    fi

    "${cmd[@]}" "$@"
}

# Sincroniza o repositório
rsync_cmd \
    "${source_url}" \
    "${target}"

