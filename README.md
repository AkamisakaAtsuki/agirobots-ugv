# agirobots-ugv

# 使用環境
``` bash
pi@raspberry:~ $ cat /etc/os-release
PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"
NAME="Debian GNU/Linux"
VERSION_ID="12"
VERSION="12 (bookworm)"
VERSION_CODENAME=bookworm
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
```

# セットアップ
## Dockerの導入
``` bash
cd install 
./docker_debian.sh
```

## 主な手順
odriveで回すには、その前にモータの設定を永続メモリに書き込んで再起動する必要がある。設定はodrivetoolを使用して書き込むので以下を実行する。

``` bash
odrivetool
```
今回はリンク（https://amzn.asia/d/790prhe）の電動ホイールを例に考える。
分解して中身をみると、磁石の数が30個（SNペアでいうと15個）。他にも確認してほしいところはありますが、とりあえず以下で対応しました。

``` python
odrv0.axis0.motor.config.pole_pairs = 15  # 磁石の数（30個ならSNペアで15個）
odrv0.axis0.motor.config.resistance_calib_max_voltage = 4   
odrv0.axis0.motor.config.requested_current_range = 25 
odrv0.axis0.motor.config.current_control_bandwidth = 100

odrv0.axis0.motor.config.torque_constant = 8.27 / 16  # 単位はNm/A。この値が異なるとPD?制御が上手く働かない
odrv0.axis0.encoder.config.mode = ENCODER_MODE_HALL
odrv0.axis0.encoder.config.cpr = 90
odrv0.axis0.encoder.config.calib_scan_distance = 150

odrv0.axis0.encoder.config.bandwidth = 100
odrv0.axis0.controller.config.pos_gain = 1
odrv0.axis0.controller.config.vel_gain = 0.02 * odrv0.axis0.motor.config.torque_constant * odrv0.axis0.encoder.config.cpr
odrv0.axis0.controller.config.vel_integrator_gain = 0.1 * odrv0.axis0.motor.config.torque_constant * odrv0.axis0.encoder.config.cpr
odrv0.axis0.controller.config.vel_limit = 10

odrv0.axis0.controller.config.control_mode = CONTROL_MODE_VELOCITY_CONTROL

odrv0.axis0.motor.config.current_lim = 5
odrv0.axis0.motor.config.calibration_current = 5 # モータの最大連続定格電流の50%を超えないように（今回のwheelは約10AがMaxなのでその50%は5A）

odrv0.save_configuration()
odrv0.reboot()
```

キャリブレーションを保存
```python
odrv0.axis0.requested_state = AXIS_STATE_MOTOR_CALIBRATION
odrv0.axis0.motor
odrv0.axis0.motor.config.pre_calibrated = True

odrv0.axis0.requested_state = AXIS_STATE_ENCODER_OFFSET_CALIBRATION
odrv0.axis0.encoder
odrv0.axis0.encoder.config.pre_calibrated = True

odrv0.save_configuration()
odrv0.reboot()
```

設定を全てリセットしたい時は以下を使用する。
``` python
odrv0.erase_configuration()
```

odrv0.axis0.requested_state = AXIS_STATE_CLOSED_LOOP_CONTROL
odrv0.axis0.controller.input_vel = 2


## 4つの電動ホイールのIDを設定する
### IDの確認
１つずつODriveのデバイスを接続し、以下を実行したときに、表示された番号がIDとなる。
``` bash
sudo lsusb -v -s $(lsusb | grep -i odrive | awk '{print $2 ":" substr($4, 1, length($4)-1)}') | grep -i "iSerial" | awk '{print $3}'
```
### IDの設定
IDの確認にて確認した各々のIDを、以下の順番で記載して実行。
```bash
sudo ./create_ugv_dev_cfg.sh <serial_front_right> <serial_front_left> <serial_rear_right> <serial_rear_left>
# EX) sudo ./create_ugv_dev_cfg.sh 12345 23456 34567 45678
```
## コンテナの作成・起動と実行
### コンテナをビルドする
``` bash
docker build -t odrive .
```
### コンテナを起動
``` bash
cd agirobots-ugv
docker run -it --privileged --volume /dev:/dev --volume ./config:/root/ros_workspace/config odrive
```