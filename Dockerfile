# 使用 Ubuntu 22.04 (Jammy)
FROM ubuntu:jammy

# 设置工作目录
WORKDIR /app

# 使用 ARG 来接收 build 传递的环境变量
ARG http_proxy
ARG https_proxy
ARG no_proxy

# 设置环境变量
ENV http_proxy=${http_proxy}
ENV https_proxy=${https_proxy}
ENV no_proxy=${no_proxy}

# 更新系统并安装必要的工具，包括 ARM64 工具链和其他常用工具
RUN apt update && apt install -y build-essential cmake git wget curl pkg-config unzip \
                                        tar vim gcc-aarch64-linux-gnu g++-aarch64-linux-gnu

# 安装 ROS2, RUN apt不稳定，自行在容器里面安装吧
# RUN apt update && apt install -y locales && \
#     locale-gen en_US en_US.UTF-8 && \
#     update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
#     export LANG=en_US.UTF-8 && \
#     apt install -y software-properties-common && \
#     add-apt-repository universe && \
#     apt update && apt install -y curl && \
#     curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
#     echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
#     apt update && apt install -y ros-humble-ros-base ros-dev-tools

# 安装 Qt5, OpenCV 和 FFmpeg, RUN apt不稳定，自行在容器里面安装吧
# RUN apt install -y qt5-qmake qtbase5-dev qtchooser qtbase5-dev-tools libopencv-dev ffmpeg \
#     libavcodec-dev libavformat-dev libavutil-dev libswscale-dev

# 创建一个简单的文件
RUN echo "Hello from ARM64 ubuntu22.04 ROS2 Humble!" > hello.txt

# 设置默认命令，验证文件内容
CMD cat hello.txt
