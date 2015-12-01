#
# Copyright (C) 2015 Mark Charlebois. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#	notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#	notice, this list of conditions and the following disclaimer in
#	the documentation and/or other materials provided with the
#	distribution.
# 3. Neither the name PX4 nor the names of its contributors may be
#	used to endorse or promote products derived from this software
#	without specific prior written permission.
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
#

include(CMakeForceCompiler)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

if ("$ENV{HEXAGON_SDK_ROOT}" STREQUAL "")
	message(FATAL_ERROR
		"The HexagonSDK version 2.0 must be installed and the environment variable HEXAGON_SDK_ROOT must be set"
		"(e.g. export HEXAGON_SDK_ROOT=/opt/Qualcomm/Hexagon_SDK/2.0)")
else()
	set(HEXAGON_SDK_ROOT $ENV{HEXAGON_SDK_ROOT})
endif()

include_directories(
	${HEXAGON_SDK_ROOT}/inc/stddef
	${HEXAGON_SDK_ROOT}/lib/common/remote/ship/UbuntuARM_Release
	)

set(CMAKE_C_FLAGS -g CACHE STRING "cflags")


message(STATUS "CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")

# Flags we pass to the linker
#
set(CMAKE_EXE_LINKER_FLAGS -lc CACHE STRING "linkflags")

# where is the target environment 
set(CMAKE_FIND_ROOT_PATH  get_file_component(${C_COMPILER} PATH))

