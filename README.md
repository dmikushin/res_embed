# Embed resources into CMake targets in a cross-platform way

Embed resources into a binary using CMake, C/C++ and assembler compilers depending on the target platfrom (Linux, Windows and MacOS are supported).

Unlike [xxd_embed](https://github.com/dmikushin/xxd_embed.git), the files are included into an assembly file as a data directly, which is fast even for very large files. In order to compile the assembly file, NASM is deployed on Windows/MacOS, and GNU AS on all other platforms.

## Example

1. Add this `res_embed` project to your CMake project as a submodule:

```
cd some/path
git submodule add https://github.com/dmikushin/res_embed.git
```

2. Integrate `res_embed` project into your `CMakeLists.txt`:

```cmake 
# ResEmbed requires C and ASM languages in addtion to the C++ API:
project(res_example LANGUAGES ASM C CXX)

add_subdirectory(some/path/res_embed)
```

3. Embed the following example resource file into an executable using `res_embed` macro:

```
$ cat resource 
Hello, world!
```

```cmake
add_executable(res_example "example.cpp")
res_embed(TARGET res_example NAME "resource" PATH ${CMAKE_CURRENT_SOURCE_DIR}/resource)
```

4. Use the embedded resource in your program:

```c++
#include "res_embed.h"

#include <cstdio>

int main(int argc, char* argv[])
{
	printf("%s", res::embed::get("resource"));
	return 0;
}
```

