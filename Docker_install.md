# Docker Engine多平台镜像构建(ARM64、x64、riscv64...)
# 1. Docker Engine安装
1. 设置 Docker 的存储库
    ```bash
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    ```
2. 安装 Docker 软件包
    ```bash
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```
3. 以非 root 用户身份管理 Docker
	`运行完这里，记得重启电脑`
    ```bash
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
    ```
# 2. bridge-nf-call-iptables问题
```bash
docker info
WARNING: bridge-nf-call-iptables is disabled
WARNING: bridge-nf-call-ip6tables is disabled
# 解决办法：
sudo vi /etc/sysctl.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
sudo sysctl -p
# 检查是否生效
sudo sysctl net.bridge.bridge-nf-call-iptables
sudo sysctl net.bridge.bridge-nf-call-ip6tables
```
# 3. 代理配置问题
`用代理就没必要设置镜像源了`
```bash
sudo mkdir /etc/systemd/system/docker.service.d
sudo touch /etc/systemd/system/docker.service.d/proxy.conf
sudo vim /etc/systemd/system/docker.service.d/proxy.conf
# 把下面的内容拷贝进proxy.conf, 代理端口7897需要根据自己的情况设置
[Service] 
Environment="HTTP_PROXY=localhost:7897" 
Environment="HTTPS_PROXY=localhost:7897"
```
`测试代理设置`
```bash
$ docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
c1ec31eb5944: Pull complete 
Digest: sha256:305243c734571da2d100c8c8b3c3167a098cab6049c9a5b066b6021a60fcb966
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

```
# 4. 构建多平台镜像问题
## 4.1 前言
`目的是`：在X64电脑上运行ARM64架构的docker镜像，这样可以在镜像上开发代码，最后打包镜像分发。`这么做好处是`：可以直接在ARM64端安装docker并下载镜像，运行镜像即可实现项目部署。
## 4.2 buildx安装和测试
1. 安装
    ```bash
    # 将 buildx 设置为默认构建器
    docker buildx install
    # 安装 QEMU 模拟支持多架构
    docker run --privileged --rm tonistiigi/binfmt --install all
    ```
2. 编辑Dockerfile
    ```bash
    touch Dockerfile
    ```
    把下面的内容复制进Dockerfile中
    ```
    # syntax=docker/dockerfile:1

    # 使用一个轻量级的 ARM 架构镜像
    FROM --platform=linux/arm64 alpine:latest

    # 设置工作目录
    WORKDIR /app

    # 创建一个简单的文件
    RUN echo "Hello from ARM64 architecture!" > hello.txt

    # 显示文件内容
    CMD cat hello.txt

    ```
3. 测试
   ```bash
   # 创建镜像
   docker buildx build --platform linux/arm64 -t my-arm64-image .
   # 运行镜像
   docker run --platform linux/arm64 my-arm64-image
   ```

# 5 Dockerfile构建和容器使用代理问题
## 5.1 前言
`问题背景：`
1. 在Dockerfile中，使用`apt update && apt install...`的时候，无法访问apt源
2. 在容器内部，使用`apt update && apt install...`的时候，无法访问apt源
## 5.2 网络以及代理配置
我的项目文件结构如下

