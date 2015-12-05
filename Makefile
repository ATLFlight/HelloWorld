all: build_dsp/libhelloworld.so build_arm/helloworld

stubs: helloworld_skel.c helloworld_stub.c

helloworld_skel.c helloworld_stub.c: helloworld.idl
	${HEXAGON_SDK_ROOT}/tools/qaic/Ubuntu14/qaic -mdll -I ${HEXAGON_SDK_ROOT}/inc/stddef $<

build_dsp/libhelloworld.so: stubs
	mkdir -p build_dsp && cd build_dsp && cmake -Wno-dev ../dsp -DCMAKE_TOOLCHAIN_FILE=Toolchain-qurt.cmake
	cd build_dsp && make
	
build_arm/helloworld: stubs
	mkdir -p build_arm && cd build_arm && cmake -Wno-dev ../arm-linux -DCMAKE_TOOLCHAIN_FILE=Toolchain-arm-linux-gnueabihf.cmake
	cd build_arm && make

load: build_dsp/libhelloworld.so build_arm/helloworld
	adb wait-for-devices
	adb push build_dsp/libhelloworld_skel.so /usr/share/data/adsp/
	adb push build_dsp/libhelloworld.so /usr/share/data/adsp/	
	adb push build_arm/helloworld /home/linaro/

clean:
	rm -rf build* helloworld_stub.c helloworld_skel.c helloworld.h
