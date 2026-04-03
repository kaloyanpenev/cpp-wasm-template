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
    --bind  # Enable embind for C++/JS bindings
    $<$<BOOL:${WASM_SINGLE_FILE}>:-sSINGLE_FILE=1>)
  
  file(GLOB WEB_ASSETS "${CMAKE_SOURCE_DIR}/web/*")
  file(COPY ${WEB_ASSETS} DESTINATION "${CMAKE_BINARY_DIR}/web")
endif()

