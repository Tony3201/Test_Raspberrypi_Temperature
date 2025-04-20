 #!/bin/sh
echo "=== MiniDLNA USB 修复工具 v1.0 ==="

MOUNT_POINT="/mnt/sda2"
DEVICE="/dev/sda2"
USER_ID=65534  # nobody
GROUP_ID=65534 # nogroup

# 1. 检查是否已挂载
if mount | grep -q "$MOUNT_POINT"; then
    echo "[✔] 设备已挂载在 $MOUNT_POINT"
else
    echo "[✘] 设备未挂载，尝试挂载..."
    mkdir -p "$MOUNT_POINT"
    ntfs-3g "$DEVICE" "$MOUNT_POINT" -o uid=$USER_ID,gid=$GROUP_ID,umask=0022
    if mount | grep -q "$MOUNT_POINT"; then
        echo "[✔] 挂载成功：$MOUNT_POINT"
    else
        echo "[✘] 挂载失败，请检查设备是否存在：$DEVICE"
        exit 1
    fi
fi

# 2. 检查挂载类型
FS_TYPE=$(mount | grep "$MOUNT_POINT" | awk '{print $5}')
if [ "$FS_TYPE" != "ntfs" ] && [ "$FS_TYPE" != "ntfs-3g" ]; then
    echo "[!] 挂载文件系统为 $FS_TYPE，建议使用 ntfs-3g 以支持权限控制"
else
    echo "[✔] 文件系统类型：$FS_TYPE"
fi

# 3. 权限修复
echo "[•] 设置媒体目录权限为 nobody:nogroup..."
chown -R nobody:nogroup "$MOUNT_POINT"
chmod -R 755 "$MOUNT_POINT"

# 4. 检查媒体文件是否存在
echo "[•] 检查媒体文件..."
MEDIA_FILES=$(find
 "$MOUNT_POINT" -type f \( -iname "*.mp4" -o -iname "*.avi" -o -iname 
"*.mkv" -o -iname "*.mp3" -o -iname "*.jpg" \) | wc -l)

if [ "$MEDIA_FILES" -eq 0 ]; then
    echo "[⚠️ ] 未检测到支持的媒体文件，请检查目录下是否存在 .mp4/.mp3/.jpg 等文件"
else
    echo "[✔] 检测到 $MEDIA_FILES 个媒体文件"
fi

# 5. 重启 DLNA 服务
echo "[•] 重启 MiniDLNA 服务并重建数据库..."
rm -rf /var/run/minidlna/*
/etc/init.d/minidlna stop
/etc/init.d/minidlna start
sleep 2
/etc/init.d/minidlna restart

echo "[✔] MiniDLNA 已重新启动，稍等几分钟可在客户端设备中看到媒体内容"

# 6. 提示
echo "=== 完成。请确保客户端与 DLNA 服务在同一局域网 ==="


