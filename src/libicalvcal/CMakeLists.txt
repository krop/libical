add_definitions(-Dlibical_vcal_EXPORTS)

#these are generated sources, but we keep them in the repo
set(icalvcal_LIB_DEVSRCS vcc.c)

########### next target ###############

set(icalvcal_LIB_SRCS
  libical_vcal_export.h
  icalvcal.h
  icalvcal.c
  vcc.h
  vobject.h
  vobject.c
  vcaltmp.h
  vcaltmp.c
  ${icalvcal_LIB_DEVSRCS}
)

add_library(icalvcal ${LIBRARY_TYPE} ${icalvcal_LIB_SRCS})
add_dependencies(icalvcal ical-header)

target_include_directories(icalvcal PUBLIC "$<BUILD_INTERFACE:${libical_SOURCE_DIR}/src>")
target_link_libraries(icalvcal ical)

if(MSVC)
  set_target_properties(icalvcal PROPERTIES PREFIX "lib")
endif()

set_target_properties(icalvcal PROPERTIES
  VERSION ${PROJECT_VERSION}
  SOVERSION ${PROJECT_VERSION_MAJOR}
)

set_target_properties(icalvcal PROPERTIES CLEAN_DIRECT_OUTPUT 1)

install(
  TARGETS icalvcal
  EXPORT icalTargets
  DESTINATION ${INSTALL_TARGETS_DEFAULT_ARGS}
)

########### next target ###############
if(NOT SHARED_ONLY)
  add_library(icalvcal-static STATIC ${icalvcal_LIB_SRCS})
  add_dependencies(icalvcal-static ical-header)

  target_include_directories(icalvcal-static PUBLIC "$<BUILD_INTERFACE:${libical_BINARY_DIR};$<TARGET_PROPERTY:ical-static,INTERFACE_INCLUDE_DIRECTORIES>>")

  if(MSVC)
    set_target_properties(icalvcal-static PROPERTIES PREFIX "lib")
  else()
    set_target_properties(icalvcal-static PROPERTIES OUTPUT_NAME "icalvcal")
  endif()
  set_target_properties(icalvcal-static PROPERTIES CLEAN_DIRECT_OUTPUT 1)

  install(
    TARGETS icalvcal-static
    EXPORT icalTargets
    DESTINATION ${INSTALL_TARGETS_DEFAULT_ARGS}
  )
endif()

########### install files ###############

install(FILES
  icalvcal.h
  vcaltmp.h
  vcc.h
  vobject.h
  libical_vcal_export.h
  DESTINATION
  ${INCLUDE_INSTALL_DIR}/libical
  COMPONENT Devel
)
