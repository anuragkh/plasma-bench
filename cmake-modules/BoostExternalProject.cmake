# Boost external project
# target:
#  - boost_ep
# defines:
#  - Boost_INCLUDE_DIR
#  - Boost_SYSTEM_LIBRARY
#  - Boost_FILESYSTEM_LIBRARY
#  - Boost_THREAD_LIBRARY

# Set the required boost version.
set(BOOST_MAJOR_VERSION 1)
set(BOOST_MINOR_VERSION 68)
set(BOOST_SUBMINOR_VERSION 0)
set(TARGET_BOOST_VERSION ${BOOST_MAJOR_VERSION}.${BOOST_MINOR_VERSION}.${BOOST_SUBMINOR_VERSION})

set(Boost_INSTALL_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/external/boost-install)

set(Boost_INCLUDE_DIR ${Boost_INSTALL_PREFIX}/include)
set(BOOST_ROOT ${Boost_INSTALL_PREFIX})
set(Boost_LIBRARY_DIR ${Boost_INSTALL_PREFIX}/lib)
set(Boost_SYSTEM_LIBRARY ${Boost_LIBRARY_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}boost_system${CMAKE_STATIC_LIBRARY_SUFFIX})
set(Boost_THREAD_LIBRARY ${Boost_LIBRARY_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}boost_thread${CMAKE_STATIC_LIBRARY_SUFFIX})
set(Boost_FILESYSTEM_LIBRARY ${Boost_LIBRARY_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}boost_filesystem${CMAKE_STATIC_LIBRARY_SUFFIX})

#set(boost_URL https://github.com/boostorg/boost.git)
#set(boost_TAG boost-1.68.0)

set(Boost_TAR_GZ_URL http://dl.bintray.com/boostorg/release/1.68.0/source/boost_1_68_0.tar.gz)
set(Boost_BUILD_PRODUCTS ${Boost_SYSTEM_LIBRARY} ${Boost_FILESYSTEM_LIBRARY})
set(Boost_URL_MD5 "5d8b4503582fffa9eefdb9045359c239")

set(Boost_USE_STATIC_LIBS ON)

ExternalProject_Add(boost_ep
        PREFIX external/boost
        URL ${Boost_TAR_GZ_URL}
        URL_MD5 ${Boost_URL_MD5}
        #    GIT_REPOSITORY ${boost_URL}
        #    GIT_TAG ${boost_TAG}
        #    GIT_SUBMODULES ""
        BUILD_IN_SOURCE 1
        BUILD_BYPRODUCTS ${Boost_BUILD_PRODUCTS}
        CONFIGURE_COMMAND ./bootstrap.sh
        BUILD_COMMAND bash -c "./b2 cxxflags=\"-fPIC -D_GLIBCXX_USE_CXX11_ABI=0\" cflags=-fPIC variant=release link=static --with-filesystem --with-system --with-thread --with-atomic --with-chrono --with-date_time --with-regex -j8 install --prefix=${Boost_INSTALL_PREFIX} > /dev/null"
        INSTALL_COMMAND "")