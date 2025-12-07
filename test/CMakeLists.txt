include(FetchContent)

FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
  DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
set(gtest_force_shared_crt OFF CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# Do not run clang-tidy on third-party gtest targets
if(ENABLE_CLANG_TIDY)
  foreach(_gtest_target gtest gtest_main gmock gmock_main)
    if(TARGET ${_gtest_target})
      set_target_properties(${_gtest_target} PROPERTIES CXX_CLANG_TIDY "")
    endif()
  endforeach()
endif()

add_executable(example_test example_test.cpp)
target_link_libraries(example_test PRIVATE GTest::gtest_main)

include(GoogleTest)
gtest_discover_tests(example_test)
