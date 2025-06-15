cmake_minimum_required(VERSION 3.17)
project(resource_test LANGUAGES ASM C CXX)

# Add the res_embed subdirectory
add_subdirectory(.. res_embed_build)

# Create test executable
add_executable(resource_test test_app.cpp)

# Embed multiple resources
res_embed(TARGET resource_test NAME "resource1" PATH ${CMAKE_CURRENT_SOURCE_DIR}/resources/resource1.txt)
res_embed(TARGET resource_test NAME "resource2" PATH ${CMAKE_CURRENT_SOURCE_DIR}/resources/resource2.txt)
res_embed(TARGET resource_test NAME "binary" PATH ${CMAKE_CURRENT_SOURCE_DIR}/resources/binary.dat)