#!/bin/sh

###############################################################################
# FreeBSD Mirror Sync Script
#
# Sincroniza o projeto FreeBSD completo usando rsync
# com controle de lock, logging e variáveis configuráveis.
###############################################################################

# =========================
# CONFIGURAÇÕES
# =========================

# Upstream rsync
RSYNC_SOURCE="rsync://ftp2.br.FreeBSD.org/FreeBSD/"

# Diretório local do mirror
MIRROR_PATH="/mnt/mirror/freebsd"

# Arquivo de lock
LOCKFILE="/mnt/mirror/sync_freebsd_mirror.lock"

# Log
LOGFILE="/mnt/mirror/sync_freebsd_mirror.log"

# Binários
RSYNC_BIN="/usr/bin/rsync"

# Opções do rsync
RSYNC_OPTS="-avHz --delete --delete-delay --partial --stats"

# =========================
# FUNÇÕES
# =========================

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOGFILE"
}

cleanup() {
    log "Removendo lock e finalizando."
    rm -f "$LOCKFILE"
    exit
}

# =========================
# VERIFICAÇÕES
# =========================

# Garante que o rsync existe
if [ ! -x "$RSYNC_BIN" ]; then
    echo "ERRO: rsync não encontrado em $RSYNC_BIN"
    exit 1
fi

# Verifica se o diretório existe
if [ ! -d "$MIRROR_PATH" ]; then
    log "Diretório $MIRROR_PATH não existe. Criando..."
    mkdir -p "$MIRROR_PATH" || exit 1
fi

# =========================
# LOCK
# =========================

if [ -f "$LOCKFILE" ]; then
    PID=$(cat "$LOCKFILE")
    if ps -p "$PID" >/dev/null 2>&1; then
        log "Outro sync já está rodando (PID $PID). Abortando."
        exit 0
    else
        log "Lock antigo encontrado. Limpando."
        rm -f "$LOCKFILE"
    fi
fi

echo $$ > "$LOCKFILE"

# Remove lock se receber sinais
trap cleanup INT TERM EXIT

# =========================
# SINCRONIZAÇÃO
# =========================

log "Iniciando sincronização do FreeBSD"
log "Origem : $RSYNC_SOURCE"
log "Destino: $MIRROR_PATH"

$RSYNC_BIN $RSYNC_OPTS \
    "$RSYNC_SOURCE" \
    "$MIRROR_PATH" >> "$LOGFILE" 2>&1

RSYNC_STATUS=$?

if [ $RSYNC_STATUS -eq 0 ]; then
    log "Sincronização finalizada com sucesso."
else
    log "ERRO: rsync terminou com código $RSYNC_STATUS"
fi

cleanup
