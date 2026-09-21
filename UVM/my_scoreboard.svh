import "DPI-C" function void dpi_aes_encrypt_ecb(
        input  byte key[16],
        input  byte plaintext[16],
        output byte ciphertext[16]
    );
class my_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(my_scoreboard)
    
    int fd;
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

        // Convert bit vectors to byte arrays
        {>>{key_bytes}}   = t.cipher_key;
        {>>{plain_bytes}} = t.plain_text;

        dpi_aes_encrypt_ecb(key_bytes, plain_bytes, cipher_bytes);

        // Convert byte array back to bit vector
        {>>{exp_out}} = cipher_bytes;

        // COMPARE THE ACTUAL OUTPUT AND EXPECTED OUTPUT
        if(!t.reset) exp_out = 128'h0;
        if(exp_out == t.cipher_text)
            `uvm_info(get_name(), $sformatf("SUCCESS , OUT IS %h and EXP OUT IS %h ", t.cipher_text , exp_out), UVM_LOW )
        else 
            `uvm_error(get_name(), $sformatf("FAILURE , OUT IS %h and EXP OUT IS %h ", t.cipher_text , exp_out)) 
        

    endtask
endclass