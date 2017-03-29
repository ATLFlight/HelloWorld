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

# This Makefile shows two examples of how to build a QuRT application.
# helloworld-bundle builds both the apps proc and dsp sides of the app from
# one CMakeLists.txt file.
#
# An alternative wat to build the app is to build the adsp lib and apps proc
# portions separately.
# helloworld builds just the apps proc portion and
# libhelloworld just builds the adsp portion.

.PHONY all check_env helloworld libhelloworld submodule submodules:

all: helloworld libhelloworld

GETTING_STARTED_MSG="See https://github.com/ATLFlight/ATLFlightDocs/blob/master/GettingStarted.md"

QC_SOC_TARGET?="APQ8074"
UPDATE_SUB_MODULE_2_LATEST?=0

ifeq (${UPDATE_SUB_MODULE_2_LATEST},1)
        SUBMODULE_FLAG=--remote
else
        SUBMODULE_FLAG=--init
endif

check_env:
	@if [ "${HEXAGON_SDK_ROOT}" = "" ]; then echo "HEXAGON_SDK_ROOT not set"; echo ${GETTING_STARTED_MSG}; false; fi
	@if [ "${HEXAGON_TOOLS_ROOT}" = "" ]; then echo "HEXAGON_TOOLS_ROOT not set"; echo ${GETTING_STARTED_MSG}; false; fi


# This target builds only helloworld for apps proc
helloworld: submodules
	@mkdir -p build_apps && cd build_apps && cmake -Wno-dev ../apps_proc -DQC_SOC_TARGET=${QC_SOC_TARGET} -DCMAKE_TOOLCHAIN_FILE=../cmake_hexagon/toolchain/Toolchain-arm-linux-gnueabihf.cmake
	@cd build_apps && make
	
# This target builds only libhelloworld.so and libhelloworld_skel.so for adsp proc
libhelloworld: submodules
	@mkdir -p build_adsp && cd build_adsp && cmake -Wno-dev ../adsp_proc -DQC_SOC_TARGET=${QC_SOC_TARGET} -DCMAKE_TOOLCHAIN_FILE=../cmake_hexagon/toolchain/Toolchain-qurt.cmake
	@cd build_adsp && make
	
submodule: cmake_hexagon

submodules:
	git submodule init && git submodule update ${SUBMODULE_FLAG}

clean:
	@rm -rf build_adsp build_apps

load: libhelloworld helloworld
	adb shell rm -f /usr/share/data/adsp/libexample_interface_skel.so /usr/share/data/adsp/libhelloworld.so /home/linaro/helloworld*
	cd build_adsp && make libhelloworld-load
	cd build_apps && make helloworld-load

