########### doesnothing target ###############

set(doesnothing_SRCS
  access_components.c
  access_properties_and_parameters.c
  errors.c
  main.c
  parse_text.c
)

add_executable(doesnothing ${doesnothing_SRCS})
add_dependencies(doesnothing ical icalss icalvcal)

if(NOT STATIC_ONLY)
  target_link_libraries(doesnothing ical icalss icalvcal)
else()
  target_link_libraries(doesnothing
    ical-static
    icalss-static
    icalvcal-static
  )
  target_link_libraries(doesnothing ${CMAKE_THREAD_LIBS_INIT})
  if(ICU_FOUND)
    include_directories(${ICU_INCLUDE_DIRS})
    target_link_libraries(doesnothing ${ICU_LIBRARIES})
  endif()
  if(ICU_I18N_FOUND)
    target_link_libraries(doesnothing ICU::i18n)
  endif()
 if(BDB_FOUND)
    target_link_libraries(doesnothing BDB::BDB)
  endif()
endif()
