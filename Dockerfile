# Ubuntu Jammy + ROS 2 Humbleが含まれる公式イメージを使用
FROM ros:humble

# 必要な追加パッケージがあればここでインストール
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-pip \
    libusb-1.0-0 \
    # その他プロジェクトに必要なパッケージ
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install odrive
RUN echo "PATH=$PATH:~/.local/bin/" >> ~/.bashrc 

# ワークディレクトリの設定（必要に応じて変更）
WORKDIR /root/ros_workspace

# コンテナ起動時にbashを起動する
CMD ["bash"]
