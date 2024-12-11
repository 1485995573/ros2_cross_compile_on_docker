cmake_minimum_required(VERSION 3.10)

# 设置项目名称和版本
project(QtOpenCVFFmpegTest VERSION 1.0)

# 找到 Qt5、OpenCV 和 FFmpeg 库
find_package(Qt5 REQUIRED COMPONENTS Core Gui Widgets)  # 添加 Qt5 Widgets 模块
find_package(OpenCV REQUIRED)
find_package(PkgConfig REQUIRED)

# FFmpeg 库需要通过 pkg-config 找到
pkg_check_modules(FFMPEG REQUIRED libavcodec libavformat libavutil libswscale)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# 添加源文件
add_executable(QtOpenCVFFmpegTest main.cpp)

# 链接库
target_link_libraries(QtOpenCVFFmpegTest
    Qt5::Core Qt5::Gui Qt5::Widgets  # 添加 Qt5::Widgets
    ${OpenCV_LIBS}
    ${FFMPEG_LIBRARIES}
)
link_directories(/lib/aarch64-linux-gnu)
# 设置 OpenCV 和 FFmpeg 的包含目录
target_include_directories(QtOpenCVFFmpegTest
    PRIVATE
    ${OpenCV_INCLUDE_DIRS}
    ${FFMPEG_INCLUDE_DIRS}
)
