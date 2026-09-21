`include "aes_params.vh"

module encrypt_final_round
#(
    parameter STATE_WIDTH = 128
)
(
    input  wire [STATE_WIDTH-1:0] state_in,
    input  wire [STATE_WIDTH-1:0] round_key,
    output wire [STATE_WIDTH-1:0] state_out
);


    wire [STATE_WIDTH-1:0] sub_bytes_out;
    wire [STATE_WIDTH-1:0] shift_rows_out;



    //==================================================
    // SubBytes
    //==================================================

    subbytes #(
        .STATE_WIDTH(STATE_WIDTH)

    ) u_subbytes (

        .i_state(state_in),
        .o_state(sub_bytes_out)

    );



    //==================================================
    // ShiftRows
    //==================================================

    ShiftRows #(
        .STATE_WIDTH(STATE_WIDTH)

    ) u_shift_rows (

        .state_in(sub_bytes_out),
        .state_out(shift_rows_out)

    );



    //==================================================
    // AddRoundKey
    //==================================================

    add_round_key u_add_round_key (

        .state_in(shift_rows_out),
        .round_key(round_key),
        .state_out(state_out)

    );


endmodule
