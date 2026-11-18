#!/bin/bash
# ============================================================================
# Ночь темного Ворона — Рестарт WorldServer
# Запускается watcher_service.js при изменении Lua-файлов
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$(cd "$SCRIPT_DIR/../server" && pwd)"
WORLDSERVER_EXE="$SERVER_DIR/worldserver"
PID_FILE="/tmp/nightdarkraven_worldserver.pid"

echo "[$(date)] Рестарт WorldServer..."

# Убиваем старый процесс если есть PID
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        kill "$OLD_PID" 2>/dev/null || true
        sleep 2
        kill -9 "$OLD_PID" 2>/dev/null || true
        echo "Старый процесс $OLD_PID завершен."
    fi
fi

# Запускаем новый worldserver в фоне и сохраняем PID
cd "$SERVER_DIR"
nohup "$WORLDSERVER_EXE" > "$SERVER_DIR/worldserver.log" 2>&1 &
echo $! > "$PID_FILE"
echo "WorldServer запущен с PID $(cat "$PID_FILE")"