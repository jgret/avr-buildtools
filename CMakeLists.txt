# I target a recent cmake, it shouldn't be a problem on a dev machine
cmake_minimum_required(VERSION 3.11)

set(PRODUCT_NAME led)

project(${PRODUCT_NAME})

set(F_CPU 16000000UL)
set(BAUD 19200)
set(MCU atmega1284p)

# Use AVR GCC toolchain
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_CXX_COMPILER avr-g++)
set(CMAKE_C_COMPILER avr-gcc)
set(CMAKE_ASM_COMPILER avr-gcc)


# Pass defines to compiler
add_definitions(
    -DF_CPU=${F_CPU}
    -DBAUD=${BAUD}
)

# mmcu MUST be passed to bot the compiler and linker, this handle the linker
set(CMAKE_EXE_LINKER_FLAGS -mmcu=${MCU})


add_compile_options(
    -mmcu=${MCU} # MCU
    -Os # optimize
    -Wall # enable warnings
    -Wno-main
    -Wundef
    -pedantic
    #-Werror
    -Wfatal-errors
    -Wl,--relax,--gc-sections
    -g
    -gdwarf-2
    -funsigned-char # a few optimizations
    -funsigned-bitfields
    -fpack-struct
    -fshort-enums
    -ffunction-sections
    -fdata-sections
    -fno-split-wide-types
    -fno-tree-scev-cprop
    -save-temps
    -u
    -vfprintf
    -lprintf_min
    -lprintf_flt
    -lm
)

include_directories(${PROJECT_SOURCE_DIR})

file(GLOB SRC_FILES "./main.c") # Load all files in src folder

# Create one target
add_executable(${PRODUCT_NAME} ${SRC_FILES})

# Rename the output to .elf as we will create multiple files
set_target_properties(${PRODUCT_NAME} PROPERTIES OUTPUT_NAME ${PRODUCT_NAME}.elf)

# Strip binary for upload
add_custom_target(strip ALL avr-strip ${PRODUCT_NAME}.elf DEPENDS ${PRODUCT_NAME})

# Transform binary into hex file, we ignore the eeprom segments in the step
add_custom_target(hex ALL avr-objcopy -R .eeprom -O ihex ${PRODUCT_NAME}.elf ${PRODUCT_NAME}.hex DEPENDS strip)

# view size
add_custom_target(size ALL avr-size --mcu=${MCU} ${PRODUCT_NAME}.elf ${PRODUCT_NAME}.hex)

# clean
add_custom_target(clean-all
    COMMAND rm *.s *.i
)