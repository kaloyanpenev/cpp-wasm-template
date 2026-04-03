set(LIBRARY_NAME libExample)

set(BASE_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
set(INCLUDE_DIR ${BASE_INCLUDE_DIR}/${LIBRARY_NAME})
set(SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)

file(GLOB_RECURSE INCLUDE_FILES
        "${INCLUDE_DIR}/*.h"
        "${INCLUDE_DIR}/*.hpp"
)

file(GLOB_RECURSE SOURCE_FILES
        "${SOURCE_DIR}/*.cpp"
        "${SOURCE_DIR}/*.h"
)

add_library(${LIBRARY_NAME} STATIC
        ${SOURCE_FILES}
        ${INCLUDE_FILES}
)

target_include_directories(${LIBRARY_NAME}
        PUBLIC ${BASE_INCLUDE_DIR} # Propagate includes to other libraries only by appending "libExample/" before header files
        PRIVATE ${INCLUDE_DIR} # Internally, can use includes directly by name without appending "libExample/"
)

# Tests
add_subdirectory("tests")