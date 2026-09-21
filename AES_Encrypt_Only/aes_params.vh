// aes_params.vh - Include this file in all modules
`define AES_KEY_SIZE_128 1
// `define AES_KEY_SIZE_192 2
// `define AES_KEY_SIZE_256 3

`ifdef AES_KEY_SIZE_128
    `define KEY_BITS 128
    `define NUM_ROUNDS 10
`elsif AES_KEY_SIZE_192
    `define KEY_BITS 192
    `define NUM_ROUNDS 12
`else
    `define KEY_BITS 256
    `define NUM_ROUNDS 14
`endif

`define STATE_WIDTH 128  // Always 128-bit for AES
`define DATA_WIDTH 128    // Configurable: 8, 16, 32, 64, 128