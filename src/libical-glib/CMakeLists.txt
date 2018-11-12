add_definitions(-Dlibical_ical_EXPORTS)

# build the src-generator
add_executable(src-generator
  tools/generator.c
  tools/generator.h
  tools/xml-parser.c
  tools/xml-parser.h
)

target_compile_options(src-generator PUBLIC -DG_LOG_DOMAIN="src-generator")
target_link_libraries(src-generator GLIB2::GLIB2 LIBXML2::LIBXML2)

list(APPEND API_FILES
  api/i-cal-array.xml
  api/i-cal-attach.xml
  api/i-cal-comp-iter.xml
  api/i-cal-component.xml
  api/i-cal-datetimeperiod-type.xml
  api/i-cal-derived-parameter.xml
  api/i-cal-derived-property.xml
  api/i-cal-derived-value.xml
  api/i-cal-duration-type.xml
  api/i-cal-enums.xml
  api/i-cal-error.xml
  api/i-cal-geo-type.xml
  api/i-cal-langbind.xml
  api/i-cal-memory.xml
  api/i-cal-mime.xml
  api/i-cal-parameter.xml
  api/i-cal-parser.xml
  api/i-cal-period-type.xml
  api/i-cal-property.xml
  api/i-cal-recur-iterator.xml
  api/i-cal-recurrence-type.xml
  api/i-cal-recur.xml
  api/i-cal-reqstat-type.xml
  api/i-cal-restriction.xml
  api/i-cal-time-span.xml
  api/i-cal-timetype.xml
  api/i-cal-time.xml
  api/i-cal-timezone-phase.xml
  api/i-cal-timezonetype.xml
  api/i-cal-timezone.xml
  api/i-cal-trigger-type.xml
  api/i-cal-unknowntokenhandling.xml
  api/i-cal-value.xml
)

list(APPEND LIBICAL_GLIB_HEADERS
  ${CMAKE_CURRENT_BINARY_DIR}/libical-glib.h
  ${CMAKE_CURRENT_BINARY_DIR}/i-cal-object.h
  ${CMAKE_CURRENT_BINARY_DIR}/i-cal-forward-declarations.h
)

# add the command to generate the source code from the api files
foreach(file IN LISTS API_FILES)
  string(REPLACE "api/" "${CMAKE_CURRENT_SOURCE_DIR}/api/" xml_file_fullpath ${file})
  string(REPLACE "api/" "${CMAKE_CURRENT_BINARY_DIR}/" bin_file ${file})
  string(REPLACE ".xml" ".h" h_file ${bin_file})
  string(REPLACE ".xml" ".c" c_file ${bin_file})

  list(APPEND LIBICAL_GLIB_SRCS ${h_file} ${c_file})
  list(APPEND LIBICAL_GLIB_HEADERS ${h_file})
  list(APPEND xml_files ${xml_file_fullpath})
endforeach()

add_custom_command (
  OUTPUT ${LIBICAL_GLIB_SRCS} ${CMAKE_CURRENT_BINARY_DIR}/libical-glib-private.h ${CMAKE_CURRENT_BINARY_DIR}/i-cal-forward-declarations.h
  COMMAND ${EXECUTABLE_OUTPUT_PATH}/src-generator "${CMAKE_CURRENT_SOURCE_DIR}/tools" "${CMAKE_CURRENT_SOURCE_DIR}/api"
  DEPENDS ${EXECUTABLE_OUTPUT_PATH}/src-generator ${xml_files}
)

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/i-cal-object.c.in
  ${CMAKE_CURRENT_BINARY_DIR}/i-cal-object.c
  COPYONLY
)

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/i-cal-object.h.in
  ${CMAKE_CURRENT_BINARY_DIR}/i-cal-object.h
  COPYONLY
)

list(APPEND LIBICAL_GLIB_SRCS
  ${CMAKE_CURRENT_BINARY_DIR}/libical-glib-private.h
  ${CMAKE_CURRENT_BINARY_DIR}/i-cal-object.c
  ${CMAKE_CURRENT_BINARY_DIR}/i-cal-object.h
)

