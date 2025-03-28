cmake_minimum_required(VERSION 3.10...3.27)
project(framebuffer-vncserver)

FILE(GLOB SOURCES src/*.c)
ADD_EXECUTABLE(framebuffer-vncserver ${SOURCES})
INSTALL(TARGETS framebuffer-vncserver RUNTIME DESTINATION bin)

# LIBVNC via pkg-config
find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBVNC REQUIRED libvncserver)
include_directories(${LIBVNC_INCLUDE_DIRS})
link_directories(${LIBVNC_LIBRARY_DIRS})
target_link_libraries(framebuffer-vncserver ${LIBVNC_LIBRARIES})

install(PROGRAMS ${CMAKE_SOURCE_DIR}/framebuffer-vncserver.sh DESTINATION bin)

# Install systemd service file
install(FILES ${CMAKE_SOURCE_DIR}/framebuffer-vncserver.service DESTINATION lib/systemd/system)

set(CPACK_GENERATOR "DEB")
set(CPACK_PACKAGE_NAME "${CPACK_PACKAGE_NAME}")
set(CPACK_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}")
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Ultimaker")
set(CPACK_PACKAGE_CONTACT "support@example.com")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "libvncserver1 (>= 0.9.12)")
include(CPack)
