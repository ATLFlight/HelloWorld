all: helloworld

stubs: helloworld_skel.c helloworld_stub.c

helloworld_skel.c helloworld_stub.c: helloworld.idl
	${HEXAGON_SDK_ROOT}/tools/qaic/Ubuntu14/qaic -m dll -I ${HEXAGON_SDK_ROOT}/inc/stddef $<

build_qurt/libhelloworld.so: stubs
	mkdir -p build_qurt && cd build_qurt && cmake -Wno-dev ../qurt -DCMAKE_TOOLCHAIN_FILE=Toolchain-qurt.cmake
	cd build_qurt && make
	
helloworld: build_qurt/libhelloworld.so build/helloworld

build/helloworld: stubs
	mkdir -p build && cd build && cmake -Wno-dev ../linux -DCMAKE_TOOLCHAIN_FILE=Toolchain-linux.cmake
	cd build && make

run: build/libhelloworld.so
	adb push build/libhelloworld.so 

clean:
	rm -rf build* helloworld_stub.c helloworld_skel.c helloworld.h
