# Compiler warnings configuration
# Creates a project_warnings interface library

add_library(project_warnings INTERFACE)

if(MSVC)
  target_compile_options(project_warnings INTERFACE
    /W4
    /w14242 /w14254 /w14263 /w14265 /w14287 /we4289 /w14296 /w14311
    /w14545 /w14546 /w14547 /w14549 /w14555 /w14619 /w14640 /w14826
    /w14905 /w14906 /w14928
    /permissive-
  )
  if(WARNINGS_AS_ERRORS)
    target_compile_options(project_warnings INTERFACE /WX)
  endif()

elseif(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
  target_compile_options(project_warnings INTERFACE
    -Wall -Wextra -Wshadow -Wnon-virtual-dtor -Wold-style-cast -Wcast-align
    -Wunused -Woverloaded-virtual -Wpedantic -Wconversion -Wsign-conversion
    -Wnull-dereference -Wdouble-promotion -Wformat=2 -Wimplicit-fallthrough
  )
  if(WARNINGS_AS_ERRORS)
    target_compile_options(project_warnings INTERFACE -Werror)
  endif()

elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_compile_options(project_warnings INTERFACE
    -Wall -Wextra -Wshadow -Wnon-virtual-dtor -Wold-style-cast -Wcast-align
    -Wunused -Woverloaded-virtual -Wpedantic -Wconversion -Wsign-conversion
    -Wnull-dereference -Wdouble-promotion -Wformat=2 -Wimplicit-fallthrough
    -Wmisleading-indentation -Wduplicated-cond -Wduplicated-branches
    -Wlogical-op -Wuseless-cast -Wsuggest-override
  )
  if(WARNINGS_AS_ERRORS)
    target_compile_options(project_warnings INTERFACE -Werror)
  endif()
endif()
