# HelloWorld

A simple hello world program to demonstrate how to run a
program on the Hexagon DSP.

## Environment setup

The following environment varaiables need to be set:

```
HEXAGON_SDK_ROOT
HEXAGON_TOOLS_ROOT
```
If the SDK is installed as $HOME/Qualcomm/Hexagon_SDK/2.0/...
```
HEXAGON_SDK_ROOT=${HOME}/Qualcomm/Hexagon_SDK/2.0
```

The Hexagon SDK 2.0 comes with the Hexagon Tools 6.4.06. There is
a newer toolchain available (7.2.10). Set your HEXAGON_TOOLS_ROOT
environment to the newer tools version:
```
HEXAGON_TOOLS_ROOT=${HOME}/Qualcomm/HEXAGON_Tools/7.2.10/Tools
```

You will also need the armhf cross compiler in your path:
```
export PATH=${HEXAGON_SDK_ROOT}/gcc-linaro-arm-linux-gnueabihf-4.8-2013.08_linux/bin:${PATH}
```

## Building

```
make
```

## Loading the program

Attach the board to your PC via ADB. Then make sure your device can be seen.

```
adb devices
```
You should see something like:
```
$ adb devices
List of devices attached 
997e5d3a	device
```

Now go into the build subdirectory and load the SW on the target:

```
cd build
make helloworld-load
```

This will push helloworld_app to /home/linaro/ on the device, and it will push libhelloworld.so and libhelloworld_skel.so to /usr/share/data/adsp/ on the device.

## Running the program
To see the program output you will need to run mini-dm in another terminal.
```
${HEXAGON_SDK_ROOT}/tools/mini-dm/Linux_Debug/mini-dm
```

To run the program:
```
$ adb shell
# cd /home/linaro
# ./helloworld_app
```

You should output from mini-dm similar to the following:
```
[08500/00]  31:00.930  HAP:8237:Hello World  0037  helloworld_dsp.c
```

You may see additional warning messages but those can generally be ignored.
