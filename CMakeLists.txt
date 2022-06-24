cmake_minimum_required(VERSION 3.1)

project(res_embed)

option(RES_EMBED_USE_SHARED "Use shared library for res_embed (default: OFF)" OFF)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} PARENT_SCOPE)

if (RES_EMBED_USE_SHARED)
if (NOT TARGET res_embed)
add_library(res_embed SHARED ${CMAKE_CURRENT_SOURCE_DIR}/src/res_embed.cpp)
set_property(TARGET res_embed PROPERTY CXX_STANDARD 11)
target_include_directories(res_embed PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include")
add_library(res::embed ALIAS res_embed)
endif()
else()
if (NOT TARGET res_embed_static)
add_library(res_embed_static STATIC ${CMAKE_CURRENT_SOURCE_DIR}/src/res_embed.cpp)
set_property(TARGET res_embed_static PROPERTY CXX_STANDARD 11)
set_property(TARGET res_embed_static PROPERTY POSITION_INDEPENDENT_CODE ON)
target_compile_definitions(res_embed_static PUBLIC RES_EMBED_STATIC)
target_include_directories(res_embed_static PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include")
add_library(res::embed::static ALIAS res_embed_static)
endif()
endif()

add_subdirectory(example)

