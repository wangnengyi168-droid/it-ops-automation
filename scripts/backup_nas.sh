#!/bin/bash
# NAS 备份脚本
# 用法: ./backup_nas.sh [源目录] [目标NAS]
# 示例: ./backup_nas.sh /home/wang/backup wang2025.lan

SRC=${1:-/home/wang/backup}
NAS=${2:-wang2025.lan}
DEST="/home/wang/nas-mount/backups"

echo "[$(date)] 开始备份 $SRC -> $NAS"
rsync -av --delete "$SRC/" "$DEST/" >> /home/wang/logs/nas_backup.log 2>&1

if [ $? -eq 0 ]; then
    echo "[$(date)] ✅ 备份成功"
else
    echo "[$(date)] ❌ 备份失败"
    exit 1
fi
