# arm64-toolchain.cmake
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Specify the cross compiler
set(CMAKE_C_COMPILER arm-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER arm-linux-gnueabihf-g++)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=armv7-a -Wall -fno-common -Wshadow -Wformat-overflow -Wformat-truncation -Wformat=2 -Wundef -Wimplicit-fallthrough=2")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=armv7-a -mfpu=neon -mfloat-abi=hard")