########### next target ###############

add_library(ical-glib ${LIBRARY_TYPE} ${LIBICAL_GLIB_SRCS})
add_dependencies(ical-glib ical-header)

target_compile_definitions(ical-glib PRIVATE -DG_LOG_DOMAIN="libical-glib" -DLIBICAL_GLIB_COMPILATION)
target_include_directories(ical-glib PUBLIC "$<BUILD_INTERFACE:${libical_BINARY_DIR};${libical_BINARY_DIR}/src>")

target_link_libraries(ical-glib PRIVATE ical GLIB2::GLIB2)

if(MSVC)
  set_target_properties(ical-glib PROPERTIES PREFIX "lib")
endif()

set_target_properties(ical-glib PROPERTIES
  VERSION ${PROJECT_VERSION}
  SOVERSION ${PROJECT_VERSION_MAJOR}
)

set_target_properties(ical-glib PROPERTIES CLEAN_DIRECT_OUTPUT 1)

install(
  TARGETS ical-glib
  EXPORT icalTargets
  DESTINATION ${INSTALL_TARGETS_DEFAULT_ARGS}
)

########### next target ###############

if(NOT SHARED_ONLY)
  add_library(ical-glib-static STATIC ${LIBICAL_GLIB_SRCS})
  add_dependencies(ical-glib-static ical-header)

  target_include_directories(ical-glib-static PUBLIC "$<BUILD_INTERFACE:${libical_BINARY_DIR};${libical_BINARY_DIR}/src;$<TARGET_PROPERTY:ical-static,INTERFACE_INCLUDE_DIRECTORIES>>")

  target_compile_options(ical-glib-static PUBLIC -DG_LOG_DOMAIN="libical-glib" -DLIBICAL_GLIB_COMPILATION)
  target_link_libraries(ical-glib-static GLIB2::GLIB2)

  if(MSVC)
    set_target_properties(icalss-static PROPERTIES PREFIX "lib")
  else()
    set_target_properties(icalss-static PROPERTIES OUTPUT_NAME "icalss")
  endif()
  set_target_properties(icalss-static PROPERTIES CLEAN_DIRECT_OUTPUT 1)

  install(
    TARGETS ical-glib-static
    EXPORT icalTargets
    DESTINATION ${INSTALL_TARGETS_DEFAULT_ARGS}
  )
endif()

