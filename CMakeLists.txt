cmake_minimum_required(VERSION 3.1)

project(
  res_embed
  VERSION 1.0.0
  LANGUAGES C CXX)

option(BUILD_SHARED_LIBS
       "Build and use shared library for res_embed (default: OFF)" OFF)

option(BUILD_EXAMPLE "Build the examples (default: ON)" ON)

if(NOT DEFINED ITERATOR_DEBUG_VALUE)
  set(ITERATOR_DEBUG_VALUE 0)
endif()
option(MSVC_ITERATOR_DEBUG "Define _ITERATOR_DEBUG_LEVEL (defaults to 0, can be set using ITERATOR_DEBUG_VALUE)" OFF)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# Only modify the parent's CMAKE_MODULE_PATH if it exists
get_directory_property(has_parent PARENT_DIRECTORY)
if(has_parent)
  set(CMAKE_MODULE_PATH
      ${CMAKE_MODULE_PATH}
      PARENT_SCOPE)
endif()

# ------------------------------------------------------------------------------

include(GNUInstallDirs)

set(RE_INSTALL_BINDIR "${CMAKE_INSTALL_BINDIR}")
set(RE_INSTALL_SBINDIR "${CMAKE_INSTALL_SBINDIR}")
set(RE_INSTALL_SYSCONFDIR "${CMAKE_INSTALL_SYSCONFDIR}")
set(RE_INSTALL_INCLUDEDIR "${CMAKE_INSTALL_INCLUDEDIR}/res_embed")
set(RE_INSTALL_DATADIR "${CMAKE_INSTALL_DATADIR}/res_embed")
set(RE_INSTALL_LIBDIR "${CMAKE_INSTALL_LIBDIR}/res_embed")
set(RE_INSTALL_DOCDIR "${CMAKE_INSTALL_DATADIR}/doc/res_embed")
set(RE_INSTALL_CMAKEDIR "${RE_INSTALL_DATADIR}/cmake")
set(RE_INSTALL_3RDPARTYDIR "${RE_INSTALL_LIBDIR}/third_party")

# ==============================================================================

if(BUILD_SHARED_LIBS)
  set(_tgt_name res_embed)
  set(_alias_name res::embed)
  set(_tgt_defines)
else()
  set(_tgt_name res_embed_static)
  set(_alias_name res::embed::static)
  set(_tgt_defines RES_EMBED_STATIC)
endif()

if(NOT TARGET ${_tgt_name})
  add_library(${_tgt_name} ${CMAKE_CURRENT_SOURCE_DIR}/src/res_embed.cpp)
  target_compile_features(${_tgt_name} PUBLIC cxx_std_11)
  set_property(TARGET ${_tgt_name} PROPERTY POSITION_INDEPENDENT_CODE ON)
  target_compile_definitions(${_tgt_name} PUBLIC ${_tgt_defines})
  target_include_directories(
    ${_tgt_name} PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>
                        $<INSTALL_INTERFACE:${RE_INSTALL_INCLUDEDIR}>)
  add_library(${_alias_name} ALIAS ${_tgt_name})
  if(MSVC AND MSVC_ITERATOR_DEBUG)
    target_compile_definitions(${_tgt_name} PUBLIC _ITERATOR_DEBUG=${ITERATOR_DEBUG_VALUE})
  endif()
endif()

# ==============================================================================

include(CMakePackageConfigHelpers)

set(_namespace res_embed::)

configure_package_config_file(
  ${CMAKE_CURRENT_LIST_DIR}/cmake/res_embedConfig.cmake.in
  ${PROJECT_BINARY_DIR}/res_embedConfig.cmake
  INSTALL_DESTINATION ${RE_INSTALL_CMAKEDIR})

write_basic_package_version_file(
  ${PROJECT_BINARY_DIR}/res_embedConfigVersion.cmake
  COMPATIBILITY SameMajorVersion)

install(FILES ${PROJECT_BINARY_DIR}/res_embedConfig.cmake
              ${PROJECT_BINARY_DIR}/res_embedConfigVersion.cmake
        DESTINATION ${RE_INSTALL_CMAKEDIR})

install(DIRECTORY ${PROJECT_SOURCE_DIR}/cmake
        DESTINATION ${RE_INSTALL_CMAKEDIR})

install(
  FILES ${PROJECT_SOURCE_DIR}/include/res_embed.cpp.in
        ${PROJECT_SOURCE_DIR}/include/res_embed.gas.in
        ${PROJECT_SOURCE_DIR}/include/res_embed.h
        ${PROJECT_SOURCE_DIR}/include/res_embed.nasm.in
  DESTINATION ${RE_INSTALL_INCLUDEDIR})

# ==============================================================================

if(BUILD_EXAMPLE)
  add_subdirectory(example)
endif()

# ==============================================================================

install(
  TARGETS ${_tgt_name}
  EXPORT res_embedTargets
  PRIVATE_HEADER DESTINATION ${RE_INSTALL_INCLUDEDIR}
  PUBLIC_HEADER DESTINATION ${RE_INSTALL_INCLUDEDIR}
  ARCHIVE DESTINATION ${RE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${RE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${RE_INSTALL_BINDIR})

install(
  EXPORT res_embedTargets
  NAMESPACE ${_namespace}
  DESTINATION ${RE_INSTALL_CMAKEDIR})

# ==============================================================================
