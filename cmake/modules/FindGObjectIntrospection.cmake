#.rst:
# FindGObjectIntrospection
# ------------------------
#
# Find the GObject-introspection library and utilities
#
# Once done this will define:
#
#  ``GObjectIntrospection_FOUND``
#     System has gobject-introspection
#
#  ``GObjectIntrospection_SCANNER``
#     The gobject-introspection scanner, g-ir-scanner
#
#  ``GObjectIntrospection_COMPILER``
#     The gobject-introspection compiler, g-ir-compiler
#
#  ``GObjectIntrospection_GENERATE``
#     The gobject-introspection generate, g-ir-generate
#
#  ``GObjectIntrospection_GIRDIR``
#
#  ``GObjectIntrospection_TYPELIBDIR``
#
#  ``GObjectIntrospection_CFLAGS``
#     Additional gobject-introspection compiler flags
#
#  ``GObjectIntrospection_LIBRARIES``
#     The gobject-introspection libraries
#
#=============================================================================
# Copyright (C) 2010, Pino Toscano, <pino@kde.org>
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

find_package(PkgConfig QUIET)

macro(_GIR_GET_PKGCONFIG_VAR _outvar _varname)
  execute_process(
    COMMAND ${PKG_CONFIG_EXECUTABLE} --variable=${_varname} gobject-introspection-1.0
    OUTPUT_VARIABLE _result
    RESULT_VARIABLE _null
  )

  if (_null)
  else()
    string(REGEX REPLACE "[\r\n]" " " _result "${_result}")
    string(REGEX REPLACE " +$" ""  _result "${_result}")
    separate_arguments(_result)
    set(${_outvar} ${_result} CACHE INTERNAL "")
  endif()
endmacro()

pkg_check_modules(PC_GIR gobject-introspection-1.0 QUIET)

set(GObjectIntrospection_CFLAGS "${PC_GIR_CFLAGS}")
set(GObjectIntrospection_LIBRARIES "${PC_GIR_LIBRARIES}")

if(PC_GIR_FOUND)
  _gir_get_pkgconfig_var(GObjectIntrospection_SCANNER "g_ir_scanner")
  _gir_get_pkgconfig_var(GObjectIntrospection_COMPILER "g_ir_compiler")
  _gir_get_pkgconfig_var(GObjectIntrospection_GENERATE "g_ir_generate")
  _gir_get_pkgconfig_var(GObjectIntrospection_GIRDIR "girdir")
  _gir_get_pkgconfig_var(GObjectIntrospection_TYPELIBDIR "typelibdir")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GObjectIntrospection
  FOUND_VAR GObjectIntrospection_FOUND
  REQUIRED_VARS GObjectIntrospection_SCANNER GObjectIntrospection_COMPILER
      GObjectIntrospection_GENERATE GObjectIntrospection_GIRDIR
      GObjectIntrospection_TYPELIBDIR GObjectIntrospection_LIBRARIES
)

mark_as_advanced(
  GObjectIntrospection_SCANNER
  GObjectIntrospection_COMPILER
  GObjectIntrospection_GENERATE
  GObjectIntrospection_GIRDIR
  GObjectIntrospection_TYPELIBDIR
  GObjectIntrospection_CFLAGS
  GObjectIntrospection_LIBRARIES
)
