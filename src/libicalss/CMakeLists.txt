add_definitions(-Dlibical_icalss_EXPORTS)

set(TOPS "${CMAKE_SOURCE_DIR}")
set(TOPB "${CMAKE_BINARY_DIR}")

add_custom_target(
  icalss-header ALL
  DEPENDS ${CMAKE_BINARY_DIR}/src/libicalss/icalss.h
)

########### next target ###############

#these are generated sources, but we keep them in the repo
set(icalss_LIB_DEVSRCS icalsslexer.c icalssyacc.c)

set(icalss_LIB_SRCS
  libical_icalss_export.h
  icalcalendar.c
  icalcalendar.h
  icalclassify.c
  icalclassify.h
  icalcluster.c
  icalcluster.h
  icalclusterimpl.h
  icalgauge.c
  icalgauge.h
  icalgaugeimpl.h
  icaldirset.c
  icaldirset.h
  icaldirsetimpl.h
  icalfileset.c
  icalfileset.h
  icalfilesetimpl.h
  icalset.c
  icalset.h
  icalssyacc.h
  icalspanlist.c
  icalspanlist.h
  icalmessage.c
  icalmessage.h
  ${icalss_LIB_DEVSRCS}
)

if(BDB_FOUND)
  list(APPEND icalss_LIB_SRCS
    icalbdbset.c
    icalbdbset.h
    icalbdbsetimpl.h
  )
endif()

add_custom_command(
  OUTPUT
    ${CMAKE_BINARY_DIR}/src/libicalss/icalss.h
  COMMAND
  ${CMAKE_COMMAND}
    -DTOPS:FILEPATH=${TOPS}
    -DTOPB:FILEPATH=${TOPB}
    -DICAL_FILE_H_FILE:FILEPATH=${CMAKE_BINARY_DIR}/src/libicalss/icalss.h
    -DBDB_FOUND=${BDB_FOUND}
    -P ${CMAKE_CURRENT_SOURCE_DIR}/icalss_file.cmake
  DEPENDS ${icalss_LIB_SRCS} ${CMAKE_CURRENT_SOURCE_DIR}/icalss_file.cmake
)

########### next target ###############

add_library(icalss ${LIBRARY_TYPE} ${icalss_LIB_SRCS})
add_dependencies(icalss ical-header icalss-header)

target_include_directories(icalss PUBLIC "$<BUILD_INTERFACE:${libical_SOURCE_DIR}/src/libicalss;${libical_BINARY_DIR}/src>")
target_link_libraries(icalss ical)
if(BDB_FOUND)
  target_link_libraries(icalss BDB::BDB)
endif()

if(MSVC)
  set_target_properties(icalss PROPERTIES PREFIX "lib")
endif()

set_target_properties(icalss PROPERTIES
  VERSION ${PROJECT_VERSION}
  SOVERSION ${PROJECT_VERSION_MAJOR}
)

set_target_properties(icalss PROPERTIES CLEAN_DIRECT_OUTPUT 1)

install(
  TARGETS icalss
  EXPORT icalTargets
  DESTINATION ${INSTALL_TARGETS_DEFAULT_ARGS}
)

########### next target ###############

if(NOT SHARED_ONLY)
  add_library(icalss-static STATIC ${icalss_LIB_SRCS})
  add_dependencies(icalss-static ical-header icalss-header)

  target_include_directories(icalss-static PUBLIC "$<BUILD_INTERFACE:${libical_BINARY_DIR};$<TARGET_PROPERTY:ical-static,INTERFACE_INCLUDE_DIRECTORIES>>")

  if(MSVC)
    set_target_properties(icalss-static PROPERTIES PREFIX "lib")
  else()
    set_target_properties(icalss-static PROPERTIES OUTPUT_NAME "icalss")
  endif()
  set_target_properties(icalss-static PROPERTIES CLEAN_DIRECT_OUTPUT 1)

  install(
    TARGETS icalss-static
    EXPORT icalTargets
    DESTINATION ${INSTALL_TARGETS_DEFAULT_ARGS}
  )
endif()

########### next target ###############

if(WITH_CXX_BINDINGS)
  set(icalsscxx_LIB_SRCS
    icalspanlist_cxx.cpp
    icalspanlist_cxx.h
  )
  if(BDB_FOUND)
    list(APPEND icalsscxx_LIB_SRCS
      icalbdbset_cxx.h
    )
  endif()
  add_library(icalss_cxx ${LIBRARY_TYPE} ${icalsscxx_LIB_SRCS})
  add_dependencies(icalss_cxx ical-header icalss-header)

  target_link_libraries(icalss_cxx icalss ical_cxx ${CMAKE_THREAD_LIBS_INIT})

  if(MSVC)
    set_target_properties(icalss_cxx PROPERTIES PREFIX "lib")
  endif()

  set_target_properties(icalss_cxx PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
  )
  set_target_properties(icalss_cxx PROPERTIES CLEAN_DIRECT_OUTPUT 1)

  install(
    TARGETS icalss_cxx
    EXPORT icalTargets
    DESTINATION ${INSTALL_TARGETS_DEFAULT_ARGS}
  )

  ########### next target ###############
  if(NOT SHARED_ONLY)
    add_library(icalss_cxx-static STATIC ${icalsscxx_LIB_SRCS})
    add_dependencies(icalss_cxx-static ical-header icalss-header)
    target_include_directories(icalss_cxx-static PUBLIC "$<BUILD_INTERFACE:$<TARGET_PROPERTY:icalss-static,INTERFACE_INCLUDE_DIRECTORIES>>")

    if(MSVC)
      set_target_properties(icalss_cxx-static PROPERTIES PREFIX "lib")
    else()
      set_target_properties(icalss_cxx-static PROPERTIES OUTPUT_NAME "icalss_cxx")
    endif()

    set_target_properties(icalss_cxx-static PROPERTIES CLEAN_DIRECT_OUTPUT 1)

    install(
      TARGETS icalss_cxx-static
      EXPORT icalTargets
      DESTINATION ${INSTALL_TARGETS_DEFAULT_ARGS}
    )
  endif()
endif()

########### install files ###############

install(FILES
  ${CMAKE_BINARY_DIR}/src/libicalss/icalss.h
  icalcalendar.h
  icalclassify.h
  icalcluster.h
  icaldirset.h
  icaldirsetimpl.h
  icalfileset.h
  icalfilesetimpl.h
  icalgauge.h
  icalgaugeimpl.h
  icalmessage.h
  icalset.h
  icalspanlist.h
  icalssyacc.h
  libical_icalss_export.h
  DESTINATION
  ${INCLUDE_INSTALL_DIR}/libical
  COMPONENT Devel
)

if(WITH_CXX_BINDINGS)
  install(FILES
    icalspanlist_cxx.h
    DESTINATION
    ${INCLUDE_INSTALL_DIR}/libical
    COMPONENT Devel
  )
  if(BDB_FOUND)
    install(FILES icalbdbset_cxx.h
      DESTINATION
      ${INCLUDE_INSTALL_DIR}/libical
      COMPONENT Devel
    )
  endif()
endif()
