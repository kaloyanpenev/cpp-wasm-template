# Executable target
add_executable(${PROJECT_NAME} main.cpp)

add_subdirectory(libExample)
target_link_libraries(${PROJECT_NAME} PRIVATE libExample)
