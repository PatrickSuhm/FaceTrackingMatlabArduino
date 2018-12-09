# FaceTrackingMatlabArduino
This repository contains example code for the following Youtube video: 
- https://www.youtube.com/watch?v=X1eb78jfWw4

## Getting Started
[FaceTrackingMatlabArduino.m](https://github.com/PatrickSuhm/FaceTrackingMatlabArduino/blob/master/FaceTrackingMatlabArduino.m) is a simple Matlab script for face tracking with a camera that can be tilted and panned. To use it, you need an Arduino and camera, that is mounted on a pan/tilt platform. The two servos of the pan/tilt platform have to be connected to two, digital pins, of the Arduino. To keep things simple, the "Matlab Support Package for Arduino" is used, so there is no need to program the Arduino, just install the support package in Matlab and connect the Arduino to you computer. Then make some minor changes in the code, to adjust for your specific hardware.

## Prerequisites
- Matlab with the Arduino Support Package
- Arduino
- USB camera
- pan/tilt platform with servos

### Author
Patrick Suhm
