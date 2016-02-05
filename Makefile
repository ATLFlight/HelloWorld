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

.PHONY all:
all: submodule helloworld

GETTING_STARTED_MSG="See https://github.com/ATLFlight/ATLFlightDocs/blob/master/GettingStarted.md"

.PHONY: helloworld

.PHONY check_env:
	@if [ "${HEXAGON_SDK_ROOT}" = "" ]; then echo "HEXAGON_SDK_ROOT not set"; echo ${GETTING_STARTED_MSG}; false; fi
	@if [ "${HEXAGON_TOOLS_ROOT}" = "" ]; then echo "HEXAGON_TOOLS_ROOT not set"; echo ${GETTING_STARTED_MSG}; false; fi

helloworld: check_env
	@mkdir -p build && cd build && cmake -Wno-dev .. -DCMAKE_TOOLCHAIN_FILE=cmake_hexagon/toolchain/Toolchain-qurt.cmake
	@cd build && make

.PHONY submodule:
submodule:
	git submodule init
	git submodule update

clean:
	@rm -rf build

load: all
	adb shell rm -f /usr/share/data/adsp/libexample_interface_skel.so /usr/share/data/adsp/libhelloworld.so /home/linaro/helloworld_app
	adb push build/libexample_interface_skel.so /usr/share/data/adsp/
	adb push build/libhelloworld.so /usr/share/data/adsp/
	adb push build/helloworld_app /home/linaro/
	adb shell sync
