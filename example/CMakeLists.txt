include(ResEmbed)

if (NOT TARGET res_example)
add_executable(res_example "example.cpp")
res_embed(TARGET res_example NAME "resource" PATH ${CMAKE_CURRENT_SOURCE_DIR}/resource)
endif()

