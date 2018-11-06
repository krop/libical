#.rst:
# FindLibXML
# -------
#
# Finds the LibXML Library.
#
# This will define the following variables:
#
#  ``LIBXML2_FOUND``
#     libxml2 was found.
#
#  ``LIBXML2_INCLUDE_DIRS``
#     This should be passed to target_include_directories() if
#     the target is not used for linking.
#
#  ``LIBXML2_LIBRARIES``
#     The LibXML2 library. This can be passed to target_link_libraries()
#     if the exported target is not used.
#
#  ``LIBXML2_VERSION``
#     The libxml2 version.
#
#=============================================================================
# Copyright 2018 Christophe Giboudeaux <christophe@krop.fr>
#
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. The name of the author may not be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#=============================================================================

# Starting with 2.9.2, libxml2 provides a CMake config file.
if(LibXML2_FIND_VERSION VERSION_LESS "2.9.2")

  find_package(PkgConfig QUIET)
  pkg_check_modules(PC_LIBXML2 libxml-2.0 QUIET)

  find_path(LIBXML2_INCLUDE_DIRS NAMES libxml/xmlversion.h
    HINTS ${PC_LIBXML2_INCLUDE_DIRS}
    PATH_SUFFIXES libxml2
  )

  find_library(LIBXML2_LIBRARIES NAMES xml2
    HINTS ${PC_LIBXML2_LIBRARY_DIRS}
  )

  set(LIBXML2_VERSION "${PC_LIBXML2_VERSION}")

  if(NOT LIBXML2_VERSION)
    if(EXISTS "${LIBXML2_INCLUDE_DIRS}/libxml/xmlversion.h")
      file(READ "${LIBXML2_INCLUDE_DIRS}/libxml/xmlversion.h" XMLVERSION_H_CONTENT)
      string(REGEX MATCH "LIBXML_DOTTED_VERSION \"[0-9.]+\"" XML_VERSION_MATCH ${XMLVERSION_H_CONTENT})
      string(REGEX REPLACE "LIBXML_DOTTED_VERSION \"(.*)\"" "\\1" LIBXML2_VERSION ${XML_VERSION_MATCH})
    else()
      # Could not find the version
      message(FATAL_ERROR "Cannot determine the libxml version. Check your installation.")
    endif()
  endif()
else()
  find_package(libxml2 CONFIG)
  set(LIBXML2_VERSION "${LIBXML2_VERSION_STRING}")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LIBXML2
    FOUND_VAR LIBXML2_FOUND
    REQUIRED_VARS LIBXML2_LIBRARIES LIBXML2_INCLUDE_DIRS
    VERSION_VAR LIBXML2_VERSION
)

if(LIBXML2_FOUND AND NOT TARGET LIBXML2::LIBXML2)
  add_library(LIBXML2::LIBXML2 UNKNOWN IMPORTED)
  set_target_properties(LIBXML2::LIBXML2 PROPERTIES
    IMPORTED_LOCATION "${LIBXML2_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${LIBXML2_INCLUDE_DIRS}"
  )
endif()

mark_as_advanced(LIBXML2_INCLUDE_DIRS LIBXML2_LIBRARIES)

include(FeatureSummary)
set_package_properties(LibXML2 PROPERTIES
  DESCRIPTION "A Library to Manipulate XML Files"
  URL "http://xmlsoft.org"
)
