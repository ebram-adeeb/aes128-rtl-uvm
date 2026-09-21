`include "aes_params.vh"

module add_vector (
    input  wire [`STATE_WIDTH-1:0] plaintext,
    input  wire [`STATE_WIDTH-1:0] vector,
    output wire [`STATE_WIDTH-1:0] state_out
);

assign state_out = plaintext ^ vector;

endmodule
