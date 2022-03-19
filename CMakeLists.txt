cmake_minimum_required(VERSION 3.1)

project(res_embed)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

if (MSVC)
find_package(Nasm REQUIRED)
enable_language(ASM_NASM)
if(NOT CMAKE_ASM_NASM_COMPILER_LOADED)
message(FATAL_ERROR "NASM assembler not found, please install NASM")
endif()
set(RES_EMBED_ASM_IN "${CMAKE_CURRENT_SOURCE_DIR}/include/res_embed.nasm.in")
else()
enable_language(ASM-ATT)
set(RES_EMBED_ASM_IN "${CMAKE_CURRENT_SOURCE_DIR}/include/res_embed.gas.in")
endif()

add_library(res_embed SHARED ${CMAKE_CURRENT_SOURCE_DIR}/src/res_embed.cpp)
set_property(TARGET res_embed PROPERTY CXX_STANDARD 11)
target_include_directories(res_embed PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
add_library(res::embed ALIAS res_embed)

add_library(res_embed_static STATIC ${CMAKE_CURRENT_SOURCE_DIR}/src/res_embed.cpp)
set_property(TARGET res_embed_static PROPERTY CXX_STANDARD 11)
target_include_directories(res_embed_static PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
add_library(res::embed::static ALIAS res_embed_static)

set(CMAKE_CURRENT_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include" CACHE STRING "" FORCE)

# Convert file into a binary blob and embed it into a C++ source file.
macro(res_embed FILE_KEY FILE_PATH SOURCES)
	set(EMBED_FILE_CPP_PATH "${CMAKE_CURRENT_BINARY_DIR}/${FILE_KEY}.cpp")
	add_custom_command(
		OUTPUT ${EMBED_FILE_CPP_PATH}
		COMMAND ${CMAKE_COMMAND} -DCMAKE_CURRENT_INCLUDE_DIR=${CMAKE_CURRENT_INCLUDE_DIR} -DFILE_KEY=${FILE_KEY} -DFILE_PATH=${FILE_PATH} -DEMBED_FILE_PATH=${EMBED_FILE_CPP_PATH} -P ${CMAKE_CURRENT_INCLUDE_DIR}/../cmake/EmbedFile.cmake
		COMMENT "Adding file ${FILE_PATH}"
		DEPENDS "${CMAKE_CURRENT_INCLUDE_DIR}/res_embed.cpp.in")
	set_source_files_properties("${EMBED_FILE_CPP_PATH}" PROPERTIES GENERATED TRUE) 

	list(APPEND ${SOURCES} ${EMBED_FILE_CPP_PATH})

	set(EMBED_FILE_PATH "${CMAKE_CURRENT_BINARY_DIR}/${FILE_KEY}.asm")
	add_custom_command(
		OUTPUT ${EMBED_FILE_PATH}
		COMMAND ${CMAKE_COMMAND} -DCMAKE_CURRENT_INCLUDE_DIR=${CMAKE_CURRENT_INCLUDE_DIR} -DFILE_KEY=${FILE_KEY} -DFILE_PATH=${FILE_PATH} -DEMBED_FILE_PATH=${EMBED_FILE_PATH} -P ${CMAKE_CURRENT_INCLUDE_DIR}/../cmake/EmbedFile.cmake
		COMMENT "Embedding file ${FILE_PATH} content"
		DEPENDS "${RES_EMBED_ASM_IN}")
	set_source_files_properties("${EMBED_FILE_PATH}" PROPERTIES GENERATED TRUE)
	if (MSVC)
		set_source_files_properties("${EMBED_FILE_PATH}" PROPERTIES LANGUAGE ASM_NASM)
	else()
		set_source_files_properties("${EMBED_FILE_PATH}" PROPERTIES LANGUAGE ASM-ATT)
	endif()

	# Submit the resulting source file for compilation
	list(APPEND ${SOURCES} ${EMBED_FILE_PATH})

	message(STATUS "Source file ${EMBED_FILE_PATH} shall be added to ${SOURCES}")
endmacro()

add_subdirectory(example)

