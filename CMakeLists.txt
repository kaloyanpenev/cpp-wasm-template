cmake_minimum_required(VERSION 3.21)

# Project name from central config
file(READ "${CMAKE_SOURCE_DIR}/project.json" PROJECT_JSON)
string(JSON PROJECT_NAME_VAR GET ${PROJECT_JSON} "name")

project(${PROJECT_NAME_VAR} VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Build Type Configuration
set(CMAKE_BUILD_TYPES Debug RelWithDebInfo Release)

if(NOT CMAKE_CONFIGURATION_TYPES)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${CMAKE_BUILD_TYPES})
endif()

# Set default build type to RelWithDebInfo if not specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "Build type" FORCE)
  message(STATUS "Build type not specified, defaulting to RelWithDebInfo")
endif()

# Configure optimization flags for each build type
# CMake will automatically use CMAKE_CXX_FLAGS_<BUILD_TYPE> based on CMAKE_BUILD_TYPE
if(MSVC)
  # MSVC optimization flags
  set(CMAKE_CXX_FLAGS_DEBUG "/Od /Zi /MDd" CACHE STRING "Debug compiler flags" FORCE)
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "/O2 /Zi /MD" CACHE STRING "RelWithDebInfo compiler flags" FORCE)
  set(CMAKE_CXX_FLAGS_RELEASE "/O2 /DNDEBUG /MD" CACHE STRING "Release compiler flags" FORCE)
else()
  # GCC/Clang optimization flags
  set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g" CACHE STRING "Debug compiler flags" FORCE)
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g" CACHE STRING "RelWithDebInfo compiler flags" FORCE)
  set(CMAKE_CXX_FLAGS_RELEASE "-O2 -DNDEBUG" CACHE STRING "Release compiler flags" FORCE)
endif()

# CMake modules
# Configure build type defaults and define CMake options
include(cmake/Options.cmake)
# Enable compiler cache (ccache/sccache) when available
include(cmake/Cache.cmake)
# Configure compiler warning flags and warnings-as-errors
include(cmake/CompilerWarnings.cmake)
# Configure sanitizer flags (ASan, LSan, TSan, UBSan, MSan)
include(cmake/Sanitizers.cmake)
# Configure static analysis tools (clang-tidy, cppcheck, IWYU)
include(cmake/StaticAnalyzers.cmake)
# Configure interprocedural optimization (LTO)
include(cmake/InterproceduralOptimization.cmake)

# Try to enable compiler cache early in configuration
project_enable_cache()

# Main target
add_executable(${PROJECT_NAME} src/main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE project_warnings project_sanitizers)

# Emscripten configuration
include(cmake/Emscripten.cmake)

# Testing
if(BUILD_TESTING)
  enable_testing()
  include(CTest)
  if(NOT EMSCRIPTEN)
    add_subdirectory(test)
  endif()
endif()

if(MSVC)
  set_property(DIRECTORY PROPERTY VS_STARTUP_PROJECT ${PROJECT_NAME})
endif()
