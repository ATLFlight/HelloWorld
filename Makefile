############################################################################
# Copyright (c) 2015 Mark Charlebois. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
# 3. Neither the name ATLFlight nor the names of its contributors may be
#    used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
# OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
# AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
############################################################################

all: build_dsp/libhelloworld.so build_arm/helloworld

stubs: helloworld_skel.c helloworld_stub.c

.PHONY: ENV_VARS
ENV_VARS:
	@[ ! -z "${HEXAGON_SDK_ROOT}" ] || (echo "HEXAGON_SDK_ROOT not set" && false)
	@[ ! -z "${HEXAGON_TOOLS_ROOT}" ] || (echo "HEXAGON_TOOLS_ROOT not set" && false)

helloworld_skel.c helloworld_stub.c: helloworld.idl ENV_VARS
	@${HEXAGON_SDK_ROOT}/tools/qaic/Ubuntu14/qaic -mdll -I ${HEXAGON_SDK_ROOT}/inc/stddef helloworld.idl

build_dsp/libhelloworld.so: stubs ENV_VARS
	@mkdir -p build_dsp && cd build_dsp && cmake -Wno-dev ../dsp -DCMAKE_TOOLCHAIN_FILE=Toolchain-qurt.cmake
	@cd build_dsp && make
	
build_arm/helloworld: stubs ENV_VARS
	@mkdir -p build_arm && cd build_arm && cmake -Wno-dev ../arm-linux -DCMAKE_TOOLCHAIN_FILE=Toolchain-arm-linux-gnueabihf.cmake
	@cd build_arm && make

load-hello: build_dsp/libhelloworld.so build_arm/helloworld
	@adb wait-for-devices
	@adb push build_dsp/libhelloworld_skel.so /usr/share/data/adsp/
	@adb push build_dsp/libhelloworld.so /usr/share/data/adsp/	
	@adb push build_arm/helloworld /home/linaro/

.PHONY: ADD_ON
ADD_ON:
	@[ ! -z "${HEXAGON_FC_ADDON}" ] || (echo "HEXAGON_FC_ADDON not set" && false)

load-adsp: ADD_ON
	@adb wait-for-devices
	@adb push ${HEXAGON_FC_ADDON}/images/8074-eagle/normal/adsp_proc/obj/qdsp6v5_ReleaseG/LA/system/etc/firmware /lib/firmware
	@adb shell sync
	@adb reboot

clean:
	@rm -rf build* helloworld_stub.c helloworld_skel.c helloworld.h
