class my_subscriber extends uvm_subscriber #(my_sequence_item);  
    `uvm_component_utils(my_subscriber)
    my_sequence_item seq_item;
    uvm_analysis_imp #(my_sequence_item, my_subscriber) my_analysis_imp;

    covergroup cg_aes128_coverage with function sample(my_sequence_item t);
        option.per_instance = 1;
        option.name         = "cg_aes_coverage";

        cp_plain_text_0:  coverpoint t.plain_text[7:0]     { bins b[] = {[0:255]}; } 
        cp_plain_text_1:  coverpoint t.plain_text[15:8]    { bins b[] = {[0:255]}; }
        cp_plain_text_2:  coverpoint t.plain_text[23:16]   { bins b[] = {[0:255]}; }
        cp_plain_text_3:  coverpoint t.plain_text[31:24]   { bins b[] = {[0:255]}; }
        cp_plain_text_4:  coverpoint t.plain_text[39:32]   { bins b[] = {[0:255]}; }
        cp_plain_text_5:  coverpoint t.plain_text[47:40]   { bins b[] = {[0:255]}; }
        cp_plain_text_6:  coverpoint t.plain_text[55:48]   { bins b[] = {[0:255]}; }
        cp_plain_text_7:  coverpoint t.plain_text[63:56]   { bins b[] = {[0:255]}; }
        cp_plain_text_8:  coverpoint t.plain_text[71:64]   { bins b[] = {[0:255]}; }
        cp_plain_text_9:  coverpoint t.plain_text[79:72]   { bins b[] = {[0:255]}; }
        cp_plain_text_10: coverpoint t.plain_text[87:80]   { bins b[] = {[0:255]}; }
        cp_plain_text_11: coverpoint t.plain_text[95:88]   { bins b[] = {[0:255]}; }
        cp_plain_text_12: coverpoint t.plain_text[103:96]  { bins b[] = {[0:255]}; }
        cp_plain_text_13: coverpoint t.plain_text[111:104] { bins b[] = {[0:255]}; }
        cp_plain_text_14: coverpoint t.plain_text[119:112] { bins b[] = {[0:255]}; }
        cp_plain_text_15: coverpoint t.plain_text[127:120] { bins b[] = {[0:255]}; }


        cp_key_0:  coverpoint t.cipher_key[7:0]     { bins b[] = {[0:255]}; }
        cp_key_1:  coverpoint t.cipher_key[15:8]    { bins b[] = {[0:255]}; }
        cp_key_2:  coverpoint t.cipher_key[23:16]   { bins b[] = {[0:255]}; }
        cp_key_3:  coverpoint t.cipher_key[31:24]   { bins b[] = {[0:255]}; }
        cp_key_4:  coverpoint t.cipher_key[39:32]   { bins b[] = {[0:255]}; }
        cp_key_5:  coverpoint t.cipher_key[47:40]   { bins b[] = {[0:255]}; }
        cp_key_6:  coverpoint t.cipher_key[55:48]   { bins b[] = {[0:255]}; }
        cp_key_7:  coverpoint t.cipher_key[63:56]   { bins b[] = {[0:255]}; }
        cp_key_8:  coverpoint t.cipher_key[71:64]   { bins b[] = {[0:255]}; }
        cp_key_9:  coverpoint t.cipher_key[79:72]   { bins b[] = {[0:255]}; }
        cp_key_10: coverpoint t.cipher_key[87:80]   { bins b[] = {[0:255]}; }
        cp_key_11: coverpoint t.cipher_key[95:88]   { bins b[] = {[0:255]}; }
        cp_key_12: coverpoint t.cipher_key[103:96]  { bins b[] = {[0:255]}; }
        cp_key_13: coverpoint t.cipher_key[111:104] { bins b[] = {[0:255]}; }
        cp_key_14: coverpoint t.cipher_key[119:112] { bins b[] = {[0:255]}; }
        cp_key_15: coverpoint t.cipher_key[127:120] { bins b[] = {[0:255]}; }

        cp_valid_in : coverpoint t.valid_in  { bins v[] = {0, 1}; }
        cp_valid_out: coverpoint t.valid_out { bins v[] = {0, 1}; }

        cp_reset: coverpoint t.reset { 
            bins tr_low_high = (0 => 1); 
            bins tr_high_low = (1 => 0); 
        }        
    endgroup

    function new(string name = "my_subscriber", uvm_component parent = null);
        super.new(name, parent);
        cg_aes128_coverage = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        $display("Building my_subscriber...");
        super.build_phase(phase);
        my_analysis_imp = new("my_analysis_imp", this);
    endfunction

    virtual function void connect_phase (uvm_phase phase);
        $display("connecting my_subscriber...");
        super.connect_phase(phase);
    endfunction

    virtual function void write(my_sequence_item t);
        cg_aes128_coverage.sample(t);
    endfunction

endclass