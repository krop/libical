#.rst:
# FindBDB
# -------
#
# Finds the Berkeley DB Library.
#
# This will define the following variables:
#
#  ``BDB_FOUND``
#     TRUE if Berkeley DB found.
#
#  ``BDB_INCLUDE_DIRS``
#     This should be passed to target_include_directories() if
#     the target is not used for linking.
#
#  ``BDB_LIBRARIES``
#     The BDB library. This can be passed to target_link_libraries()
#     if the exported target is not used.
#
# The following variables are defined for backward compatibility
#

find_path(BDB_INCLUDE_DIRS
  NAMES db.h
  HINTS /usr/local/opt/db/include
  DOC "Include directory for the Berkeley DB library"
)

find_library(BDB_LIBRARIES
  NAMES db
  HINTS /usr/local/opt/db4/lib
  DOC "Libraries to link against for the Berkeley DB"
)

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(BDB
  FOUND_VAR BDB_FOUND
  REQUIRED_VARS BDB_LIBRARIES BDB_INCLUDE_DIRS
)

if(BDB_FOUND)
  add_library(BDB::BDB UNKNOWN IMPORTED)
  set_target_properties(BDB::BDB PROPERTIES
    IMPORTED_LOCATION "${BDB_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${BDB_INCLUDE_DIRS}"
  )
endif()

mark_as_advanced(BDB_LIBRARIES BDB_INCLUDE_DIRS)

include(FeatureSummary)
set_package_properties(BDB PROPERTIES
  DESCRIPTION "Berkeley DB storage"
  URL "https://www.oracle.com/database/berkeley-db"
)
