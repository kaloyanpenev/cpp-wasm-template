# Static analyzer configuration (clang-tidy, cppcheck)

if(ENABLE_CLANG_TIDY)
  find_program(CLANG_TIDY clang-tidy)
  if(CLANG_TIDY)
    set(CMAKE_CXX_CLANG_TIDY 
      ${CLANG_TIDY}
      -extra-arg=-Wno-unknown-warning-option
      -extra-arg=-std=c++${CMAKE_CXX_STANDARD}
      -p
    )
    if(WARNINGS_AS_ERRORS)
      list(APPEND CMAKE_CXX_CLANG_TIDY -warnings-as-errors=*)
    endif()
    message(STATUS "clang-tidy enabled")
  else()
    message(WARNING "clang-tidy requested but not found")
  endif()
endif()

if(ENABLE_IWYU)
  find_program(INCLUDE_WHAT_YOU_USE include-what-you-use)
  if(INCLUDE_WHAT_YOU_USE)
    set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE
      ${INCLUDE_WHAT_YOU_USE}
      -Wno-unknown-warning-option
    )
    message(STATUS "include-what-you-use enabled")
  else()
    message(WARNING "include-what-you-use requested but not found")
  endif()
endif()

if(ENABLE_CPPCHECK)
  find_program(CPPCHECK cppcheck)
  if(CPPCHECK)
    set(CMAKE_CXX_CPPCHECK 
      ${CPPCHECK}
      --enable=style,performance,warning,portability
      --inline-suppr
      --suppress=cppcheckError
      --suppress=unmatchedSuppression
      --suppress=syntaxError
      --std=c++${CMAKE_CXX_STANDARD}
    )
    if(WARNINGS_AS_ERRORS)
      list(APPEND CMAKE_CXX_CPPCHECK --error-exitcode=2)
    endif()
    message(STATUS "cppcheck enabled")
  else()
    message(WARNING "cppcheck requested but not found")
  endif()
endif()
