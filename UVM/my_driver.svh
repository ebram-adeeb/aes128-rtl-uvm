class my_driver extends uvm_driver #(my_sequence_item);
    `uvm_component_utils(my_driver)
    virtual interface intf_aes my_vif;
    my_sequence_item seq_item;
    function new(string name = "my_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        $display("Building my_driver...");
        super.build_phase(phase);
        seq_item = my_sequence_item::type_id::create("seq_item");
        if (!uvm_config_db#(virtual intf_aes)::get(this, "", "my_vif", my_vif)) begin
            `uvm_fatal(get_full_name(), "Could not find virtual interface in config_db")
        end
    endfunction

    virtual function void connect_phase (uvm_phase phase);
        $display("connecting my_driver...");
        super.connect_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            seq_item_port.get_next_item(seq_item);
            //drive the v_interface data
            @(my_vif.cb_drv);
            my_vif.cb_drv.reset       <= seq_item.reset;
            my_vif.cb_drv.valid_in    <= seq_item.valid_in;
            my_vif.cb_drv.plain_text  <= seq_item.plain_text;
            my_vif.cb_drv.cipher_key  <= seq_item.cipher_key;

            //report driven values
            `uvm_info(get_name(), $sformatf("DRIVEN TRANSACTION | reset: %0b | valid_in: %0b | plain_text: 0x%0h | key: 0x%0h", 
                      seq_item.reset, seq_item.valid_in, seq_item.plain_text, seq_item.cipher_key), UVM_HIGH)
            
            if (seq_item.reset === 1'b1 && seq_item.valid_in === 1'b1) begin
                @(my_vif.cb_drv);
                my_vif.cb_drv.valid_in <= 1'b0; 
                while (my_vif.cb_drv.valid_out !== 1'b1) begin
                    @(my_vif.cb_drv);
                end
            end
            seq_item_port.item_done();
        end
    endtask
endclass