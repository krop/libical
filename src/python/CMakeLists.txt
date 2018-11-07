include_directories(
  ${CMAKE_SOURCE_DIR}/src
  ${CMAKE_SOURCE_DIR}/src/libical
  ${CMAKE_SOURCE_DIR}/src/libicalss
)

########### next target ###############

set(LibicalWrap_LIB_SRCS
  LibicalWrap.c
)

add_library(LibicalWrap ${LIBRARY_TYPE} ${LibicalWrap_LIB_SRCS})

target_link_libraries(LibicalWrap)

set_target_properties(LibicalWrap PROPERTIES
  VERSION ${PROJECT_VERSION}
  SOVERSION ${PROJECT_VERSION_MAJOR}
)
install(TARGETS LibicalWrap DESTINATION lib)

########### install files ###############

