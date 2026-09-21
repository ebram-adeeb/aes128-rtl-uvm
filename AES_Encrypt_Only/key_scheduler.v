`include "aes_params.vh"
module key_scheduler(
    input  wire [4*(`NUM_ROUNDS+1)*32-1:0] w,
    input  wire [3:0]                     round_idx,
    input  wire                           decrypt,
    output wire [`STATE_WIDTH-1:0]        round_key
);

    wire [3:0] actual_round = decrypt ? (`NUM_ROUNDS - round_idx) : round_idx;
    
    assign round_key = w[actual_round * `STATE_WIDTH +: `STATE_WIDTH];

endmodule
