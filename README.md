
# DeskCam

A simple MacOS app to mirror the camera in different screen locations. It supports person segmentation and allows to toggle between 2 different configurations.

If several monitors are connected, the app will assume you want to place the window in the smaller monitor.

Each configuration specifies:
* Position on the screen (e.g. bottom left corner)
* Size (small, medium, ...)
* Mask for the window (square, circle, ...)
* Segmentation (none, blur, cutout)

Access configution with command+C and toggle between configured modes with control+option+command+T (available globally).

You can test the app in TestFlight at [this public link](https://testflight.apple.com/join/JjlQp2qa).
