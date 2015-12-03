# defines:
#
# NM
# OBJCOPY
# LD
# CXX_COMPILER
# C_COMPILER
# CMAKE_SYSTEM_NAME
# CMAKE_SYSTEM_VERSION
# GENROMFS
# LINKER_FLAGS
# CMAKE_EXE_LINKER_FLAGS
# CMAKE_FIND_ROOT_PATH
# CMAKE_FIND_ROOT_PATH_MODE_PROGRAM
# CMAKE_FIND_ROOT_PATH_MODE_LIBRARY
# CMAKE_FIND_ROOT_PATH_MODE_INCLUDE
# HEXAGON_SDK_ROOT

if ("$ENV{HEXAGON_SDK_ROOT}" STREQUAL "")
	message(FATAL_ERROR "HEXAGON_SDK_ROOT not set")
endif()

set(HEXAGON_SDK_ROOT $ENV{HEXAGON_SDK_ROOT})

include(CMakeForceCompiler)

# this one is important
set(CMAKE_SYSTEM_NAME Generic)

#this one not so much
set(CMAKE_SYSTEM_VERSION 1)

# specify the cross compiler
find_program(C_COMPILER arm-linux-gnueabihf-gcc)
if(NOT C_COMPILER)
	message(FATAL_ERROR "could not find arm-linux-gnueabihf-gcc compiler")
endif()
cmake_force_c_compiler(${C_COMPILER} GNU)

# compiler tools
foreach(tool objcopy nm ld)
	string(TOUPPER ${tool} TOOL)
	find_program(${TOOL} arm-linux-gnueabihf-${tool})
	if(NOT ${TOOL})
		message(FATAL_ERROR "could not find arm-linux-gnueabihf-${tool}")
	endif()
endforeach()

# os tools
#foreach(tool echo patch grep rm mkdir nm genromfs cp touch make unzip)
#	string(TOUPPER ${tool} TOOL)
#	find_program(${TOOL} ${tool})
#	if(NOT ${TOOL})
#		message(FATAL_ERROR "could not find ${TOOL}")
#	endif()
#endforeach()

include_directories(
	${HEXAGON_SDK_ROOT}/inc/stddef
	${HEXAGON_SDK_ROOT}/lib/common/remote/ship/UbuntuARM_Debug
	)

set(CMAKE_C_FLAGS "")
set(LINKER_FLAGS "-Wl,-gc-sections")
set(CMAKE_EXE_LINKER_FLAGS ${LINKER_FLAGS})

# where is the target environment 
set(CMAKE_FIND_ROOT_PATH  get_file_component(${C_COMPILER} PATH))

# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
