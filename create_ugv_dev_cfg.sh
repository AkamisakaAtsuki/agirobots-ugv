#!/bin/bash
# create_ugv_dev_cfg.sh
# Usage:
#   sudo ./create_ugv_dev_cfg.sh <serial_front_right> <serial_front_left> <serial_rear_right> <serial_rear_left>
#
# 例:
#   sudo ./create_ugv_dev_cfg.sh SN12345 SN23456 SN34567 SN45678
#
# このスクリプトは、各ODriveのシリアル番号をYAML形式の設定ファイルに保存します。
# 作成されるファイルは「ugv_odrive_config.yaml」となります。

if [ "$#" -ne 4 ]; then
  echo "Usage: sudo $0 <serial_front_right> <serial_front_left> <serial_rear_right> <serial_rear_left>"
  exit 1
fi

SERIAL_FRONT_RIGHT=$1
SERIAL_FRONT_LEFT=$2
SERIAL_REAR_RIGHT=$3
SERIAL_REAR_LEFT=$4

mkdir config
CONFIG_FILE="./config/ugv_odrive_config.yaml"

cat > "$CONFIG_FILE" <<EOF
odrives:
  front_right: "$SERIAL_FRONT_RIGHT"
  front_left: "$SERIAL_FRONT_LEFT"
  rear_right: "$SERIAL_REAR_RIGHT"
  rear_left: "$SERIAL_REAR_LEFT"
EOF

echo "Configuration file created at $CONFIG_FILE"
