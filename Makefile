all: helloworld

build/libhelloworld.so:
	mkdir -p build && cd build && cmake -Wno-dev .. -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/Toolchain-qurt.cmake
	cd build && make
	
helloworld: build/libhelloworld.so

run: build/libhelloworld.so
	adb push build/libhelloworld.so 

clean:
	rm -rf build
