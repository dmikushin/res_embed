#include "res_embed.h"
#include <cstdio>
#include <cstring>
#include <iostream>

int main() {
    // Test text resource 1
    const char* res1 = res::embed::get("resource1");
    if (strcmp(res1, "Test resource 1\n") != 0) {
        std::cerr << "Resource 1 mismatch" << std::endl;
        return 1;
    }
    
    // Test text resource 2
    const char* res2 = res::embed::get("resource2");
    if (strcmp(res2, "Test resource 2 with different content!\n") != 0) {
        std::cerr << "Resource 2 mismatch" << std::endl;
        return 1;
    }
    
    // Test binary resource
    const char* binary = res::embed::get("binary");
    size_t binary_size = res::embed::size("binary");
    if (binary_size != 5) {
        std::cerr << "Binary resource size mismatch: expected 5, got " << binary_size << std::endl;
        return 1;
    }
    
    // Check binary content
    unsigned char expected[] = {0x00, 0x01, 0x02, 0x03, 0xFF};
    for (size_t i = 0; i < 5; i++) {
        if ((unsigned char)binary[i] != expected[i]) {
            std::cerr << "Binary data mismatch at byte " << i << std::endl;
            return 1;
        }
    }
    
    std::cout << "All resource tests passed!" << std::endl;
    return 0;
}