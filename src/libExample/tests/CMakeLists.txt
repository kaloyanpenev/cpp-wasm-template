if(BUILD_TESTING)

  set(TESTS_NAME ${LIBRARY_NAME}Tests)

  add_executable(${TESTS_NAME}
    libExampleTests.cpp
  )

  target_precompile_headers(${TESTS_NAME} PRIVATE <gtest/gtest.h>)

  target_link_libraries(${TESTS_NAME} PRIVATE
    ${LIBRARY_NAME}
    gtest_main
  )


  add_test(${TESTS_NAME} ${TESTS_NAME})
endif()