cmake_minimum_required(VERSION 2.8.9)

project(tiny-kernel C ASM)

# -- apply to all configurations --- #

SET(CMAKE_C_COMPILER "aarch64-linux-gnu-gcc")
SET(CMAKE_ASM_COMPILER "aarch64-linux-gnu-gcc")

SET(CMAKE_C_FLAGS "-Wall -nostdlib -nostartfiles -ffreestanding -Iinclude -mgeneral-regs-only -g -O0")
SET(CMAKE_ASM_FLAGS "-g")

# ---- dir setup ---- #
include_directories(
  ./include
)
 # https://stackoverflow.com/questions/6594796/how-do-i-make-cmake-output-into-a-bin-dir
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/build)

file(GLOB_RECURSE HEADERS
"./*.h"
)

file(GLOB COMMON_SOURCES
  ${HEADERS}
  src/*.c src/*.S)
  
SET(CMAKE_EXE_LINKER_FLAGS "-T ./src/linker.ld")

# ------------------------------------- #
# all executables  
# ------------------------------------- #
add_executable(kernel8.elf
  ${COMMON_SOURCES}
)
  
add_custom_command(TARGET kernel8.elf POST_BUILD
  COMMAND aarch64-linux-gnu-objcopy build/kernel8.elf -O binary kernel8.img
)  

# ------------------------------------- #
add_executable(kernel8-qemu.elf
  ${COMMON_SOURCES}
)

set_target_properties(kernel8-qemu.elf PROPERTIES 
  COMPILE_FLAGS "-DUSE_QEMU" )

add_custom_command(TARGET kernel8-qemu.elf POST_BUILD
  COMMAND aarch64-linux-gnu-objcopy build/kernel8-qemu.elf -O binary kernel8-qemu.img
  )
# ------------------------------------- #  