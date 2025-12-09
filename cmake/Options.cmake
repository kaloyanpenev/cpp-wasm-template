# =============================================================================
# Build Type Configuration
# =============================================================================
# Configure build type specific settings
# Default to RelWithDebInfo settings (optimized with debug symbols, static analyzers enabled, no sanitizers)
set(WARNINGS_AS_ERRORS_DEFAULT ON)
set(ENABLE_IPO_DEFAULT OFF)
set(ENABLE_ASAN_DEFAULT OFF)
set(ENABLE_LSAN_DEFAULT OFF)
set(ENABLE_TSAN_DEFAULT OFF)
set(ENABLE_UBSAN_DEFAULT OFF)
set(ENABLE_MSAN_DEFAULT OFF)
set(ENABLE_CLANG_TIDY_DEFAULT ON)
set(ENABLE_CPPCHECK_DEFAULT ON)
set(ENABLE_IWYU_DEFAULT OFF)
set(BUILD_TESTING_DEFAULT OFF)

if(EMSCRIPTEN)
  # Emscripten: disable all analysis tools
  set(ENABLE_CLANG_TIDY_DEFAULT OFF)
  set(ENABLE_CPPCHECK_DEFAULT OFF)
  
elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(ENABLE_ASAN_DEFAULT OFF)
  set(ENABLE_LSAN_DEFAULT OFF)
  set(ENABLE_TSAN_DEFAULT OFF)
  set(ENABLE_UBSAN_DEFAULT ON)
  set(ENABLE_MSAN_DEFAULT OFF)
  set(ENABLE_IWYU_DEFAULT ON)
  set(BUILD_TESTING_DEFAULT ON)
  message(STATUS "Build type: Debug - UBSan enabled, no optimization, IWYU enabled")
  
elseif(CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
  message(STATUS "Build type: RelWithDebInfo - Optimized with debug symbols, static analyzers enabled, no sanitizers")
  
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
  # Release: Full optimization, no sanitizers, static analyzers enabled
  set(ENABLE_IPO_DEFAULT ON)
  message(STATUS "Build type: Release - Full optimization, static analyzers enabled, no sanitizers")
  
else()
  # Default to RelWithDebInfo settings if build type is not recognized
  message(STATUS "Build type: ${CMAKE_BUILD_TYPE} - Using RelWithDebInfo defaults")
endif()

# =============================================================================
# Options
# =============================================================================
option(WARNINGS_AS_ERRORS "Treat warnings as errors" ${WARNINGS_AS_ERRORS_DEFAULT})
option(ENABLE_IPO "Enable interprocedural optimization" ${ENABLE_IPO_DEFAULT})
option(ENABLE_ASAN "Enable AddressSanitizer" ${ENABLE_ASAN_DEFAULT})
option(ENABLE_LSAN "Enable LeakSanitizer" ${ENABLE_LSAN_DEFAULT})
option(ENABLE_TSAN "Enable ThreadSanitizer" ${ENABLE_TSAN_DEFAULT})
option(ENABLE_UBSAN "Enable UndefinedBehaviorSanitizer" ${ENABLE_UBSAN_DEFAULT})
option(ENABLE_MSAN "Enable MemorySanitizer (Clang only)" ${ENABLE_MSAN_DEFAULT})
option(ENABLE_CLANG_TIDY "Enable clang-tidy" ${ENABLE_CLANG_TIDY_DEFAULT})
option(ENABLE_CPPCHECK "Enable cppcheck" ${ENABLE_CPPCHECK_DEFAULT})
option(ENABLE_IWYU "Enable include-what-you-use" ${ENABLE_IWYU_DEFAULT})
option(ENABLE_COMPILER_CACHE "Enable compiler cache (ccache/sccache)" ON)
option(WASM_SINGLE_FILE "Embed WASM in JS (Emscripten only)" OFF)
option(BUILD_TESTING "Build the testing tree" ${BUILD_TESTING_DEFAULT})

