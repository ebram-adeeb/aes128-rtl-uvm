#include <stdint.h>
#include "aes.h"

// DPI-C function called directly from SystemVerilog
void dpi_aes_encrypt_ecb(const uint8_t *key, const uint8_t *plaintext, uint8_t *ciphertext) {
    struct AES_ctx ctx;
    AES_init_ctx(&ctx, key);
    
    // Copy plaintext into output buffer and encrypt in-place
    for (int i = 0; i < 16; i++) {
        ciphertext[i] = plaintext[i];
    }
    
    AES_ECB_encrypt(&ctx, ciphertext);
}