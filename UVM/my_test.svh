class my_test extends uvm_test;
    `uvm_component_utils(my_test)
    virtual interface intf_aes my_vif;
    my_environment env;
    function new(string name = "my_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        $display("Building my_test...");
        super.build_phase(phase);
        
        env = my_environment::type_id::create("env", this);

        if (!uvm_config_db#(virtual intf_aes)::get(this, "", "my_vif", my_vif)) begin
            `uvm_fatal(get_full_name(), "Could not find virtual interface in config_db")
        end
        uvm_config_db#(virtual interface intf_aes)::set(this, "env", "my_vif" , my_vif);
    endfunction

    virtual function void connect_phase (uvm_phase phase);
        $display("connecting my_test...");
        super.connect_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        aes_master_seq master_seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        master_seq = aes_master_seq::type_id::create("master_seq");
        `uvm_info(get_name(), "Starting AES Master Sequence from Test...", UVM_LOW)

        master_seq.start(env.v_seqr);

        phase.drop_objection(this);
    endtask
endclass