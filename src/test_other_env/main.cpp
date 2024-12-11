#include <QApplication>
#include <QLabel>
#include <opencv2/opencv.hpp>
#include <iostream>
extern "C"{
    #include <libavcodec/avcodec.h>
    #include <libavformat/avformat.h>
    #include <libswscale/swscale.h>
}

int main(int argc, char *argv[]) {
    // 初始化 Qt 应用
    QApplication app(argc, argv);

    // 测试 OpenCV: 读取并显示一张图片
    cv::Mat img = cv::imread("/path/to/your/image.jpg"); // 修改为实际图片路径
    if (img.empty()) {
        std::cerr << "Error: Could not open image!" << std::endl;
        return -1;
    }

    // 显示 OpenCV 图像
    cv::imshow("OpenCV Image", img);
    cv::waitKey(0); // 等待按键

    // 测试 FFmpeg: 输出 FFmpeg 版本
    av_register_all();
    std::cout << "FFmpeg version: " << av_version_info() << std::endl;

    // 测试 Qt: 显示简单的标签
    QLabel label("Hello from Qt!");
    label.show();

    return app.exec();
}
