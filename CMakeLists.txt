cmake_minimum_required(VERSION 3.21)

project(order_engine LANGUAGES CXX VERSION 0.1.0)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Emscripten detection - disable incompatible features
if(EMSCRIPTEN)
  message(STATUS "Building with Emscripten")
  set(ENABLE_WARNINGS_AS_ERRORS_DEFAULT OFF)
  set(ENABLE_IPO_DEFAULT OFF)
  set(ENABLE_ASAN_DEFAULT OFF)
  set(ENABLE_TSAN_DEFAULT OFF)
  set(ENABLE_UBSAN_DEFAULT OFF)
  set(ENABLE_CLANG_TIDY_DEFAULT OFF)
  set(ENABLE_CPPCHECK_DEFAULT OFF)
  set(ENABLE_IWYU_DEFAULT OFF)
  option(WASM_SINGLE_FILE "Embed WASM inside the generated .js" ON)
else()
  set(ENABLE_WARNINGS_AS_ERRORS_DEFAULT ON)
  set(ENABLE_IPO_DEFAULT ON)
  set(ENABLE_ASAN_DEFAULT ON)
  set(ENABLE_TSAN_DEFAULT OFF)  # TSan is mutually exclusive with ASan
  set(ENABLE_UBSAN_DEFAULT ON)
  set(ENABLE_CLANG_TIDY_DEFAULT ON)
  set(ENABLE_CPPCHECK_DEFAULT ON)
  set(ENABLE_IWYU_DEFAULT OFF)
endif()

option(ENABLE_WARNINGS_AS_ERRORS "Treat compiler warnings as errors" ${ENABLE_WARNINGS_AS_ERRORS_DEFAULT})
option(ENABLE_IPO "Enable IPO/LTO when supported" ${ENABLE_IPO_DEFAULT})
option(ENABLE_ASAN "Enable address sanitizer" ${ENABLE_ASAN_DEFAULT})
option(ENABLE_TSAN "Enable thread sanitizer" ${ENABLE_TSAN_DEFAULT})
option(ENABLE_UBSAN "Enable undefined behavior sanitizer" ${ENABLE_UBSAN_DEFAULT})
option(ENABLE_CLANG_TIDY "Run clang-tidy during builds" ${ENABLE_CLANG_TIDY_DEFAULT})
option(ENABLE_CPPCHECK "Run cppcheck during builds" ${ENABLE_CPPCHECK_DEFAULT})
option(ENABLE_IWYU "Run include-what-you-use during builds" ${ENABLE_IWYU_DEFAULT})

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

# Sanitizer mutual exclusivity check
if(ENABLE_ASAN AND ENABLE_TSAN)
  message(FATAL_ERROR "ASan and TSan cannot be enabled simultaneously. Disable one of ENABLE_ASAN or ENABLE_TSAN.")
endif()

# Address sanitizer
if(ENABLE_ASAN AND CMAKE_CXX_COMPILER_ID MATCHES ".*Clang|GNU")
  add_compile_options(-fsanitize=address -fno-omit-frame-pointer)
  add_link_options(-fsanitize=address)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    add_link_options(-static-libasan)
  endif()
endif()

# Thread sanitizer
if(ENABLE_TSAN AND CMAKE_CXX_COMPILER_ID MATCHES ".*Clang|GNU")
  add_compile_options(-fsanitize=thread)
  add_link_options(-fsanitize=thread)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    add_link_options(-static-libtsan)
  endif()
endif()

# Undefined behavior sanitizer
if(ENABLE_UBSAN AND CMAKE_CXX_COMPILER_ID MATCHES ".*Clang|GNU")
  add_compile_options(-fsanitize=undefined)
  add_link_options(-fsanitize=undefined)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    add_link_options(-static-libubsan)
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

# Emscripten-specific configuration
if(EMSCRIPTEN)
  set_target_properties(order_engine PROPERTIES
    SUFFIX ".js"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/web"
  )
  
  # Emscripten compile options
  target_compile_options(order_engine PRIVATE
    -sNO_DISABLE_EXCEPTION_CATCHING
  )
  
  # Emscripten link options
  target_link_options(order_engine PRIVATE
    -sWASM=1
    -sEXPORT_ES6=1
    -sMODULARIZE=1
    -sEXPORT_NAME=OrderEngine
    -sENVIRONMENT=web,worker,node
    -sALLOW_MEMORY_GROWTH=1
    -sDISABLE_EXCEPTION_CATCHING=1
    $<$<BOOL:${WASM_SINGLE_FILE}>:-sSINGLE_FILE=1>
  )
  
  # Copy web assets to build directory
  file(GLOB WEB_ASSETS "${CMAKE_SOURCE_DIR}/web/*")
  file(COPY ${WEB_ASSETS} DESTINATION "${CMAKE_BINARY_DIR}/web")
endif()

enable_testing()
include(CTest)
if(BUILD_TESTING AND NOT EMSCRIPTEN)
  add_subdirectory(test)
endif()
