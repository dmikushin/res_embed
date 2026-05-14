#include <cstddef>
#include <cstring>
#include <iostream>

extern "C" const char* static_resource_get(size_t* size);

int main()
{
    size_t size = 0;
    const char* data = static_resource_get(&size);
    const char expected[] = "Test resource 1\n";

    if (!data) {
        std::cerr << "Static library resource is missing" << std::endl;
        return 1;
    }

    if (size != sizeof(expected) - 1) {
        std::cerr << "Static library resource size mismatch" << std::endl;
        return 1;
    }

    if (std::memcmp(data, expected, size) != 0) {
        std::cerr << "Static library resource content mismatch" << std::endl;
        return 1;
    }

    return 0;
}
