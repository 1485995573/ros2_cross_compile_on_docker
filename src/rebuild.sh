#!/bin/bash
source /opt/ros/humble/setup.bash
cd test_ros2_env && rm rm build/ install/ log/ -rf
colcon build --packages-select camera_node --parallel-workers $(nproc)