```bash
$ tree -L 1
.
├── compose.yaml
├── Dockerfile
├── Docker_install.md
├── LICENSE
├── Makefile
├── README.md
└── src
```
### 5.2.1 Makefile
```bash
# 定义代理配置文件路径
PROXY_CONF_FILE = /etc/systemd/system/docker.service.d/proxy.conf

.PHONY: build rebuild set_docker_proxy init build_image run 

# 使用环境变量 PORT 来传递端口
PROXY_PORT ?= 7897
IMAGE_NAME ?= arm64_ros2_v1.0

# 修改 proxy.conf 中的端口
set_docker_proxy:
	@echo "Updating proxy port to $(PROXY_PORT) in $(PROXY_CONF_FILE)..."
	@sudo sed -i "s|Environment=\"HTTP_PROXY=.*\"|Environment=\"HTTP_PROXY=localhost:$(PROXY_PORT)\"|" $(PROXY_CONF_FILE)
	@sudo sed -i "s|Environment=\"HTTPS_PROXY=.*\"|Environment=\"HTTPS_PROXY=localhost:$(PROXY_PORT)\"|" $(PROXY_CONF_FILE)
	@echo "Port updated successfully to $(PROXY_PORT)."
	@sudo systemctl daemon-reload
	@sudo systemctl restart docker

# 安装跨平台支持
init:
	@docker run --privileged --rm tonistiigi/binfmt --install all

# 构建 Docker 镜像
build_image:
	@echo "Building Docker image: $(IMAGE_NAME)..."
	@docker buildx build --platform linux/arm64 \
		--build-arg http_proxy=http://127.0.0.1:$(PROXY_PORT) \
		--build-arg https_proxy=http://127.0.0.1:$(PROXY_PORT) \
		--build-arg no_proxy=localhost,127.0.0.1 \
		--network host \
		-t $(IMAGE_NAME) .
	@echo "Docker image $(IMAGE_NAME) built successfully."

run:
	@docker run --platform linux/arm64 \
	-e http_proxy=http://127.0.0.1:$(PROXY_PORT) \
	-e https_proxy=http://127.0.0.1:$(PROXY_PORT) \
	-e no_proxy=localhost,127.0.0.1 \
	--network host \
	--name ros2 \
	-it --rm $(IMAGE_NAME):latest bash

build:
	@export BUILD_COMMAND=build && docker compose run --rm ros2

rebuild:
	@export BUILD_COMMAND=rebuild && docker compose run --rm ros2
```
### 5.2.3 compose.yaml
```bash
services:
  ros2:
    image: arm64_ros2_v1.0:latest      # 使用镜像
    container_name: ros2               # 容器名称
    environment:                       # 配置环境变量
      - http_proxy=http://127.0.0.1:7897
      - https_proxy=http://127.0.0.1:7897
      - no_proxy=localhost,127.0.0.1
      - QT_QPA_PLATFORM=offscreen      # 设置 Qt 使用 offscreen 插件
    network_mode: host                 # 使用主机网络
    stdin_open: true                   # 支持交互
    tty: true                          # 启用伪终端
    volumes:                           # 映射卷
      - ./src:/app
    # command: /bin/bash -c "/app/cross_compile.sh && \bash" # 启动脚本后保持 bash 交互
    command: >
      bash -c "
        echo BUILD_COMMAND = ${BUILD_COMMAND}
        if [ ${BUILD_COMMAND} == build ]; then
          ./build.sh;
        elif [ ${BUILD_COMMAND} == rebuild ]; then
          ./rebuild.sh;
        else
          echo 'No valid command specified';
        fi"
```
# 6 补充笔记
1. 把现有容器打包成新镜像，例如把`CONTAINER ID：21498c429b79`容器打包成名叫`arm64_ros2_v1.0`的镜像

```bash
# 查看现有容器
$ docker ps -a
CONTAINER ID   IMAGE                    COMMAND   CREATED             STATUS                      PORTS     NAMES
a7ed4ed09832   arm64_ros2_v1.0:latest   "bash"    15 minutes ago      Up 15 minutes                         ros2-cross-build-ros2-run-48cc0ee073c9
21498c429b79   arm64_ros2:latest        "bash"    About an hour ago   Exited (0) 38 minutes ago             ARM64_ROS2
# 打包新镜像
docker commit 21498c429b79 arm64_ros2_v1.0
```

# 7 参考资料
1. [Docker Engine官方安装教程文档](https://docs.docker.com/engine/install/ubuntu/)
2. [ROS2交叉编译官方文档](https://docs.ros.org/en/humble/How-To-Guides/Cross-compilation.html)
3. [docker多平台镜像构建工具:buildx](https://github.com/docker/buildx#building-multi-platform-images)
4. [buildx官方文档](https://docs.docker.com/reference/cli/docker/buildx/)