#include <cstddef>
#include <cstring>
#include <iostream>

extern "C" const char* static_resource_get(size_t* size);
extern "C" const char* static_resource_extra_get(size_t* size);

static int check_resource(const char* name, const char* data, size_t size, const char* expected)
{
    if (!data) {
        std::cerr << name << " is missing" << std::endl;
        return 1;
    }

    size_t expected_size = std::strlen(expected);
    if (size != expected_size) {
        std::cerr << name << " size mismatch" << std::endl;
        return 1;
    }

    if (std::memcmp(data, expected, size) != 0) {
        std::cerr << name << " content mismatch" << std::endl;
        return 1;
    }

    return 0;
}

int main()
{
    size_t size = 0;
    const char* data = static_resource_get(&size);
    if (check_resource("Static library resource", data, size, "Test resource 1\n") != 0) {
        return 1;
    }

    data = static_resource_extra_get(&size);
    if (check_resource("Static library extra resource", data, size, "Test resource 2 with different content!\n") != 0) {
        return 1;
    }

    return 0;
}
