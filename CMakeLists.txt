cmake_minimum_required(VERSION 3.21)

project(order_engine LANGUAGES CXX VERSION 0.1.0)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(ENABLE_WARNINGS_AS_ERRORS "Treat compiler warnings as errors" ON)
option(ENABLE_IPO "Enable IPO/LTO when supported" ON)
option(ENABLE_ASAN "Enable address sanitizer" ON)
option(ENABLE_CLANG_TIDY "Run clang-tidy during builds" ON)
option(ENABLE_CPPCHECK "Run cppcheck during builds" ON)
option(ENABLE_IWYU "Run include-what-you-use during builds" OFF)

# Compiler warnings (as interface library to apply only to project targets)
add_library(project_warnings INTERFACE)
target_compile_options(project_warnings INTERFACE
    -Wall -Wextra -Wshadow -Wnon-virtual-dtor -Wold-style-cast -Wcast-align
    -Wunused -Woverloaded-virtual -Wpedantic -Wconversion -Wsign-conversion
    -Wnull-dereference -Wdouble-promotion -Wformat=2 -Wimplicit-fallthrough)
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_compile_options(project_warnings INTERFACE
      -Wmisleading-indentation -Wduplicated-cond -Wduplicated-branches
      -Wlogical-op -Wuseless-cast -Wsuggest-override)
endif()
if(ENABLE_WARNINGS_AS_ERRORS)
  target_compile_options(project_warnings INTERFACE -Werror)
endif()

# IPO/LTO
if(ENABLE_IPO)
  include(CheckIPOSupported)
  check_ipo_supported(RESULT ipo_supported OUTPUT ipo_output)
  if(ipo_supported)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)
  else()
    message(SEND_ERROR "IPO is not supported: ${ipo_output}")
  endif()
endif()

# Address sanitizer
if(ENABLE_ASAN AND CMAKE_CXX_COMPILER_ID MATCHES ".*Clang|GNU")
  add_compile_options(-fsanitize=address -fno-omit-frame-pointer)
  add_link_options(-fsanitize=address)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    add_link_options(-static-libasan)
  endif()
endif()

# Clang-tidy
if(ENABLE_CLANG_TIDY)
  find_program(CLANGTIDY clang-tidy)
  if(CLANGTIDY)
    set(CMAKE_CXX_CLANG_TIDY ${CLANGTIDY}
        -extra-arg=-std=c++${CMAKE_CXX_STANDARD}
        -extra-arg=-Wno-unknown-warning-option
        -p)
    if(ENABLE_WARNINGS_AS_ERRORS)
      list(APPEND CMAKE_CXX_CLANG_TIDY -warnings-as-errors=*)
    endif()
  else()
    message(WARNING "clang-tidy requested but executable not found")
  endif()
endif()

# Cppcheck
if(ENABLE_CPPCHECK)
  find_program(CPPCHECK cppcheck)
  if(CPPCHECK)
    set(CMAKE_CXX_CPPCHECK ${CPPCHECK} --template=gcc
        --enable=style,performance,warning,portability --inline-suppr --inconclusive
        --suppress=cppcheckError --suppress=internalAstError --suppress=unmatchedSuppression
        --suppress=passedByValue --suppress=syntaxError --suppress=preprocessorErrorDirective
        --suppress=knownConditionTrueFalse --std=c++${CMAKE_CXX_STANDARD})
    if(ENABLE_WARNINGS_AS_ERRORS)
      list(APPEND CMAKE_CXX_CPPCHECK --error-exitcode=2)
    endif()
  else()
    message(WARNING "cppcheck requested but executable not found")
  endif()
endif()

# Include-what-you-use
if(ENABLE_IWYU)
  find_program(IWYU include-what-you-use)
  if(IWYU)
    set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE ${IWYU})
  else()
    message(WARNING "include-what-you-use requested but executable not found")
  endif()
endif()

add_executable(order_engine src/main.cpp)
target_link_libraries(order_engine PRIVATE project_warnings)

include(CTest)
if(BUILD_TESTING)
  add_subdirectory(test)
endif()
