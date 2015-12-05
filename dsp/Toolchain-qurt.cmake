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

include(CMakeForceCompiler)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

if ("$ENV{HEXAGON_SDK_ROOT}" STREQUAL "")
	message(FATAL_ERROR
		"The Hexagon SDK version 2.0 must be installed and the environment variable HEXAGON_SDK_ROOT must be set"
		"(e.g. export HEXAGON_SDK_ROOT=/opt/Qualcomm/Hexagon_SDK/2.0)")
else()
	set(HEXAGON_SDK_ROOT $ENV{HEXAGON_SDK_ROOT})
endif()

if ("$ENV{HEXAGON_TOOLS_ROOT}" STREQUAL "")
	message(FATAL_ERROR
		"The HexagonTools version 7.2.10 must be installed and the environment variable HEXAGON_TOOLS_ROOT must be set"
		"(e.g. export HEXAGON_TOOLS_ROOT=/opt/Qualcomm/HEXAGON_Tools/7.2.10/Tools)")
else()
	set(HEXAGON_TOOLS_ROOT $ENV{HEXAGON_TOOLS_ROOT})
endif()

macro (list2string out in)
	set(list ${ARGV})
	list(REMOVE_ITEM list ${out})
	foreach(item ${list})
		set(${out} "${${out}} ${item}")
	endforeach()
endmacro(list2string)

set(V_ARCH "v5")
set(CROSSDEV "hexagon-")
set(HEXAGON_BIN	${HEXAGON_TOOLS_ROOT}/Tools/bin)
set(HEXAGON_LIB_DIR ${HEXAGON_TOOLS_ROOT}/Tools/gnu/hexagon/lib)
set(HEXAGON_ISS_DIR ${HEXAGON_TOOLS_ROOT}/Tools/lib/iss)
set(TOOLSLIB ${HEXAGON_TOOLS_ROOT}/Tools/target/hexagon/lib/${V_ARCH}/G0)

# Use the HexagonTools compiler (7.2.10)
set(CMAKE_C_COMPILER	${HEXAGON_BIN}/${CROSSDEV}clang)
set(CMAKE_CXX_COMPILER  ${HEXAGON_BIN}/${CROSSDEV}clang++)

set(CMAKE_AR	  ${HEXAGON_BIN}/${CROSSDEV}ar CACHE FILEPATH "Archiver")
set(CMAKE_RANLIB  ${HEXAGON_BIN}/${CROSSDEV}ranlib)
set(CMAKE_LINKER  ${HEXAGON_BIN}/${CROSSDEV}ld.qcld)
set(CMAKE_NM	  ${HEXAGON_BIN}/${CROSSDEV}nm)
set(CMAKE_OBJDUMP ${HEXAGON_BIN}/${CROSSDEV}objdump)
set(CMAKE_OBJCOPY ${HEXAGON_BIN}/${CROSSDEV}objcopy)

#set(DYNAMIC_LIBS  -Wl,${TOOLSLIB}/pic/libstdc++.a)

#set(MAXOPTIMIZATION -O0)

# Base CPU flags for each of the supported architectures.
#
set(ARCHCPUFLAGS
	-m${V_ARCH}
	-G0
	)

add_definitions(
	-D__DF_QURT
	-D_PID_T -D_UID_T -D_TIMER_T
	-Dnoreturn_function= 
	-D_HAS_C9X
	-D__EXPORT= 
	-Drestrict=
	-D_DEBUG
	-Wno-error=shadow
	)

# optimisation flags
#
set(ARCHOPTIMIZATION
	-O0
	-g
	-fno-strict-aliasing
	-fdata-sections
	-fno-zero-initialized-in-bss
	)

# Language-specific flags
#
set(ARCHCFLAGS
	-std=gnu99
	-D__CUSTOM_FILE_IO__
	)
set(ARCHCXXFLAGS
	-fno-exceptions
	-fno-rtti
	-std=c++11
	-fno-threadsafe-statics
	-DCONFIG_WCHAR_BUILTIN
	-D__CUSTOM_FILE_IO__
	)

