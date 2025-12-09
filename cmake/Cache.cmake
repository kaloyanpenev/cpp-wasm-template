#[[ Enable compiler cache (ccache/sccache) if available ]]
function(project_enable_cache)
  # Check if compiler cache is enabled via option
  if(NOT ENABLE_COMPILER_CACHE)
    message(STATUS "Compiler cache is disabled via ENABLE_COMPILER_CACHE option")
    return()
  endif()

  set(CACHE_OPTION
      "ccache"
      CACHE STRING "Compiler cache to be used")
  set(CACHE_OPTION_VALUES "ccache" "sccache")
  set_property(CACHE CACHE_OPTION PROPERTY STRINGS ${CACHE_OPTION_VALUES})
  list(FIND CACHE_OPTION_VALUES ${CACHE_OPTION} CACHE_OPTION_INDEX)

  if(${CACHE_OPTION_INDEX} EQUAL -1)
    message(
      STATUS
        "Using custom compiler cache system: '${CACHE_OPTION}', explicitly supported entries are ${CACHE_OPTION_VALUES}"
    )
  endif()

  # Prefer the requested cache, but fall back to any supported option that exists.
  find_program(CACHE_BINARY NAMES ${CACHE_OPTION} ${CACHE_OPTION_VALUES})
  if(CACHE_BINARY)
    message(STATUS "${CACHE_BINARY} found and enabled")
    set(CMAKE_CXX_COMPILER_LAUNCHER
        ${CACHE_BINARY}
        CACHE FILEPATH "CXX compiler cache used")
    set(CMAKE_C_COMPILER_LAUNCHER
        ${CACHE_BINARY}
        CACHE FILEPATH "C compiler cache used")
  else()
    message(WARNING "${CACHE_OPTION} is enabled but was not found. Not using it")
  endif()
endfunction()

