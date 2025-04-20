 #!/bin/sh

echo "=== 开始安装 MiniDLNA 和 USB 支持 ==="

# 1. 更新软件包列表并安装必要组件
opkg update
opkg install \
kmod-usb-storage block-mount kmod-fs-ext4 kmod-fs-ntfs ntfs-3g \
usbutils kmod-usb2 kmod-usb3 \
minidlna luci-app-minidlna

# 2. 创建挂载目录
mkdir -p /mnt/usb

# 3. 配置 FSTAB 自动挂载
uci -q delete fstab.@mount[0]
uci add fstab mount
uci set fstab.@mount[-1].device='/dev/sda2'
uci set fstab.@mount[-1].target='/mnt/sda2'
uci set fstab.@mount[-1].enabled='1'
uci set fstab.@mount[-1].fstype='auto'
uci set fstab.@mount[-1].options='rw,sync'
uci commit fstab
/etc/init.d/fstab enable
/etc/init.d/fstab restart

# 4. 配置 MiniDLNA
uci set minidlna.@minidlna[0].enabled='1'
uci set minidlna.@minidlna[0].media_dir='mnt/sda2'
uci set minidlna.@minidlna[0].port='8200'
uci set minidlna.@minidlna[0].friendly_name='OpenWRT_MediaServer'
uci set minidlna.@minidlna[0].inotify='1'
uci set minidlna.@minidlna[0].root_container='B'
uci commit minidlna
/etc/init.d/minidlna enable
/etc/init.d/minidlna start

# 5. 设置热插拔自动挂载和刷新 DLNA
HOTPLUG_SCRIPT="/etc/hotplug.d/block/10-mount"
cat << 'EOF' > $HOTPLUG_SCRIPT
#!/bin/sh
[ "$ACTION" = "add" ] || exit 0
MOUNT_POINT="/mnt/$DEVNAME"
mkdir -p "$MOUNT_POINT"
mount -o rw /dev/$DEVNAME "$MOUNT_POINT"
chown -R nobody:nogroup "$MOUNT_POINT"
chmod -R 755 "$MOUNT_POINT"
/etc/init.d/minidlna restart
EOF

chmod +x $HOTPLUG_SCRIPT

# 6. 设置权限
chown -R nobody:nogroup /mnt/sda2
chmod -R 755 /mnt/sda2

echo "=== 安装与配置完成！请插入 USB 硬盘测试 DLNA 功能 ==="


