#!/bin/bash
target="/mnt/mirror/archriscv"

# Lockfile path
lock="/mnt/mirror/syncarchriscvrepo.lck"

bwlimit=0

source_url='rsync://archriscv.felixc.at/archriscv'

#### END CONFIG

[ ! -d "${target}" ] && mkdir -p "${target}"

exec 9>"${lock}"
flock -n 9 || exit

find "${target}" -name '.~tmp~' -exec rm -r {} +

rsync_cmd() {
	local -a cmd=(rsync -rlptH --safe-links --delete-delay --delay-updates
		"--timeout=600" "--contimeout=60" --no-motd)

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


rsync_cmd \
	--exclude='*.links.tar.gz*' \
	"${source_url}" \
	"${target}"
