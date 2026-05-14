#include "res_embed.h"

#include <cstddef>

extern "C" const char* static_resource_get(size_t* size)
{
    return res::embed::get("static_resource", size);
}
