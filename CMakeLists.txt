cmake_minimum_required(VERSION 3.10)
project(plasma_bench)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake-modules")

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(ExternalProject)
include(GNUInstallDirs)
include(Dependencies)

add_executable(plasma_bench src/main.cpp src/plasma_writer.cc src/plasma_writer.h src/benchmark_runner.h src/plasma_reader.cc src/plasma_reader.h)
target_link_libraries(plasma_bench plasma arrow glog ${CMAKE_THREAD_LIBS_INIT})
