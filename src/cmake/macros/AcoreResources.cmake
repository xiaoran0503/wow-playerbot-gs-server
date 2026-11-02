#
# This file is part of the AzerothCore Project. See AUTHORS file for Copyright information
#
# This file is free software; as a special exception the author hereby grants
# unlimited permission to copy and/or distribute it, with or without
# modifications, as long as this notice is preserved.
#
# Independent resource (.rc) compilation for application targets.
#
# Why this exists:
#   The MSBuild RC task inherits every include directory of the target. worldserver
#   links 40+ static script modules, so its include closure grows to 470+ paths
#   (~35 KB), which exceeds the 32767 character limit of a Windows command line and
#   makes rc.exe fail with MSB6003. The .rc carries both the application ICON and the
#   VERSIONINFO block, so the resource cannot simply be dropped.
#
#   This module compiles the .rc with a standalone rc.exe invocation that only gets a
#   handful of /I paths (app directory, build root for revision.h, SDK and CRT
#   headers). The resulting .res is handed to the linker, so icon and version info
#   survive while the command line length no longer depends on the module count.
#

# Locate rc.exe:
#   1) next to cl.exe (some toolchains ship it there)
#   2) the Windows SDK (the canonical location, e.g.
#      ".../Windows Kits/10/bin/10.0.26100.0/x64/rc.exe")
function(_acore_locate_rc)
  if (ACORE_RC_EXECUTABLE AND EXISTS "${ACORE_RC_EXECUTABLE}")
    return()
  endif()

  if (CMAKE_CXX_COMPILER)
    get_filename_component(_acore_bindir "${CMAKE_CXX_COMPILER}" DIRECTORY)
    if (EXISTS "${_acore_bindir}/rc.exe")
      set(ACORE_RC_EXECUTABLE "${_acore_bindir}/rc.exe" CACHE FILEPATH
        "rc.exe used to compile application resources")
      return()
    endif()
  endif()

  # $ENV{ProgramFiles(x86)} 里的括号必须转义，否则 CMake 会把 '(' 当成变量名的一部分
  set(_acore_kit_roots
    "$ENV{ProgramFiles\(x86\)}/Windows Kits/10"
    "C:/Program Files (x86)/Windows Kits/10"
    "$ENV{ProgramFiles}/Windows Kits/10"
    "C:/Program Files/Windows Kits/10")

  foreach(_acore_root ${_acore_kit_roots})
    if (EXISTS "${_acore_root}/bin")
      file(GLOB _acore_sdk_rc "${_acore_root}/bin/*/x64/rc.exe")
      if (_acore_sdk_rc)
        list(SORT _acore_sdk_rc)
        list(GET _acore_sdk_rc -1 ACORE_RC_EXECUTABLE)
        set(ACORE_RC_EXECUTABLE "${ACORE_RC_EXECUTABLE}" CACHE FILEPATH
          "rc.exe used to compile application resources")
        return()
      endif()
    endif()
  endforeach()
endfunction()

# Derive the SDK include subdirectories (um/shared/ucrt) from the rc.exe location:
#   <kit>/bin/<version>/x64/rc.exe  ->  <kit>/Include/<version>/{um,shared,ucrt}
function(_acore_sdk_include_dirs out_var)
  set(_acore_dirs)
  if (ACORE_RC_EXECUTABLE)
    get_filename_component(_acore_arch    "${ACORE_RC_EXECUTABLE}" DIRECTORY)  # .../bin/<ver>/x64
    get_filename_component(_acore_ver_dir "${_acore_arch}" DIRECTORY)         # .../bin/<ver>
    get_filename_component(_acore_ver     "${_acore_ver_dir}" NAME)           # <ver>
    get_filename_component(_acore_bin     "${_acore_ver_dir}" DIRECTORY)      # .../bin
    get_filename_component(_acore_kit     "${_acore_bin}" DIRECTORY)          # Windows Kits/10
    foreach(_acore_sub um shared ucrt)
      if (EXISTS "${_acore_kit}/Include/${_acore_ver}/${_acore_sub}")
        list(APPEND _acore_dirs "${_acore_kit}/Include/${_acore_ver}/${_acore_sub}")
      endif()
    endforeach()
  endif()
  set(${out_var} ${_acore_dirs} PARENT_SCOPE)
endfunction()

# acore_compile_application_resources(<target> <application_name> <source_app_path>)
function(acore_compile_application_resources target app_name src_dir)
  set(_acore_rc_file "${src_dir}/${app_name}.rc")
  if (NOT EXISTS "${_acore_rc_file}")
    return()
  endif()

  _acore_locate_rc()
  if (NOT ACORE_RC_EXECUTABLE OR NOT EXISTS "${ACORE_RC_EXECUTABLE}")
    message(WARNING
      "acore: rc.exe not found, ${app_name}.exe will be built without icon/version info")
    return()
  endif()

  _acore_sdk_include_dirs(_acore_sdk_inc)

  set(_acore_res "${CMAKE_CURRENT_BINARY_DIR}/${app_name}.res")

  set(_acore_includes /I "${src_dir}" /I "${CMAKE_BINARY_DIR}")
  foreach(_acore_dir ${_acore_sdk_inc} ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES})
    list(APPEND _acore_includes /I "${_acore_dir}")
  endforeach()

  add_custom_command(TARGET ${target} PRE_LINK
    COMMAND "${ACORE_RC_EXECUTABLE}" /nologo /fo "${_acore_res}"
            ${_acore_includes} "${_acore_rc_file}"
    COMMENT "Compiling ${app_name}.rc (icon + version info)"
    VERBATIM)

  target_link_options(${target} PRIVATE "${_acore_res}")
endfunction()
