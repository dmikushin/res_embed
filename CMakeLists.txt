cmake_minimum_required(VERSION 3.1)

project(incbin)

enable_language(ASM_NASM)

if(NOT CMAKE_ASM_NASM_COMPILER_LOADED)
message(FATAL_ERROR "NASM assembler not found, please install NASM")
endif()

add_library(incbin SHARED ${CMAKE_CURRENT_SOURCE_DIR}/src/incbin.cpp)
target_include_directories(incbin PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
add_library(incbin::incbin ALIAS incbin)

set(CMAKE_CURRENT_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include" CACHE STRING "" FORCE)

# Convert file into a binary blob and embed it into a C++ source file.
macro(add_source_file FILE_PATH SOURCES)
	get_filename_component(FILE_NAME ${FILE_PATH} NAME)

	set(EMBED_FILE_PATH "${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.cpp")
	add_custom_command(
		OUTPUT ${EMBED_FILE_PATH}
		COMMAND ${CMAKE_COMMAND} -DCMAKE_CURRENT_INCLUDE_DIR=${CMAKE_CURRENT_INCLUDE_DIR} -DFILE_NAME=${FILE_NAME} -DFILE_PATH=${FILE_PATH} -DEMBED_FILE_PATH=${EMBED_FILE_PATH} -P ${CMAKE_CURRENT_INCLUDE_DIR}/../cmake/EmbedFile.cmake
		COMMENT "Embedding file ${FILE_PATH}"
		DEPENDS "${CMAKE_CURRENT_INCLUDE_DIR}/incbin.cpp.in")
	set_source_files_properties("${EMBED_FILE_PATH}" PROPERTIES GENERATED TRUE) 

	# Submit the resulting source file for compilation
	list(APPEND ${SOURCES} ${EMBED_FILE_PATH})

	message(STATUS "Source file ${EMBED_FILE_PATH} shall be added to ${SOURCES}")

	set(EMBED_FILE_PATH "${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.asm")
	add_custom_command(
		OUTPUT ${EMBED_FILE_PATH}
		COMMAND ${CMAKE_COMMAND} -DCMAKE_CURRENT_INCLUDE_DIR=${CMAKE_CURRENT_INCLUDE_DIR} -DFILE_NAME=${FILE_NAME} -DFILE_PATH=${FILE_PATH} -DEMBED_FILE_PATH=${EMBED_FILE_PATH} -P ${CMAKE_CURRENT_INCLUDE_DIR}/../cmake/EmbedFile.cmake
		COMMENT "Embedding file ${FILE_PATH}"
		DEPENDS "${CMAKE_CURRENT_INCLUDE_DIR}/incbin.asm.in")
	set_source_files_properties("${EMBED_FILE_PATH}" PROPERTIES GENERATED TRUE)
	set_source_files_properties("${EMBED_FILE_PATH}" PROPERTIES LANGUAGE ASM_NASM)

	# Submit the resulting source file for compilation
	list(APPEND ${SOURCES} ${EMBED_FILE_PATH})

	message(STATUS "Source file ${EMBED_FILE_PATH} shall be added to ${SOURCES}")
endmacro()

# Convert file into a binary blob and embed it into a C++ header file.
macro(add_header_file FILE_PATH SOURCES)
	get_filename_component(FILE_NAME ${FILE_PATH} NAME)

	# Translate content into comma-separated byte codes.
	set(EMBED_FILE_PATH "${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.h")
    add_custom_command(
	OUTPUT ${EMBED_FILE_PATH}
	COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_CURRENT_BINARY_DIR}"
	COMMAND $<TARGET_FILE:incbin> -i < ${FILE_PATH} > ${EMBED_FILE_PATH}
		COMMENT "Embedding file ${FILE_PATH}"
		DEPENDS ${FILE_PATH} incbin)
	set_source_files_properties("${EMBED_FILE_PATH}" PROPERTIES GENERATED TRUE) 
	# Submit the resulting source file for compilation
	list(APPEND ${SOURCES} ${EMBED_FILE_PATH})
	message(STATUS "Header file ${EMBED_FILE_PATH} shall be added to ${SOURCES}")
endmacro()

