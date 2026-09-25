class aes_random_seq extends uvm_sequence #(my_sequence_item);
    `uvm_object_utils(aes_random_seq)
    
    function new(string name = "aes_random_seq");
        super.new(name);
    endfunction

    virtual task body();
        my_sequence_item seq_item;
        repeat (4096) begin
            seq_item = my_sequence_item::type_id::create("seq_item");
            start_item(seq_item); 
            
            if (!seq_item.randomize() with {
                reset == 1'b1;    
                valid_in == 1'b1; 
            }) begin
                `uvm_error(get_name(), "Randomization failed")
            end
            
            finish_item(seq_item); 
        end
    endtask
endclass

class aes_reset_seq extends uvm_sequence #(my_sequence_item);
    `uvm_object_utils(aes_reset_seq)
    
    function new(string name = "aes_reset_seq");
        super.new(name);
    endfunction

    virtual task body();
        my_sequence_item seq_item;
    
        seq_item = my_sequence_item::type_id::create("reset_seq");
        start_item(seq_item);
        if (!seq_item.randomize() with {
            reset      == 1'b0; 
        }) `uvm_error(get_name(), "Reset randomization failed")
        finish_item(seq_item);
    endtask
endclass

class aes_kat_seq extends uvm_sequence #(my_sequence_item);
    `uvm_object_utils(aes_kat_seq)
    
    function new(string name = "aes_kat_seq");
        super.new(name);
    endfunction

    virtual task body();
        my_sequence_item seq_item;
        
        // NIST FIPS 197 Appendix B (AES-128 Known Answer Test Vector)
        logic [127:0] nist_key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        logic [127:0] nist_pt  = 128'h3243f6a8885a308d313198a2e0370734;
        //  Cipher Text: 3925841d02dc09fbdc118597196a0b32
        
        
        seq_item = my_sequence_item::type_id::create("kat_item");
        start_item(seq_item);
        if (!seq_item.randomize() with {
            reset == 1'b1;
            valid_in == 1'b1;
            plain_text == nist_pt;
            cipher_key == nist_key;
        }) `uvm_error(get_name(), "KAT Randomization failed")
        finish_item(seq_item);
        
        seq_item = my_sequence_item::type_id::create("kat_item_zero");
        start_item(seq_item);
        if (!seq_item.randomize() with {
            reset == 1'b1;
            valid_in == 1'b1;
            plain_text == 128'h0;
            cipher_key == 128'h0;
        }) `uvm_error(get_name(), "KAT Zero Randomization failed")
        finish_item(seq_item);
    endtask
endclass

class aes_corner_case_seq extends uvm_sequence #(my_sequence_item);
    `uvm_object_utils(aes_corner_case_seq)
    
    function new(string name = "aes_corner_case_seq");
        super.new(name);
    endfunction

    virtual task body();
        my_sequence_item seq_item;
        logic [127:0] corner_cases[$];
        
        corner_cases.push_back(128'h0);
        corner_cases.push_back(128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        corner_cases.push_back(128'h55555555555555555555555555555555);
        corner_cases.push_back(128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA);
        corner_cases.push_back(128'hA5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5);
        corner_cases.push_back(128'h5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A);
        corner_cases.push_back(128'hAAAAAAAAAAAAAAAA5555555555555555);
        corner_cases.push_back(128'h5555555555555555AAAAAAAAAAAAAAAA);
        
        repeat (8) begin
            foreach(corner_cases[i]) begin
                seq_item = my_sequence_item::type_id::create("seq_item");
                start_item(seq_item);
                
                if (!seq_item.randomize() with {
                    reset      == 1'b1;
                    valid_in   == 1'b1;
                    plain_text == corner_cases[i];
                    cipher_key inside {128'h0, 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, 128'h55555555555555555555555555555555, 128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA};
                }) begin
                    `uvm_error(get_name(), "Corner case randomization failed")
                end
                finish_item(seq_item);
            end
        end
    endtask
endclass



class aes_master_seq extends uvm_sequence #(my_sequence_item);
    `uvm_object_utils(aes_master_seq)
    `uvm_declare_p_sequencer(my_virtual_sequencer)
    
    aes_reset_seq       reset_seq1;
    aes_reset_seq       reset_seq2;
    aes_reset_seq       reset_seq3;
    aes_corner_case_seq corner_seq;
    aes_random_seq      rand_seq;
    aes_kat_seq         kat_seq;

    function new(string name = "aes_master_seq");
        super.new(name);
    endfunction

    virtual task body();
        reset_seq1  = aes_reset_seq::type_id::create("reset_seq1");
        reset_seq2  = aes_reset_seq::type_id::create("reset_seq2");
        reset_seq3  = aes_reset_seq::type_id::create("reset_seq3");
        kat_seq    = aes_kat_seq::type_id::create("kat_seq");
        corner_seq = aes_corner_case_seq::type_id::create("corner_seq");
        rand_seq  = aes_random_seq::type_id::create("rand_seq");
        `uvm_info(get_name(), "Resetting...", UVM_LOW)
        reset_seq1.start(p_sequencer.seqr);

        `uvm_info(get_name(), "Starting NIST Known Answer Test (KAT)...", UVM_LOW)
        kat_seq.start(p_sequencer.seqr);

        `uvm_info(get_name(), "Resetting...", UVM_LOW)
        reset_seq2.start(p_sequencer.seqr);

        `uvm_info(get_name(), "Starting corner case sequence...", UVM_LOW)
        corner_seq.start(p_sequencer.seqr);

        `uvm_info(get_name(), "Resetting...", UVM_LOW)
        reset_seq3.start(p_sequencer.seqr);

        `uvm_info(get_name(), "Starting randomized Sequence...", UVM_LOW)
        rand_seq.start(p_sequencer.seqr);
        
        `uvm_info(get_name(), "Master Sequence Complete!", UVM_LOW)
    endtask
endclass