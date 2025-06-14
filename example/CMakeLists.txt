project(res_example LANGUAGES ASM C CXX)

if (NOT TARGET res_example)
add_executable(res_example "example.cpp")
res_embed(TARGET res_example NAME "resource" PATH ${CMAKE_CURRENT_SOURCE_DIR}/resource)

# ==============================================================================
# Windows DLL Handling Solutions
# ==============================================================================
# Windows doesn't have an equivalent to Linux's RPATH/$ORIGIN, so we need to
# handle DLL dependencies manually. Here are the available solutions:
#
# 1. POST_BUILD copy (implemented below) - Most reliable, copies DLL after build
# 2. Static linking - Set BUILD_SHARED_LIBS=OFF to avoid DLL issues entirely
# 3. Installation with proper RUNTIME DESTINATION - For deployed applications
# 4. Custom target with dependencies - For more complex scenarios
# 5. Environment variable modification - For development environments
#
# The POST_BUILD copy solution is the most common and reliable approach.
# ==============================================================================

# On Windows, copy the DLL to the executable directory after build
if(WIN32 AND BUILD_SHARED_LIBS)
  # Get the target name of the res_embed library
  if(BUILD_SHARED_LIBS)
    set(_res_embed_target_name res_embed)
  else()
    set(_res_embed_target_name res_embed_static)
  endif()

  # Add a post-build step to copy the DLL
  add_custom_command(TARGET res_example POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    $<TARGET_FILE:${_res_embed_target_name}>
    $<TARGET_FILE_DIR:res_example>
    COMMENT "Copying res_embed DLL to example directory"
  )

  # Alternative solution: Set the working directory for debugging in IDEs
  # This helps when running from Visual Studio or other IDEs
  set_target_properties(res_example PROPERTIES
    VS_DEBUGGER_WORKING_DIRECTORY $<TARGET_FILE_DIR:res_example>
  )
endif()
endif()

