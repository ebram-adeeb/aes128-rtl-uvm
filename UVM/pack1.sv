package pack1;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    //sequence item transaction (dynamic)
    `include "my_sequence_item.svh"
    //agent components level
    `include "my_driver.svh"
    `include "my_monitor.svh"
    `include "my_sequencer.svh"
    //environment components level
    `include "my_scoreboard.svh"
    `include "my_subscriber.svh"
    `include "my_agent.svh"
    //virtual sequencer and then sequences
    `include "my_virtual_sequencer.svh"
    `include "my_sequences.svh"
    //environment level
    `include "my_environment.svh"
    //top
    `include "my_test.svh"
endpackage
