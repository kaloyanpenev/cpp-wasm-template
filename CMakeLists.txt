cmake_minimum_required(VERSION 3.21)

# Project name from central config
file(READ "${CMAKE_SOURCE_DIR}/project.json" PROJECT_JSON)
string(JSON PROJECT_NAME_VAR GET ${PROJECT_JSON} "name")

project(${PROJECT_NAME_VAR} VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# =============================================================================
# Options
# =============================================================================
if(EMSCRIPTEN)
  set(WARNINGS_AS_ERRORS_DEFAULT OFF)
  set(ENABLE_IPO_DEFAULT OFF)
  set(ENABLE_ASAN_DEFAULT OFF)
  set(ENABLE_UBSAN_DEFAULT OFF)
  set(ENABLE_CLANG_TIDY_DEFAULT OFF)
  set(ENABLE_CPPCHECK_DEFAULT OFF)
  set(ENABLE_IWYU_DEFAULT OFF)
else()
  set(WARNINGS_AS_ERRORS_DEFAULT ON)
  set(ENABLE_IPO_DEFAULT ON)
  set(ENABLE_ASAN_DEFAULT ON)
  set(ENABLE_UBSAN_DEFAULT ON)
  set(ENABLE_CLANG_TIDY_DEFAULT ON)
  set(ENABLE_CPPCHECK_DEFAULT ON)
  set(ENABLE_IWYU_DEFAULT OFF)
endif()

option(WARNINGS_AS_ERRORS "Treat warnings as errors" ${WARNINGS_AS_ERRORS_DEFAULT})
option(ENABLE_IPO "Enable interprocedural optimization" ${ENABLE_IPO_DEFAULT})
option(ENABLE_ASAN "Enable AddressSanitizer" ${ENABLE_ASAN_DEFAULT})
option(ENABLE_LSAN "Enable LeakSanitizer" OFF)
option(ENABLE_TSAN "Enable ThreadSanitizer" OFF)
option(ENABLE_UBSAN "Enable UndefinedBehaviorSanitizer" ${ENABLE_UBSAN_DEFAULT})
option(ENABLE_MSAN "Enable MemorySanitizer (Clang only)" OFF)
option(ENABLE_CLANG_TIDY "Enable clang-tidy" ${ENABLE_CLANG_TIDY_DEFAULT})
option(ENABLE_CPPCHECK "Enable cppcheck" ${ENABLE_CPPCHECK_DEFAULT})
option(ENABLE_IWYU "Enable include-what-you-use" ${ENABLE_IWYU_DEFAULT})
option(WASM_SINGLE_FILE "Embed WASM in JS (Emscripten only)" OFF)

# =============================================================================
# CMake modules
# =============================================================================
include(cmake/CompilerWarnings.cmake)
include(cmake/Sanitizers.cmake)
include(cmake/StaticAnalyzers.cmake)
include(cmake/InterproceduralOptimization.cmake)

# =============================================================================
# Main target
# =============================================================================
add_executable(${PROJECT_NAME} src/main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE project_warnings project_sanitizers)

# =============================================================================
# Emscripten configuration
# =============================================================================
if(EMSCRIPTEN)
  # Convert project name to PascalCase for JS export
  string(REPLACE "_" ";" NAME_PARTS "${PROJECT_NAME}")
  set(JS_EXPORT_NAME "")
  foreach(PART ${NAME_PARTS})
    string(SUBSTRING ${PART} 0 1 FIRST_CHAR)
    string(TOUPPER ${FIRST_CHAR} FIRST_CHAR)
    string(SUBSTRING ${PART} 1 -1 REST)
    string(APPEND JS_EXPORT_NAME "${FIRST_CHAR}${REST}")
  endforeach()

  set_target_properties(${PROJECT_NAME} PROPERTIES
    SUFFIX ".js"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/web")
  
  target_compile_options(${PROJECT_NAME} PRIVATE -sNO_DISABLE_EXCEPTION_CATCHING)
  target_link_options(${PROJECT_NAME} PRIVATE
    -sWASM=1 -sEXPORT_ES6=1 -sMODULARIZE=1
    -sEXPORT_NAME=${JS_EXPORT_NAME}
    -sENVIRONMENT=web,worker,node
    -sALLOW_MEMORY_GROWTH=1
    -sDISABLE_EXCEPTION_CATCHING=1
    $<$<BOOL:${WASM_SINGLE_FILE}>:-sSINGLE_FILE=1>)
  
  file(GLOB WEB_ASSETS "${CMAKE_SOURCE_DIR}/web/*")
  file(COPY ${WEB_ASSETS} DESTINATION "${CMAKE_BINARY_DIR}/web")
endif()

# =============================================================================
# Tests
# =============================================================================
enable_testing()
include(CTest)
if(BUILD_TESTING AND NOT EMSCRIPTEN)
  add_subdirectory(test)
endif()

# =============================================================================
# MSVC tweaks
# =============================================================================
if(MSVC)
  set_property(DIRECTORY PROPERTY VS_STARTUP_PROJECT ${PROJECT_NAME})
endif()
