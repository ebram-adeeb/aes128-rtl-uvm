`include "aes_params.vh"
module key_expansion (
    input  [`KEY_BITS-1:0]key,
    output [4*(`NUM_ROUNDS+1)*32-1:0] w
);
    localparam NK = `KEY_BITS/32;
    //Assign Key0
    assign w[`KEY_BITS-1:0] = key;
    genvar i;
    generate begin : next_keys_gen
    //generate round keys
    for (i=1;i<`NUM_ROUNDS+1;i=i+1) begin
        next_key rnd (.r(i[3:0]),.in(w[i*`KEY_BITS-1 -:`KEY_BITS]), .out(w[(i+1)*`KEY_BITS-1 -:`KEY_BITS]));
    end
    end
    endgenerate
endmodule

module next_key(
    input  [3:0]r,
    input  [`KEY_BITS-1:0]in,
    output [`KEY_BITS-1:0]out
);
    localparam NK = `KEY_BITS/32;
    wire [31:0] rotword, subword, t_w;

    //[B0,B1,B2,B3] ==> [sbox(B1),sbox(B2),sbox(B3),sbox(B0)] 
    assign rotword = {in[23:00],in[31:24]};
    sbox sbox0 (.i_data(rotword[31:24]),.o_data(subword[31:24]));
    sbox sbox1 (.i_data(rotword[23:16]),.o_data(subword[23:16]));
    sbox sbox2 (.i_data(rotword[15:08]),.o_data(subword[15:08]));
    sbox sbox3 (.i_data(rotword[07:00]),.o_data(subword[07:00]));

    reg  [07:0] rcon;
    always @(*) begin
        case (r)
            4'd1: rcon = 8'h01; 
            4'd2: rcon = 8'h02; 
            4'd3: rcon = 8'h04; 
            4'd4: rcon = 8'h08; 
            4'd5: rcon = 8'h10;

            4'd6: rcon = 8'h20; 
            4'd7: rcon = 8'h40; 
            4'd8: rcon = 8'h80;  
            4'd9: rcon = 8'h1B;  
            4'd10: rcon = 8'h36;  

            default: rcon = 8'h00;
        endcase
    end

    //Wi = Wi-4 + T(W)
    assign t_w = subword ^ {rcon, 24'h000000};
    assign out[`KEY_BITS-1 -:32] = in[`KEY_BITS-1 -:32] ^ t_w;
    //Wi = Wi-4 + Wi-1
    genvar i;
    generate begin : word_gen
    for(i=NK-1;i>0;i=i-1) begin
        if(NK>6 && (NK-i)%NK==4) begin
            wire [31:0] subword_t;
            assign temp = out[32*(i+1)-1 -:32];
            sbox sbox0 (.i_data(temp[31:24]),.o_data(subword_t[31:24]));
            sbox sbox1 (.i_data(temp[23:16]),.o_data(subword_t[23:16]));
            sbox sbox2 (.i_data(temp[15:08]),.o_data(subword_t[15:08]));
            sbox sbox3 (.i_data(temp[07:00]),.o_data(subword_t[07:00]));
            assign out[32*(i)-1 -:32] = in[32*(i)-1 -:32] ^ subword_t;
        end else begin
            assign out[32*(i)-1 -:32] = in[32*(i)-1 -:32] ^ out[32*(i+1)-1 -:32];
        end
    end
    end
    endgenerate
endmodule


// Pipelined module, untested
module key_expansion_pipelined (
    input  clk,
    input  rst_n,
    input  [`KEY_BITS-1:0]key,
    output [4*(`NUM_ROUNDS+1)*32-1:0] w
);
    localparam NK = `KEY_BITS/32;
    reg [`KEY_BITS-1:0] w_pipe [0:`NUM_ROUNDS-1];   
    //Assign Key0
    assign w[`KEY_BITS-1:0] = key;
    
    genvar i;
    generate begin : next_key_gen
    //generate round keys
    wire [`KEY_BITS-1:0] next_key0;
    next_key rnd0 (.r(4'b0001),.in(w[`KEY_BITS-1:0]), .out(next_key0));
    always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                w_pipe[0] <= {`KEY_BITS{1'b0}};
            end else begin
                w_pipe[0] <= next_key0;
            end
    end
    assign w[`KEY_BITS +:`KEY_BITS] = w_pipe[0];
    for (i=1;i<`NUM_ROUNDS;i=i+1) begin
        wire [`KEY_BITS-1:0] next_key;
        next_key rnd (.r(i[3:0]+1'b1),.in(w_pipe[i-1]), .out(next_key));

        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                w_pipe[i] <= {`KEY_BITS{1'b0}};
            end else begin
                w_pipe[i] <= next_key;
            end
        end

        assign w[(i+1)*`KEY_BITS +:`KEY_BITS] = w_pipe[i];
    end
    end
    endgenerate
endmodule
