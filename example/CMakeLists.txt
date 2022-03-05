set(SRCS "example.cpp")
res_embed("resource" ${CMAKE_CURRENT_SOURCE_DIR}/resource SRCS)

add_executable(res_example ${SRCS})
target_link_libraries(res_example res::embed)

