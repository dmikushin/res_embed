set(CMAKE_CURRENT_INCLUDE_DIR ${CMAKE_CURRENT_LIST_DIR}/../include)

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
		COMMAND ${CMAKE_COMMAND} -DCMAKE_CURRENT_INCLUDE_DIR=${CMAKE_CURRENT_INCLUDE_DIR} -DFILE_KEY=${FILE_KEY} -DFILE_PATH=${FILE_PATH} -DEMBED_FILE_PATH=${EMBED_FILE_PATH} -DRES_EMBED_ASM_IN=${RES_EMBED_ASM_IN} -P ${CMAKE_CURRENT_INCLUDE_DIR}/../cmake/EmbedFile.cmake
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

	if (RES_EMBED_USE_SHARED)
		target_link_libraries(${tgt} res::embed)
	else()
		target_link_libraries(${tgt} res::embed::static)
	endif()

	message(STATUS "Resource file ${EMBED_FILE_PATH} shall be added to target ${tgt}")
endmacro()

