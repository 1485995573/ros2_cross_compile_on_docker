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
	@export BUILD_COMMAND=None && docker compose run --rm ros2

build:
	@export BUILD_COMMAND=build && docker compose run --rm ros2

rebuild:
	@export BUILD_COMMAND=rebuild && docker compose run --rm ros2
