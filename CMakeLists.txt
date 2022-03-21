cmake_minimum_required(VERSION 3.1)

project(res_embed)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

set(CMAKE_CURRENT_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include" CACHE STRING "" FORCE)

if (MSVC OR APPLE)
find_package(Nasm REQUIRED)
enable_language(ASM_NASM)
if(NOT CMAKE_ASM_NASM_COMPILER_LOADED)
message(FATAL_ERROR "NASM assembler not found, please install NASM")
endif()
set(RES_EMBED_ASM_IN "${CMAKE_CURRENT_INCLUDE_DIR}/res_embed.nasm.in")
else()
enable_language(ASM-ATT)
set(RES_EMBED_ASM_IN "${CMAKE_CURRENT_INCLUDE_DIR}/res_embed.gas.in")
endif()

add_library(res_embed SHARED ${CMAKE_CURRENT_SOURCE_DIR}/src/res_embed.cpp)
set_property(TARGET res_embed PROPERTY CXX_STANDARD 11)
target_include_directories(res_embed PUBLIC ${CMAKE_CURRENT_INCLUDE_DIR})
add_library(res::embed ALIAS res_embed)

add_library(res_embed_static STATIC ${CMAKE_CURRENT_SOURCE_DIR}/src/res_embed.cpp)
set_property(TARGET res_embed_static PROPERTY CXX_STANDARD 11)
set_property(TARGET res_embed_static PROPERTY POSITION_INDEPENDENT_CODE ON)
target_compile_definitions(res_embed_static PRIVATE RES_EMBED_STATIC)
target_include_directories(res_embed_static PUBLIC ${CMAKE_CURRENT_INCLUDE_DIR})
add_library(res::embed::static ALIAS res_embed_static)

# Convert file into a binary blob and embed it into a C++ source file.
macro(res_embed tgt FILE_KEY FILE_PATH)
	set(EMBED_FILE_CPP_PATH "${CMAKE_CURRENT_BINARY_DIR}/${FILE_KEY}.cpp")
	add_custom_command(
		OUTPUT ${EMBED_FILE_CPP_PATH}
		COMMAND ${CMAKE_COMMAND} -DCMAKE_CURRENT_INCLUDE_DIR=${CMAKE_CURRENT_INCLUDE_DIR} -DFILE_KEY=${FILE_KEY} -DFILE_PATH=${FILE_PATH} -DEMBED_FILE_PATH=${EMBED_FILE_CPP_PATH} -P ${CMAKE_CURRENT_INCLUDE_DIR}/../cmake/EmbedFile.cmake
		COMMENT "Adding file ${FILE_PATH}"
		DEPENDS "${CMAKE_CURRENT_INCLUDE_DIR}/res_embed.cpp.in")
	set_source_files_properties("${EMBED_FILE_CPP_PATH}" PROPERTIES GENERATED TRUE) 

	target_sources(${tgt} PRIVATE ${EMBED_FILE_CPP_PATH})

	set(EMBED_FILE_PATH "${CMAKE_CURRENT_BINARY_DIR}/${FILE_KEY}.asm")
	add_custom_command(
		OUTPUT ${EMBED_FILE_PATH}
		COMMAND ${CMAKE_COMMAND} -DCMAKE_CURRENT_INCLUDE_DIR=${CMAKE_CURRENT_INCLUDE_DIR} -DFILE_KEY=${FILE_KEY} -DFILE_PATH=${FILE_PATH} -DEMBED_FILE_PATH=${EMBED_FILE_PATH} -P ${CMAKE_CURRENT_INCLUDE_DIR}/../cmake/EmbedFile.cmake
		COMMENT "Embedding file ${FILE_PATH} content"
		DEPENDS "${RES_EMBED_ASM_IN}")
	set_source_files_properties("${EMBED_FILE_PATH}" PROPERTIES GENERATED TRUE)
	if (MSVC OR APPLE)
		set_source_files_properties("${EMBED_FILE_PATH}" PROPERTIES LANGUAGE ASM_NASM)
	else()
		set_source_files_properties("${EMBED_FILE_PATH}" PROPERTIES LANGUAGE ASM-ATT)
	endif()

	# Submit the resulting source file for compilation
	target_sources(${tgt} PRIVATE ${EMBED_FILE_PATH})

	target_link_libraries(${tgt} res::embed)

	message(STATUS "Resource file ${EMBED_FILE_PATH} shall be added to target ${tgt}")
endmacro()

add_subdirectory(example)

