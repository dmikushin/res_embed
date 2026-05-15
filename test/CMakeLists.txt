cmake_minimum_required(VERSION 3.17)
project(resource_test LANGUAGES C CXX)

# Add the res_embed subdirectory
add_subdirectory(.. res_embed_build)

# Create test executable
add_executable(resource_test test_app.cpp)

# Embed multiple resources
res_embed(TARGET resource_test NAME "resource1" PATH ${CMAKE_CURRENT_SOURCE_DIR}/resources/resource1.txt)
res_embed(TARGET resource_test NAME "resource2" PATH ${CMAKE_CURRENT_SOURCE_DIR}/resources/resource2.txt)
res_embed(TARGET resource_test NAME "binary" PATH ${CMAKE_CURRENT_SOURCE_DIR}/resources/binary.dat)

# Regression test for static archive consumers: no manual init or whole-archive flags.
add_library(static_resource_lib STATIC static_lib.cpp)
target_include_directories(static_resource_lib PRIVATE ../include)
res_embed(TARGET static_resource_lib NAME "static_resource" PATH ${CMAKE_CURRENT_SOURCE_DIR}/resources/resource1.txt KEYWORD)
res_embed(TARGET static_resource_lib NAME "static_resource_extra" PATH ${CMAKE_CURRENT_SOURCE_DIR}/resources/resource2.txt KEYWORD)

add_executable(static_resource_test static_main.cpp)
target_link_libraries(static_resource_test PRIVATE static_resource_lib)

if(WIN32 AND BUILD_SHARED_LIBS)
  foreach(_test_target resource_test static_resource_test)
    add_custom_command(TARGET ${_test_target} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_if_different
      $<TARGET_FILE:res_embed>
      $<TARGET_FILE_DIR:${_test_target}>
      COMMENT "Copying res_embed DLL to ${_test_target} directory")
  endforeach()
endif()

enable_testing()
add_test(NAME resource_test COMMAND resource_test)
add_test(NAME static_resource_test COMMAND static_resource_test)
