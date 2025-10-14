cmake_minimum_required(VERSION 3.10)
project(godot-pd)

###############################################################################
# options
###############################################################################

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# build universal binaries on macos
if(APPLE)
  set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64" CACHE STRING "" FORCE)
endif()

###############################################################################
# libs
###############################################################################

add_subdirectory(godot-cpp)

set(PD_MULTI ON CACHE BOOL "" FORCE)
add_subdirectory(libpd)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/libpd/cpp)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  # TODO: is this needed only for windows or for all platforms?
  set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
  set(THREADS_PREFER_PTHREAD_FLAG TRUE)
endif()
find_package(Threads REQUIRED)

# TODO
# to compile external libs (like cyclone) with multi-instance support
# set(PD_MULTI_FLAGS "-DPDINSTANCE=1 -DPDTHREADS=1")
# set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${PD_MULTI_FLAGS}")
# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${PD_MULTI_FLAGS}")

###############################################################################

# figure out what the binary name should be
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  set(TARGET_PLATFORM_NAME "linux")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(TARGET_PLATFORM_NAME "windows")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  set(TARGET_PLATFORM_NAME "macos")
else()
  message(FATAL_ERROR "Target platform unknown!")
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  set(TARGET_PLATFORM_ARCH "universal")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(TARGET_PLATFORM_ARCH "x86_64") # TODO: this is a bit hacky
else()
  set(TARGET_PLATFORM_ARCH ${CMAKE_SYSTEM_PROCESSOR})
endif()

if(CMAKE_BUILD_TYPE STREQUAL "Release")
  set(TARGET_TEMPLATE_NAME "template_release")
elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(TARGET_TEMPLATE_NAME "template_debug")
else()
  message(FATAL_ERROR "CMAKE_BUILD_TYPE must be either Release or Debug")
endif()


# install build into example project by default
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(
    CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_LIST_DIR}/demo/addons/godot-pd/bin"
    CACHE PATH "..."
    FORCE)
endif()

# let's us link depended dlls relative to process on linux
set(CMAKE_INSTALL_RPATH "$ORIGIN")

file(GLOB GODOT_PD_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
add_library(godot-pd SHARED ${GODOT_PD_SOURCES})

target_link_libraries(
  godot-pd
  PRIVATE
    godot-cpp
    libpd_static
    $<$<BOOL:${MINGW}>:-Wl,--export-all-symbols ws2_32 kernel32 -static-libgcc>
    Threads::Threads
)

set_target_properties(
  godot-pd
  PROPERTIES
  CXX_STANDARD 17
  CXX_STANDARD_REQUIRED ON
  OUTPUT_NAME "godot-pd.${TARGET_PLATFORM_NAME}.${TARGET_TEMPLATE_NAME}.${TARGET_PLATFORM_ARCH}"
)

install(TARGETS godot-pd DESTINATION .)
