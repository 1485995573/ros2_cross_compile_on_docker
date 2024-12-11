#!/bin/bash
source /opt/ros/humble/setup.bash
cd test_ros2_env
colcon build --packages-select camera_node --parallel-workers $(nproc)