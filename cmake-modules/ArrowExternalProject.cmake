# arrow external project
# target:
#  - arrow_ep
# depends:
#
# this module defines:
#  - ARROW_HOME
#  - ARROW_SOURCE_DIR
#  - ARROW_INCLUDE_DIR
#  - ARROW_SHARED_LIB
#  - ARROW_STATIC_LIB
#  - ARROW_LIBRARY_DIR
#  - PLASMA_INCLUDE_DIR
#  - PLASMA_STATIC_LIB
#  - PLASMA_SHARED_LIB

set(arrow_URL https://github.com/anuragkh/arrow.git)
set(arrow_TAG s3_test)

set(ARROW_INSTALL_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/external/arrow-install)
set(ARROW_HOME ${ARROW_INSTALL_PREFIX})
set(ARROW_SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/external/arrow/src/arrow_ep)

set(ARROW_INCLUDE_DIR ${ARROW_HOME}/include)
set(ARROW_LIBRARY_DIR ${ARROW_HOME}/lib${LIB_SUFFIX})
set(ARROW_SHARED_LIB ${ARROW_LIBRARY_DIR}/libarrow${CMAKE_SHARED_LIBRARY_SUFFIX})
set(ARROW_STATIC_LIB ${ARROW_LIBRARY_DIR}/libarrow.a)

# plasma in arrow
set(PLASMA_INCLUDE_DIR ${ARROW_HOME}/include)
set(PLASMA_SHARED_LIB ${ARROW_LIBRARY_DIR}/libplasma${CMAKE_SHARED_LIBRARY_SUFFIX})
set(PLASMA_STATIC_LIB ${ARROW_LIBRARY_DIR}/libplasma.a)

find_package(PythonInterp REQUIRED)
message(STATUS "PYTHON_EXECUTABLE for arrow: ${PYTHON_EXECUTABLE}")

set(ARROW_CMAKE_ARGS
        -DCMAKE_BUILD_TYPE:STRING=Release
        -DCMAKE_INSTALL_PREFIX=${ARROW_INSTALL_PREFIX}
        -DCMAKE_C_FLAGS=-g -O3 ${EP_C_FLAGS}
        -DCMAKE_CXX_FLAGS=-g -O3 ${EP_CXX_FLAGS}
        -DARROW_BUILD_TESTS=off
        -DARROW_HDFS=on
        -DARROW_BOOST_USE_SHARED=off
        -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE}
        -DARROW_PYTHON=on
        -DARROW_PLASMA=on
        -DARROW_TENSORFLOW=off
        -DARROW_JEMALLOC=off
        -DARROW_WITH_BROTLI=off
        -DARROW_WITH_LZ4=off
        -DARROW_WITH_ZSTD=off
        -DARROW_WITH_THRIFT=off
        -DARROW_PARQUET=off
        -DARROW_WITH_ZLIB=off
        -DFLATBUFFERS_HOME=${FLATBUFFERS_HOME}
        -DBOOST_ROOT=${BOOST_ROOT}
        -DGLOG_HOME=${GLOG_HOME})

if (APPLE)
  set(ARROW_CMAKE_ARGS ${ARROW_CMAKE_ARGS}
          -DBISON_EXECUTABLE=/usr/local/opt/bison/bin/bison)
endif()

message(STATUS "ARROW_CMAKE_ARGS: ${ARROW_CMAKE_ARGS}")

if (CMAKE_VERSION VERSION_GREATER "3.7")
  set(ARROW_CONFIGURE SOURCE_SUBDIR "cpp" CMAKE_ARGS ${ARROW_CMAKE_ARGS})
else()
  set(ARROW_CONFIGURE CONFIGURE_COMMAND "${CMAKE_COMMAND}" -G "${CMAKE_GENERATOR}"
          ${ARROW_CMAKE_ARGS} "${ARROW_SOURCE_DIR}/cpp")
endif()

ExternalProject_Add(arrow_ep
        PREFIX external/arrow
        DEPENDS flatbuffers boost glog
        GIT_REPOSITORY ${arrow_URL}
        GIT_TAG ${arrow_TAG}
        UPDATE_COMMAND ""
        ${ARROW_CONFIGURE}
        BUILD_BYPRODUCTS "${ARROW_SHARED_LIB}" "${ARROW_STATIC_LIB}"
        LOG_DOWNLOAD ON
        LOG_CONFIGURE ON
        LOG_BUILD ON
        LOG_INSTALL ON)