set(ARCHWARNINGS
	-Wall
	-Wextra
	-Werror
	-Wno-unused-parameter
	-Wno-unused-function
	-Wno-unused-variable
	-Wno-gnu-array-member-paren-init
	-Wno-cast-align
	-Wno-missing-braces
	-Wno-strict-aliasing
#   -Werror=float-conversion - works, just needs to be phased in with some effort and needs GCC 4.9+
#   -Wcast-qual  - generates spurious noreturn attribute warnings, try again later
#   -Wconversion - would be nice, but too many "risky-but-safe" conversions in the code
#   -Wcast-align - would help catch bad casts in some cases, but generates too many false positives
	)

# C-specific warnings
#
set(ARCHCWARNINGS
	${ARCHWARNINGS}
	-Wstrict-prototypes
	-Wnested-externs
	)

# C++-specific warnings
#
set(ARCHWARNINGSXX
	${ARCHWARNINGS}
	-Wno-missing-field-initializers
	)
exec_program(${CMAKE_CXX_COMPILER} ${CMAKE_CURRENT_SOURCE_DIR} ARGS -print-libgcc-file-name OUTPUT_VARIABLE LIBGCC)
exec_program(${CMAKE_CXX_COMPILER} ${CMAKE_CURRENT_SOURCE_DIR} ARGS -print-file-name=libm.a OUTPUT_VARIABLE LIBM)
set(EXTRA_LIBS ${EXTRA_LIBS} ${LIBM})

# Flags we pass to the C compiler
#
list2string(CFLAGS 
	${ARCHCFLAGS}
	${ARCHCWARNINGS}
	${ARCHOPTIMIZATION}
	${ARCHCPUFLAGS}
	${ARCHINCLUDES}
	${INSTRUMENTATIONDEFINES}
	${ARCHDEFINES}
	${EXTRADEFINES}
	${EXTRACFLAGS}
	${HEXAGON_INCLUDE_DIRS}
	)

# Flags we pass to the C++ compiler
#
list2string(CXXFLAGS
	${ARCHCXXFLAGS}
	${ARCHWARNINGSXX}
	${ARCHOPTIMIZATION}
	${ARCHCPUFLAGS}
	${ARCHXXINCLUDES}
	${INSTRUMENTATIONDEFINES}
	${ARCHDEFINES}
	${EXTRADEFINES}
	${EXTRACXXFLAGS}
	${HEXAGON_INCLUDE_DIRS}
	)

# Flags we pass to the assembler
#
list2string(AFLAGS
	${CFLAGS} 
	-D__ASSEMBLY__
	${EXTRADEFINES}
	${EXTRAAFLAGS}
	)

# Set cmake flags
#
list2string(QURT_CMAKE_C_FLAGS
	${CMAKE_C_FLAGS}
	${CFLAGS}
	)

set(CMAKE_C_FLAGS ${QURT_CMAKE_C_FLAGS} CACHE STRING "cflags")


list2string(QURT_CMAKE_CXX_FLAGS
	${CMAKE_CXX_FLAGS}
	${CXXFLAGS}
	)

set(CMAKE_CXX_FLAGS ${QURT_CMAKE_CXX_FLAGS} CACHE STRING "cxxflags")

message(STATUS "CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")
message(STATUS "CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")

# Flags we pass to the linker
#
list2string(CMAKE_EXE_LINKER_FLAGS
	-g 
	-mv5 
	-mG0lib 
	-G0 
	-fpic 
	-shared
	-Wl,-Bsymbolic
	-Wl,--wrap=malloc
	-Wl,--wrap=calloc
	-Wl,--wrap=free
	-Wl,--wrap=realloc
	-Wl,--wrap=memalign
	-Wl,--wrap=__stack_chk_fail
	-lc
	${EXTRALDFLAGS}
	)

# where is the target environment 
set(CMAKE_FIND_ROOT_PATH  get_file_component(${C_COMPILER} PATH))

set(CMAKE_C_COMPILER_ID, "Clang")
set(CMAKE_CXX_COMPILER_ID, "Clang")

# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# The Hexagon compiler doesn't support the -rdynamic flag and this is set
# in the base cmake scripts. We have to redefine the __linux_compiler_gnu
# macro for cmake 2.8 to work
set(__LINUX_COMPILER_GNU 1)
macro(__linux_compiler_gnu lang)
  set(CMAKE_SHARED_LIBRARY_LINK_${lang}_FLAGS "")
endmacro()

