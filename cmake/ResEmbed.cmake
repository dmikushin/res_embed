cmake_policy(SET CMP0057 NEW)

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
macro(res_embed)
	set(oneValueArgs TARGET NAME PATH)
	set(multiValueArgs DEPENDS)
	set(EMBED_FILE_CPP_PATH "${CMAKE_CURRENT_BINARY_DIR}/${RES_EMBED_NAME}.cpp")
	cmake_parse_arguments(RES_EMBED "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

	add_custom_command(
		OUTPUT ${EMBED_FILE_CPP_PATH}
		COMMAND ${CMAKE_COMMAND} -DCMAKE_CURRENT_INCLUDE_DIR=${CMAKE_CURRENT_INCLUDE_DIR} -DFILE_KEY=${RES_EMBED_NAME} -DFILE_PATH=${RES_EMBED_PATH} -DEMBED_FILE_PATH=${EMBED_FILE_CPP_PATH} -P ${CMAKE_CURRENT_INCLUDE_DIR}/../cmake/EmbedFile.cmake
		COMMENT "Adding file ${RES_EMBED_PATH}"
		DEPENDS "${CMAKE_CURRENT_INCLUDE_DIR}/res_embed.cpp.in")
	set_source_files_properties("${EMBED_FILE_CPP_PATH}" PROPERTIES GENERATED TRUE) 

	target_sources(${RES_EMBED_TARGET} PRIVATE ${EMBED_FILE_CPP_PATH})

	set(EMBED_FILE_PATH "${CMAKE_CURRENT_BINARY_DIR}/${RES_EMBED_NAME}.asm")
	add_custom_command(
		OUTPUT ${EMBED_FILE_PATH}
		COMMAND ${CMAKE_COMMAND} -DCMAKE_CURRENT_INCLUDE_DIR=${CMAKE_CURRENT_INCLUDE_DIR} -DFILE_KEY=${RES_EMBED_NAME} -DFILE_PATH=${RES_EMBED_PATH} -DEMBED_FILE_PATH=${EMBED_FILE_PATH} -DRES_EMBED_ASM_IN=${RES_EMBED_ASM_IN} -P ${CMAKE_CURRENT_INCLUDE_DIR}/../cmake/EmbedFile.cmake
		COMMENT "Embedding file ${RES_EMBED_PATH} content"
		DEPENDS "${RES_EMBED_ASM_IN}")
	set_source_files_properties("${EMBED_FILE_PATH}" PROPERTIES GENERATED TRUE)
	if (MSVC OR APPLE)
		set_source_files_properties("${EMBED_FILE_PATH}" PROPERTIES LANGUAGE ASM_NASM)
	else()
		set_source_files_properties("${EMBED_FILE_PATH}" PROPERTIES LANGUAGE ASM-ATT)
	endif()

	# Submit the resulting source file for compilation
	add_library(${RES_EMBED_TARGET}_${RES_EMBED_NAME} STATIC ${EMBED_FILE_PATH})
	set_target_properties(${RES_EMBED_TARGET}_${RES_EMBED_NAME} PROPERTIES LINKER_LANGUAGE C)
	target_link_libraries(${RES_EMBED_TARGET} ${RES_EMBED_TARGET}_${RES_EMBED_NAME})
	if (RES_EMBED_DEPENDS)
		add_dependencies(${RES_EMBED_TARGET} ${RES_EMBED_DEPENDS})
	endif()

	get_target_property(LINKED_LIBRARIES ${RES_EMBED_TARGET} LINK_LIBRARIES)
	if (RES_EMBED_USE_SHARED)
		if (NOT ("res::embed" IN_LIST LINKED_LIBRARIES))
			target_link_libraries(${RES_EMBED_TARGET} res::embed)
		endif()
	else()
		if (NOT ("res::embed::static" IN_LIST LINKED_LIBRARIES))
			target_link_libraries(${RES_EMBED_TARGET} res::embed::static)
		endif()
	endif()

	message(STATUS "Resource file ${EMBED_FILE_PATH} shall be added to target ${RES_EMBED_TARGET}")
endmacro()

