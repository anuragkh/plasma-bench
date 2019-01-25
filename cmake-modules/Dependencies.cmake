include(ExternalProject)
include(CMakeParseArguments)

function(ADD_THIRDPARTY_LIB LIB_NAME)
  set(options)
  set(one_value_args SHARED_LIB STATIC_LIB)
  set(multi_value_args DEPS)
  cmake_parse_arguments(ARG "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
  if(ARG_UNPARSED_ARGUMENTS)
    message(SEND_ERROR "Error: unrecognized arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  if(ARG_STATIC_LIB AND ARG_SHARED_LIB)
    if(NOT ARG_STATIC_LIB)
      message(FATAL_ERROR "No static or shared library provided for ${LIB_NAME}")
    endif()

    SET(AUG_LIB_NAME "${LIB_NAME}_static")
    add_library(${AUG_LIB_NAME} STATIC IMPORTED)
    set_target_properties(${AUG_LIB_NAME}
            PROPERTIES IMPORTED_LOCATION "${ARG_STATIC_LIB}")
    message("Added static library dependency ${LIB_NAME}: ${ARG_STATIC_LIB}")

    SET(AUG_LIB_NAME "${LIB_NAME}_shared")
    add_library(${AUG_LIB_NAME} SHARED IMPORTED)

    if(MSVC)
      # Mark the ”.lib” location as part of a Windows DLL
      set_target_properties(${AUG_LIB_NAME}
              PROPERTIES IMPORTED_IMPLIB "${ARG_SHARED_LIB}")
    else()
      set_target_properties(${AUG_LIB_NAME}
              PROPERTIES IMPORTED_LOCATION "${ARG_SHARED_LIB}")
    endif()
    if(ARG_DEPS)
      set_target_properties(${AUG_LIB_NAME}
              PROPERTIES IMPORTED_LINK_INTERFACE_LIBRARIES "${ARG_DEPS}")
    endif()
    message("Added shared library dependency ${LIB_NAME}: ${ARG_SHARED_LIB}")
  elseif(ARG_STATIC_LIB)
    add_library(${LIB_NAME} STATIC IMPORTED)
    set_target_properties(${LIB_NAME}
            PROPERTIES IMPORTED_LOCATION "${ARG_STATIC_LIB}")
    SET(AUG_LIB_NAME "${LIB_NAME}_static")
    add_library(${AUG_LIB_NAME} STATIC IMPORTED)
    set_target_properties(${AUG_LIB_NAME}
            PROPERTIES IMPORTED_LOCATION "${ARG_STATIC_LIB}")
    if(ARG_DEPS)
      set_target_properties(${AUG_LIB_NAME}
              PROPERTIES IMPORTED_LINK_INTERFACE_LIBRARIES "${ARG_DEPS}")
    endif()
    message("Added static library dependency ${LIB_NAME}: ${ARG_STATIC_LIB}")
  elseif(ARG_SHARED_LIB)
    add_library(${LIB_NAME} SHARED IMPORTED)
    set_target_properties(${LIB_NAME}
            PROPERTIES IMPORTED_LOCATION "${ARG_SHARED_LIB}")
    SET(AUG_LIB_NAME "${LIB_NAME}_shared")
    add_library(${AUG_LIB_NAME} SHARED IMPORTED)

    if(MSVC)
      # Mark the ”.lib” location as part of a Windows DLL
      set_target_properties(${AUG_LIB_NAME}
              PROPERTIES IMPORTED_IMPLIB "${ARG_SHARED_LIB}")
    else()
      set_target_properties(${AUG_LIB_NAME}
              PROPERTIES IMPORTED_LOCATION "${ARG_SHARED_LIB}")
    endif()
    message("Added shared library dependency ${LIB_NAME}: ${ARG_SHARED_LIB}")
    if(ARG_DEPS)
      set_target_properties(${AUG_LIB_NAME}
              PROPERTIES IMPORTED_LINK_INTERFACE_LIBRARIES "${ARG_DEPS}")
    endif()
  else()
    message(FATAL_ERROR "No static or shared library provided for ${LIB_NAME}")
  endif()
endfunction()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -g -Werror -Wall -Wno-error=unused-function -Wno-error=strict-aliasing")

# The rdynamic flag is needed to produce better backtraces on Linux.
if(UNIX AND NOT APPLE)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -rdynamic")
endif()

# Custom CFLAGS

set(CMAKE_C_FLAGS "-g -Wall -Wextra -Werror=implicit-function-declaration -Wno-sign-compare -Wno-unused-parameter -Wno-type-limits -Wno-missing-field-initializers --std=c99 -fPIC -std=c99")

# The following is needed because in CentOS, the lib directory is named lib64
if(EXISTS "/etc/redhat-release" AND CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(LIB_SUFFIX 64)
endif()

include(GlogExternalProject)
message(STATUS "Glog home: ${GLOG_HOME}")
message(STATUS "Glog include dir: ${GLOG_INCLUDE_DIR}")
message(STATUS "Glog static lib: ${GLOG_STATIC_LIB}")

include_directories(${GLOG_INCLUDE_DIR})
ADD_THIRDPARTY_LIB(glog
        STATIC_LIB ${GLOG_STATIC_LIB})

add_dependencies(glog glog_ep)

# boost
include(BoostExternalProject)

message(STATUS "Boost root: ${BOOST_ROOT}")
message(STATUS "Boost include dir: ${Boost_INCLUDE_DIR}")
message(STATUS "Boost system library: ${Boost_SYSTEM_LIBRARY}")
message(STATUS "Boost filesystem library: ${Boost_FILESYSTEM_LIBRARY}")
include_directories(${Boost_INCLUDE_DIR})

ADD_THIRDPARTY_LIB(boost_system
        STATIC_LIB ${Boost_SYSTEM_LIBRARY})
ADD_THIRDPARTY_LIB(boost_filesystem
        STATIC_LIB ${Boost_FILESYSTEM_LIBRARY})
ADD_THIRDPARTY_LIB(boost_thread
        STATIC_LIB ${Boost_THREAD_LIBRARY})

add_dependencies(boost_system boost_ep)
add_dependencies(boost_filesystem boost_ep)
add_dependencies(boost_thread boost_ep)

add_custom_target(boost DEPENDS boost_system boost_filesystem boost_thread)

# flatbuffers
include(FlatBuffersExternalProject)

message(STATUS "Flatbuffers home: ${FLATBUFFERS_HOME}")
message(STATUS "Flatbuffers include dir: ${FLATBUFFERS_INCLUDE_DIR}")
message(STATUS "Flatbuffers static library: ${FLATBUFFERS_STATIC_LIB}")
message(STATUS "Flatbuffers compiler: ${FLATBUFFERS_COMPILER}")
include_directories(SYSTEM ${FLATBUFFERS_INCLUDE_DIR})

ADD_THIRDPARTY_LIB(flatbuffers STATIC_LIB ${FLATBUFFERS_STATIC_LIB})

add_dependencies(flatbuffers flatbuffers_ep)

# Apache Arrow, use FLATBUFFERS_HOME and BOOST_ROOT
include(ArrowExternalProject)

message(STATUS "Arrow home: ${ARROW_HOME}")
message(STATUS "Arrow source dir: ${ARROW_SOURCE_DIR}")
message(STATUS "Arrow include dir: ${ARROW_INCLUDE_DIR}")
message(STATUS "Arrow static library: ${ARROW_STATIC_LIB}")
message(STATUS "Arrow shared library: ${ARROW_SHARED_LIB}")
include_directories(SYSTEM ${ARROW_INCLUDE_DIR})

ADD_THIRDPARTY_LIB(arrow STATIC_LIB ${ARROW_STATIC_LIB})

add_dependencies(arrow arrow_ep)

# Plasma, it is already built in arrow
message(STATUS "Plasma include dir: ${PLASMA_INCLUDE_DIR}")
message(STATUS "Plasma static library: ${PLASMA_STATIC_LIB}")
message(STATUS "Plasma shared library: ${PLASMA_SHARED_LIB}")
include_directories(SYSTEM ${PLASMA_INCLUDE_DIR})

ADD_THIRDPARTY_LIB(plasma STATIC_LIB ${PLASMA_STATIC_LIB})

add_dependencies(plasma arrow_ep)