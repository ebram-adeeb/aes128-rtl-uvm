`include "aes_params.vh"

module Encrypt_Top #(
    parameter KEY_BITS   = 128,
    parameter NUM_ROUNDS = 10
)(
    input  wire [`STATE_WIDTH-1:0] plaintext,
    input  wire [`STATE_WIDTH-1:0] key,

    output wire [`STATE_WIDTH-1:0] ciphertext
);


    //---------------------------------------------------------
    // Key Expansion
    //---------------------------------------------------------

    wire [4*(NUM_ROUNDS+1)*32-1:0] w;


    wire [`STATE_WIDTH-1:0] r_key [0:NUM_ROUNDS];


    wire [`STATE_WIDTH-1:0] state [0:NUM_ROUNDS];



    //---------------------------------------------------------
    // Key Expansion
    //---------------------------------------------------------

    key_expansion u_key_expansion (

        .key(key),
        .w(w)

    );



    //---------------------------------------------------------
    // Key Scheduler
    //---------------------------------------------------------

    genvar i;

    generate

        for (i = 0; i <= NUM_ROUNDS; i = i + 1) begin : gen_key_scheduler


            key_scheduler u_ks (

                .w(w),
                .round_idx(i[3:0]),
                .decrypt(1'b0),
                .round_key(r_key[i])

            );


        end

    endgenerate



    //---------------------------------------------------------
    // Initial Round (AddRoundKey K0)
    //---------------------------------------------------------

    add_round_key u_initial_round (

        .state_in  (plaintext),
        .round_key (r_key[0]),
        .state_out (state[0])

    );



    //---------------------------------------------------------
    // Encryption Rounds 1 -> 9
    //---------------------------------------------------------

    genvar r;

    generate

        for (r = 1; r < NUM_ROUNDS; r = r + 1) begin : gen_encrypt_rounds


            encrypt_round u_round (

                .state_in  (state[r-1]),
                .round_key (r_key[r]),
                .state_out (state[r])

            );


        end

    endgenerate



    //---------------------------------------------------------
    // Final Round (Round 10)
    // SubBytes + ShiftRows + AddRoundKey
    //---------------------------------------------------------

    encrypt_final_round u_final_round (

        .state_in  (state[NUM_ROUNDS-1]),
        .round_key (r_key[NUM_ROUNDS]),
        .state_out (state[NUM_ROUNDS])

    );



    //---------------------------------------------------------
    // Ciphertext Output
    //---------------------------------------------------------

    assign ciphertext = state[NUM_ROUNDS];


endmodule
