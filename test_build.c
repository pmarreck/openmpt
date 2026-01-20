// Simple test to verify libopenmpt builds and links correctly
#include <stdio.h>
#include <libopenmpt/libopenmpt.h>

int main(void) {
    // Get library version
    uint32_t version = openmpt_get_library_version();
    uint32_t major = (version >> 24) & 0xFF;
    uint32_t minor = (version >> 16) & 0xFF;
    uint32_t patch = (version >> 8) & 0xFF;
    
    printf("libopenmpt version: %u.%u.%u\n", major, minor, patch);
    
    // Get supported extensions
    const char* extensions = openmpt_get_supported_extensions();
    if (extensions) {
        printf("Supported extensions: %s\n", extensions);
        openmpt_free_string(extensions);
    }
    
    printf("libopenmpt build test PASSED!\n");
    return 0;
}
