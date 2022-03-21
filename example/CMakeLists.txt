add_executable(res_example "example.cpp")
res_embed(res_example "resource" ${CMAKE_CURRENT_SOURCE_DIR}/resource)

