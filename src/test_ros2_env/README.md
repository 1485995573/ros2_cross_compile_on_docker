# 1. 项目开发环境说明
1. 系统：
    - lubancat4-ubntu22.04-server
    - linux_kernel-6.1.84
2. 编译工具链：
    - aarch64-linux-gnu-11.4.0
3. 第三方框架：
    - opencv-4.5.4
    - ffmpeg-6.0.1
    - Qt-5.15.3
    - Ros2-Humble
    - hkvision_SDK_ARM64
4. 开发工具：
    - VScode
    - Windterm
5. 补充：版本查询方式
    ```bash
    # ubuntu版本
    lsb_release -a
    # linux_kernel版本
    uname -r
    # opencv版本
    pkg-config --modversion opencv4
    # ffmpeg版本
    ffmpeg -version
    # Qt版本
    qmake --version
    # ROS版本
    printenv | grep -i ROS
    ```