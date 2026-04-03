set(BASE_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
set(INCLUDE_DIR ${BASE_INCLUDE_DIR}/libExample)
set(SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)

file(GLOB_RECURSE SOURCE_FILES
        "${SOURCE_DIR}/*.cpp"
        "${SOURCE_DIR}/*.h"
)
file(GLOB_RECURSE INCLUDE_FILES
        "${INCLUDE_DIR}/*.h"
        "${INCLUDE_DIR}/*.hpp"
)

add_library(libExample STATIC
        ${SOURCE_FILES}
        ${INCLUDE_FILES}
)

target_include_directories(libExample
        PUBLIC
        ${BASE_INCLUDE_DIR}
        PRIVATE
        ${INCLUDE_DIR}
)