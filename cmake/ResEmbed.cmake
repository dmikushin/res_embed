cmake_policy(SET CMP0057 NEW)

# Convert file into a binary blob, embed it into an ASM file, and generate a C++ interface for it.
function(res_embed)
	set(options KEYWORD)
	set(oneValueArgs TARGET NAME PATH)
	set(multiValueArgs DEPENDS)
	cmake_parse_arguments(RES_EMBED "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
	set(EMBED_FILE_CPP_PATH "${CMAKE_CURRENT_BINARY_DIR}/${RES_EMBED_NAME}.cpp")

	set(_RES_EMBED_PATH ${CMAKE_CURRENT_FUNCTION_LIST_DIR})
	set(RES_EMBED_CURRENT_INCLUDE_DIR ${_RES_EMBED_PATH}/../include)

	if(NOT DEFINED USE_NASM)
		if (MSVC OR APPLE)
			if (NOT CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64")
				set(USE_NASM TRUE)
			endif()
		else()
			set(USE_NASM FALSE)
		endif()
	endif()

	if (USE_NASM)
		find_package(Nasm REQUIRED)
		enable_language(ASM_NASM)
		if(NOT CMAKE_ASM_NASM_COMPILER_LOADED)
			message(FATAL_ERROR "NASM assembler not found, please install NASM")
		endif()
		set(RES_EMBED_ASM_IN "${RES_EMBED_CURRENT_INCLUDE_DIR}/res_embed.nasm.in")
		set(RES_EMBED_ASM_EXT ".nasm")
	else()
		enable_language(ASM)
		set(RES_EMBED_ASM_IN "${RES_EMBED_CURRENT_INCLUDE_DIR}/res_embed.gas.in")
		set(RES_EMBED_ASM_EXT ".s")
	endif()

	add_custom_command(
		OUTPUT ${EMBED_FILE_CPP_PATH}
		COMMAND ${CMAKE_COMMAND} -DCMAKE_CURRENT_INCLUDE_DIR=${RES_EMBED_CURRENT_INCLUDE_DIR} -DFILE_KEY=${RES_EMBED_NAME} -DFILE_PATH=${RES_EMBED_PATH} -DEMBED_FILE_PATH=${EMBED_FILE_CPP_PATH} -P ${_RES_EMBED_PATH}/EmbedFile.cmake
		COMMENT "Adding file ${RES_EMBED_PATH}"
		DEPENDS "${RES_EMBED_CURRENT_INCLUDE_DIR}/res_embed.cpp.in" "${RES_EMBED_PATH}")
	set_source_files_properties("${EMBED_FILE_CPP_PATH}" PROPERTIES GENERATED TRUE)

	target_sources(${RES_EMBED_TARGET} PRIVATE ${EMBED_FILE_CPP_PATH})

	set(EMBED_FILE_PATH "${CMAKE_CURRENT_BINARY_DIR}/${RES_EMBED_NAME}${RES_EMBED_ASM_EXT}")
	add_custom_command(
		OUTPUT ${EMBED_FILE_PATH}
		COMMAND ${CMAKE_COMMAND} -DCMAKE_CURRENT_INCLUDE_DIR=${RES_EMBED_CURRENT_INCLUDE_DIR} -DFILE_KEY=${RES_EMBED_NAME} -DFILE_PATH=${RES_EMBED_PATH} -DEMBED_FILE_PATH=${EMBED_FILE_PATH} -DRES_EMBED_ASM_IN=${RES_EMBED_ASM_IN} -DSYSTEM_PROCESSOR=${CMAKE_SYSTEM_PROCESSOR} -P ${_RES_EMBED_PATH}/EmbedFile.cmake
		COMMENT "Embedding file ${RES_EMBED_PATH} content identified by key ${RES_EMBED_NAME}"
		DEPENDS "${RES_EMBED_ASM_IN}" "${RES_EMBED_PATH}" "${EMBED_FILE_CPP_PATH}")
	set_source_files_properties("${EMBED_FILE_PATH}" PROPERTIES GENERATED TRUE)
	set_source_files_properties("${EMBED_FILE_PATH}" PROPERTIES OBJECT_DEPENDS "${EMBED_FILE_CPP_PATH}")
	set_source_files_properties("${EMBED_FILE_PATH}" PROPERTIES OBJECT_DEPENDS "${RES_EMBED_PATH}")

	if (USE_NASM)
		set_source_files_properties("${EMBED_FILE_PATH}" PROPERTIES LANGUAGE ASM_NASM)
	else()
		set_source_files_properties("${EMBED_FILE_PATH}" PROPERTIES LANGUAGE ASM)
	endif()

	# Submit the resulting source file for compilation
	add_library(${RES_EMBED_TARGET}_${RES_EMBED_NAME} STATIC ${EMBED_FILE_PATH})
	set_target_properties(${RES_EMBED_TARGET}_${RES_EMBED_NAME} PROPERTIES LINKER_LANGUAGE C)
	if (RES_EMBED_KEYWORD)
		target_link_libraries(${RES_EMBED_TARGET} PRIVATE ${RES_EMBED_TARGET}_${RES_EMBED_NAME})
	else()
		target_link_libraries(${RES_EMBED_TARGET} ${RES_EMBED_TARGET}_${RES_EMBED_NAME})
	endif()
	if (RES_EMBED_DEPENDS)
		add_dependencies(${RES_EMBED_TARGET} ${RES_EMBED_DEPENDS})
	endif()

	get_target_property(LINKED_LIBRARIES ${RES_EMBED_TARGET} LINK_LIBRARIES)
	if (TARGET res::embed)
		if (NOT ("res::embed" IN_LIST LINKED_LIBRARIES))
			if (RES_EMBED_KEYWORD)
				target_link_libraries(${RES_EMBED_TARGET} PRIVATE res::embed)
			else()
				target_link_libraries(${RES_EMBED_TARGET} res::embed)
			endif()
		endif()
	else()
		if (NOT ("res::embed::static" IN_LIST LINKED_LIBRARIES))
			if (RES_EMBED_KEYWORD)
				target_link_libraries(${RES_EMBED_TARGET} PRIVATE res::embed::static)
			else()
				target_link_libraries(${RES_EMBED_TARGET} res::embed::static)
			endif()
		endif()
	endif()

	message(STATUS "Resource file ${RES_EMBED_PATH} shall be added to target ${RES_EMBED_TARGET}")
endfunction()

