# Cross_compile_based_on_Docker
在docker中交叉编译ARM64_ROS2，[博客](https://blog.csdn.net/weixin_51226647/article/details/144359571)
# 1. 环境安装和代理设置(recommend)
参见[Docker_install.md](./Docker_install.md)
# 2. Getting Started
```bash
# 1. 设置docker代理端口
make set_docker_proxy 
# 2. 安装跨平台支持
make init
# 3. 构建 Docker 镜像
make build_image
# 4. 运行交叉编译容器
make run
# 5. 请自行安装ROS2、opencv、ffmpeg...
# 在dockerfile中RUN apt install不稳定，经常会安装失败，参见./Dockerfile中的注释部分
# 安装好依赖后，重新打包镜像，参见./Docker_install.md的第6章节
# 6. 交叉编译
make build
# 7. 重新编译
make rebuild
```