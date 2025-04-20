 #!/bin/sh

echo ">>> 正在更新软件源..."
opkg update

echo ">>> 正在安装 adblock 及相关软件包..."
opkg install adblock luci-app-adblock libustream-mbedtls ca-bundle

echo ">>> 启用 Adblock 服务..."
/etc/init.d/adblock enable
/etc/init.d/adblock start

echo ">>> 设置 Adblock 配置文件（启用自动下载规则）..."
uci set adblock.global.adb_enabled='1'
uci set adblock.global.verbosity='2'
uci set adblock.global.led='none'
uci set adblock.global.report='1'
uci set adblock.global.force_dns='1'
uci set adblock.global.fetch_util='uclient-fetch'
uci commit adblock

echo ">>> 更新广告规则源..."
/etc/init.d/adblock reload

echo ">>> 当前 Adblock 状态："
sleep 3
/etc/init.d/adblock status