# GObject Introspection
if(HAVE_INTROSPECTION)
  # extract only file names without path for introspection
  foreach(file IN LISTS LIBICAL_GLIB_SRCS)
    string(REPLACE "${CMAKE_CURRENT_BINARY_DIR}/" "" plain_file ${file})
    list(APPEND LIBICAL_GLIB_GIR_SOURCES ${plain_file})
  endforeach()

  include(GObjectIntrospectionMacros)
  set(LIBICAL_GLIB_GIR_VERSION_STRING "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}")

  set(GObjectIntrospection_GIRS)
  set(GObjectIntrospection_SCANNER_FLAGS)
  set(GObjectIntrospection_SCANNER_ARGS)
  set(GObjectIntrospection_COMPILER_ARGS)
  set(LIB_VERSION)

  set(LIB_VERSION ${LIBICAL_GLIB_GIR_VERSION_STRING})
  string(REPLACE "." "_" LIB_VERSION "${LIB_VERSION}")
  string(REPLACE "-" "_" LIB_VERSION "${LIB_VERSION}")

  set(GObjectIntrospection_SCANNER_ARGS
    --add-include-path=${CMAKE_CURRENT_BINARY_DIR}
    --add-include-path=${CMAKE_CURRENT_SOURCE_DIR}
    --add-include-path=${CMAKE_BINARY_DIR}/src
    --add-include-path=${CMAKE_BINARY_DIR}/src/libical
    --add-include-path=${CMAKE_SOURCE_DIR}/src
    --add-include-path=${CMAKE_SOURCE_DIR}/src/libical
    --library-path=${LIBRARY_OUTPUT_PATH}
    --identifier-prefix=ICal
    --pkg-export libical-glib-${PROJECT_VERSION}
    --c-include="libical-glib/libical-glib.h"
    --cflags-begin
    -I${CMAKE_BINARY_DIR}/src
    -I${CMAKE_BINARY_DIR}/src/libical
    -I${CMAKE_BINARY_DIR}/src/libical-glib
    -I${LIBRARY_OUTPUT_PATH}
    -I${CMAKE_SOURCE_DIR}/src
    -I${CMAKE_SOURCE_DIR}/src/libical
    --cflags-end
    --verbose
  )

  set(ICalGLib_${LIB_VERSION}_gir "ICalGLib")
  set(ICalGLib_${LIB_VERSION}_gir_SCANNERFLAGS "--warn-all")
  set(ICalGLib_${LIB_VERSION}_gir_VERSION ${LIBICAL_GLIB_GIR_VERSION_STRING})
  set(ICalGLib_${LIB_VERSION}_gir_LIBRARY "ICalGLib")
  set(ICalGLib_${LIB_VERSION}_gir_INCLUDES GObject-2.0 GLib-2.0)
  set(ICalGLib_${LIB_VERSION}_gir_CFLAGS ${_includes} ${GLIB2_CFLAGS} -DLIBICAL_GLIB_COMPILATION -I${CMAKE_CURRENT_BINARY_DIR} -I${CMAKE_CURRENT_SOURCE_DIR} -I${CMAKE_BINARY_DIR}/src/libical -I${CMAKE_SOURCE_DIR}/src/libical -I${CMAKE_BINARY_DIR}/src/libical-glib)
  set(ICalGLib_${LIB_VERSION}_gir_LIBS ical-glib)
  set(ICalGLib_${LIB_VERSION}_gir_FILES ${LIBICAL_GLIB_GIR_SOURCES})

  list(APPEND GObjectIntrospection_GIRS ICalGLib-${LIBICAL_GLIB_GIR_VERSION_STRING}.gir)

  gir_add_introspections(GObjectIntrospection_GIRS)
endif()

if(ICAL_GLIB_VAPI)
  add_custom_target(vala ALL)
  set(gir_fullname ${CMAKE_BINARY_DIR}/src/libical-glib/ICalGLib-${LIBICAL_GLIB_GIR_VERSION_STRING}.gir)
  set(vapi_file ${CMAKE_CURRENT_BINARY_DIR}/libical-glib.vapi)

  add_custom_command(OUTPUT ${vapi_file}
    COMMAND ${VAPIGEN}
      --vapidir=${CMAKE_CURRENT_SOURCE_DIR}
      --vapidir=${CMAKE_CURRENT_BINARY_DIR}
      --girdir=${CMAKE_BINARY_DIR}/src/libical-glib
      --pkg gio-2.0
      --library libical-glib
      --metadatadir=${CMAKE_CURRENT_SOURCE_DIR}
      ${gir_fullname}
    DEPENDS
      ${gir_fullname}
  )

  add_custom_target(valafile DEPENDS ${vapi_file})

  add_dependencies(vala valafile)

  install(FILES ${vapi_file} DESTINATION ${SHARE_INSTALL_DIR}/vala/vapi)
endif()

########### install files ###############

install(FILES ${LIBICAL_GLIB_HEADERS}
  DESTINATION ${INCLUDE_INSTALL_DIR}/libical-glib
  COMPONENT Devel
)

########### create and install pkg-config file #########

set(prefix "${CMAKE_INSTALL_PREFIX}")
set(exec_prefix "\${prefix}")
set(libdir "\${exec_prefix}/lib")
set(includedir "\${prefix}/include")

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/libical-glib.pc.in
  ${CMAKE_CURRENT_BINARY_DIR}/libical-glib.pc
  @ONLY
)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/libical-glib.pc DESTINATION ${LIB_INSTALL_DIR}/pkgconfig)
