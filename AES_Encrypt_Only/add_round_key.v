`include "aes_params.vh"

module add_round_key (
    input  wire [`STATE_WIDTH-1:0] state_in,   
    input  wire [`STATE_WIDTH-1:0] round_key,  // round key for this round (128 bits)
    output wire [`STATE_WIDTH-1:0] state_out   // resulting state after XOR
);

    // AddRoundKey is a pure bitwise XOR between the state and the round key.
    assign state_out = state_in ^ round_key;

endmodule