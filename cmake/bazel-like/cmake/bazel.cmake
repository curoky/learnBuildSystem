get_filename_component(BAZEL_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR} DIRECTORY)

# include(color)

macro(_build_target func_tag)
  set(_sources ${ARGN})

  if(${func_tag} STREQUAL "cc_lib")
    add_library(${_sources})
  elseif(${func_tag} STREQUAL "cc_bin")
    list(REMOVE_ITEM _sources STATIC SHARED)
    add_executable(${_sources})
  endif()
endmacro(_build_target)

function(cmake_library TARGET_NAME)
  set(options STATIC SHARED)
  set(oneValueArgs TAG)
  set(multiValueArgs SRCS DEPS)
  cmake_parse_arguments(cmake_library "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if(cmake_library_SRCS)
    if(cmake_library_SHARED) # build *.so
      set(_lib_type SHARED)
    else(cmake_library_SHARED)
      set(_lib_type STATIC)
    endif(cmake_library_SHARED)
    _build_target(${cmake_library_TAG} ${TARGET_NAME} ${_lib_type} ${cmake_library_SRCS})
    if(cmake_library_DEPS)
      add_dependencies(${TARGET_NAME} ${cmake_library_DEPS})
      target_link_libraries(${TARGET_NAME} ${cmake_library_DEPS})
    endif(cmake_library_DEPS)
  else(cmake_library_SRCS)
    if(cmake_library_DEPS AND ${cmake_library_TAG} STREQUAL "cc_lib")
      merge_static_libs(${TARGET_NAME} ${cmake_library_DEPS})
    else()
      message(FATAL_ERROR "Please review the valid syntax: typing `make helps` in the Terminal"
                          "or visiting https://github.com/gangliao/bazel.cmake#cheat-sheet")
    endif()
  endif(cmake_library_SRCS)
endfunction(cmake_library)

function(cc_library)
  cmake_library(${ARGV} TAG cc_lib)
endfunction(cc_library)

function(cc_binary)
  cmake_library(${ARGV} TAG cc_bin)
endfunction(cc_binary)

function(cc_test)
  cmake_library(${ARGV} TAG cc_bin)
  add_test(${ARGV0} ${ARGV0})
endfunction(cc_test)