cmake_minimum_required(VERSION 3.0)

string(SHA256 FILE_KEY_HASH ${FILE_KEY})

find_program(XDG_MIME xdg-mime)
if (XDG_MIME)
execute_process(COMMAND ${XDG_MIME} query filetype ${FILE_PATH} OUTPUT_VARIABLE FILE_MIME)
else()
set(FILE_MIME "unsupported")
endif()

get_filename_component(EMBED_FILE_EXT ${EMBED_FILE_PATH} LAST_EXT)

if (MSVC OR APPLE)
set(RES_EMBED_ASM_IN "${CMAKE_CURRENT_INCLUDE_DIR}/res_embed.nasm.in")
else()
set(RES_EMBED_ASM_IN "${CMAKE_CURRENT_INCLUDE_DIR}/res_embed.gas.in")
endif()

# Substitute encoded HEX content into template source file
if ("${EMBED_FILE_EXT}" STREQUAL ".cpp")
configure_file("${CMAKE_CURRENT_INCLUDE_DIR}/res_embed.cpp.in" ${EMBED_FILE_PATH})
elseif ("${EMBED_FILE_EXT}" STREQUAL ".asm")
if (APPLE)
set(OS_DEPENDENT_PREFIX "_")
endif()
configure_file("${RES_EMBED_ASM_IN}" ${EMBED_FILE_PATH})
else()
message(FATAL_ERROR "Unknown embedded file template extension: ${EMBED_FILE_EXT}")
endif()

