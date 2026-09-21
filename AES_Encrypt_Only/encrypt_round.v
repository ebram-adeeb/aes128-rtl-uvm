`include "aes_params.vh"

module encrypt_round(

    input  wire [`STATE_WIDTH-1:0] state_in,
    input  wire [`STATE_WIDTH-1:0] round_key,
    output wire [`STATE_WIDTH-1:0] state_out

);

wire [`STATE_WIDTH-1:0] sub_state;
wire [`STATE_WIDTH-1:0] shift_state;
wire [`STATE_WIDTH-1:0] mix_state;

//-------------------------
// SubBytes
//-------------------------
subbytes u_subbytes (
    .i_state (state_in),
    .o_state (sub_state)
);

//-------------------------
// ShiftRows
//-------------------------
ShiftRows u_shiftrows (
    .state_in  (sub_state),
    .state_out (shift_state)
);

//-------------------------
// MixColumns
//-------------------------
col_mix u_colmix (
    .state_in  (shift_state),
    .state_out (mix_state)
);

//-------------------------
// AddRoundKey
//-------------------------
add_round_key u_addroundkey (
    .state_in  (mix_state),
    .round_key (round_key),
    .state_out (state_out)
);

endmodule