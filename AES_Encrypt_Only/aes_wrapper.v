module aes_wrapper (
    input  wire         clk,
    input  wire         reset,       // Active low
    input  wire         valid_in,
    input  wire [127:0] plain_text,
    input  wire [127:0] cipher_key,
    output reg  [127:0] cipher_text,
    output reg          valid_out
);

  reg  valid_d;
  reg  [127:0] text_reg;
  reg  [127:0] key_reg;
  wire [127:0] core_cipher_out;

  Encrypt_Top u_aes_core (
      .plaintext(text_reg),
      .key(key_reg),
      .ciphertext(core_cipher_out)
  );

  always @(posedge clk or negedge reset) begin
    if (!reset) begin
      text_reg    <= 128'b0;
      key_reg     <= 128'b0;
      cipher_text <= 128'b0;
      valid_d     <= 1'b0;
      valid_out   <= 1'b0;
    end else begin
      if (valid_in) begin
        text_reg   <= plain_text;
        key_reg    <= cipher_key; 
      end 
      valid_d    <= valid_in;
      valid_out  <= valid_d;
      if (valid_d) cipher_text <= core_cipher_out;
    end
  end

endmodule