//==============================================================================
// Module Name : subbytes
// Description :
//   Performs the AES SubBytes transformation.
//
// Functionality:
//   - Receives the 128-bit AES state.
//   - Splits the state into sixteen 8-bit bytes.
//   - Applies the AES S-Box substitution to each byte in parallel.
//   - Combines the substituted bytes into a new 128-bit output state.
//
// Inputs:
//   - i_state : 128-bit input AES state.
//
// Outputs:
//   - o_state : 128-bit state after SubBytes transformation.
//
// Notes:
//   - Pure combinational logic.
//   - Instantiates sixteen S-Box modules.
//   - One S-Box processes each byte independently.
//   - Fully compliant with the AES SubBytes transformation.
//==============================================================================

module subbytes #(
    parameter STATE_WIDTH = 128,  // Width of the AES state
    parameter BYTE_WIDTH  = 8     // Width of each byte in the state
) (
    input  wire [STATE_WIDTH-1:0] i_state,  // 128-bit input AES state
    output wire [STATE_WIDTH-1:0] o_state   // 128-bit output AES state after SubBytes
);

localparam NUM_BYTES = STATE_WIDTH / BYTE_WIDTH;

genvar i;

generate
    for (i = 0; i < NUM_BYTES; i = i + 1) begin : gen_sbox
        sbox u_sbox (
            .i_data(
                i_state[STATE_WIDTH-1 - i*BYTE_WIDTH -: BYTE_WIDTH]
            ),
            .o_data(
                o_state[STATE_WIDTH-1 - i*BYTE_WIDTH -: BYTE_WIDTH]
            )
        );
    end
endgenerate

endmodule