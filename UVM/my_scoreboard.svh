import "DPI-C" function void dpi_aes_encrypt_ecb(
        input  byte key[16],
        input  byte plaintext[16],
        output byte ciphertext[16]
    );
class my_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(my_scoreboard)

    int unsigned n_checked = 0;
    int unsigned n_passed  = 0;
    int unsigned n_failed  = 0;

    logic [127:0] exp_out;
    byte key_bytes[16];
    byte plain_bytes[16];
    byte cipher_bytes[16];
    uvm_analysis_imp #(my_sequence_item, my_scoreboard) my_analysis_imp;
    
    function new(string name = "my_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        my_analysis_imp = new("my_analysis_imp", this);
    endfunction

    virtual function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    task write (my_sequence_item t);

        if(t.reset === 1'b1 && t.valid_in === 1'b1) begin
            // Convert bit vectors to byte arrays
            {>>{key_bytes}}   = t.cipher_key;
            {>>{plain_bytes}} = t.plain_text;

            dpi_aes_encrypt_ecb(key_bytes, plain_bytes, cipher_bytes);

            // Convert byte array back to bit vector
            {>>{exp_out}} = cipher_bytes;
        end else exp_out = 128'h0;

        // COMPARE THE ACTUAL OUTPUT AND EXPECTED OUTPUT
        n_checked++;
        if (exp_out == t.cipher_text) begin
            n_passed++;
            `uvm_info(get_name(),
                    $sformatf("SUCCESS, OUT=%h EXP_OUT=%h", t.cipher_text, exp_out), UVM_LOW)
        end else begin
            n_failed++;
            `uvm_error(get_name(),
                    $sformatf("FAILURE, OUT=%h EXP_OUT=%h", t.cipher_text, exp_out))
        end
    endtask

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_name(),
                  $sformatf("SCOREBOARD SUMMARY: checked=%0d passed=%0d failed=%0d",
                            n_checked, n_passed, n_failed), UVM_LOW)
        if (n_checked == 0)
            `uvm_warning(get_type_name(), "No transactions were checked!")
    endfunction
endclass