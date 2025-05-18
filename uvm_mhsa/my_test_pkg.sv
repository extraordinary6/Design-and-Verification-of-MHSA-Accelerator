//=====================================================================
// Description:
// my test package
// Designer : Huang Chaofan, extraordinary.h@sjtu.edu.cn
// Revision History:
// V0 date: 4.6 Initial version, Huang Chaofan
// ====================================================================

package my_test_pkg;
  parameter NUM_ENV = 3;

  import uvm_pkg::*;
  import my_sequence_pkg::*;
  import my_agent_pkg::*;
  import my_env_pkg::*;

  class my_vsequencer extends uvm_sequencer;          

    `uvm_component_utils(my_vsequencer)

    my_sequencer p_my_sequencer[NUM_ENV];             

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

  endclass : my_vsequencer

  class my_test extends uvm_test;

    `uvm_component_utils(my_test)

    string report_id = get_type_name();
    int i;

    my_env_config my_env_config_h[NUM_ENV];
    my_env my_env_h[NUM_ENV];                         
    my_vsequencer my_vsequencer_h;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);

      for(i = 0; i < NUM_ENV; i++) begin
        my_env_config_h[i] = new();
      end

      for(i = 0; i < NUM_ENV; i++) begin                      
        if(!uvm_config_db #(virtual dut_if)::get(this, "", $sformatf("dut_vif_i%1d", i), my_env_config_h[i].dut_vif_i))
          `uvm_fatal("NO_VIF", $sformatf("Virtual interface dut_vif_i%1d was not set!", i))
        if(!uvm_config_db #(virtual dut_if)::get(this, "", $sformatf("dut_vif_o%1d", i), my_env_config_h[i].dut_vif_o))
          `uvm_fatal("NO_VIF", $sformatf("Virtual interface dut_vif_o%1d was not set!", i))
      end

      for(i = 0; i < NUM_ENV; i++) begin                    
        uvm_config_db #(my_env_config)::set(this, $sformatf("my_env_h[%1d]", i), "env_config", my_env_config_h[i]);
      end

      `uvm_info(report_id, "ENV_CFG(s) set into config_db", UVM_LOW);

      for(i = 0; i < NUM_ENV; i++) begin
        my_env_h[i] = my_env::type_id::create($sformatf("my_env_h[%1d]", i), this);
      end

      my_vsequencer_h = my_vsequencer::type_id::create("my_vsequencer_h", this);

    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
      // Connect the sequencer to the agents
      for(i = 0; i < NUM_ENV; i++) begin
        my_vsequencer_h.p_my_sequencer[i] = my_env_h[i].my_agent_i_h.my_sequencer_h;     
      end

      uvm_top.print_topology();
    endfunction : connect_phase	

    function void report_phase(uvm_phase phase);
      uvm_report_server report_server_h;
      int               num_err;
      int               num_fatal;

      report_server_h = uvm_report_server::get_server();
      num_err         = report_server_h.get_severity_count(UVM_ERROR);
      num_fatal       = report_server_h.get_severity_count(UVM_FATAL);

      //Final result
      if(num_err==0 && num_fatal==0) begin
        $display("###########################################");
        $display("############    TEST PASSED    ############");
        $display("###########################################");
      end else begin
        $display("###########################################");
        $display("############    TEST FAILED    ############");
        $display("###########################################");
      end
    endfunction : report_phase
  endclass : my_test

  // define test here
  class test0 extends my_test;
    `uvm_component_utils(test0)

    string report_id = get_type_name();

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
      
      fork
        // my_env_h[0]: random sequence
        begin
          mem_rand_write_seq seq0;
          compute_start_seq seq1;
          mem_read_seq seq2;
          seq0 = mem_rand_write_seq::type_id::create("seq0", this);
          seq1 = compute_start_seq::type_id::create("seq1", this);
          seq2 = mem_read_seq::type_id::create("seq2", this);

          phase.phase_done.set_drain_time(this, 1000);
          phase.raise_objection(this);

          wait(my_env_h[0].env_config.dut_vif_i.rst_n == 1);

          seq0.start(my_vsequencer_h.p_my_sequencer[0]);

          seq1.start(my_vsequencer_h.p_my_sequencer[0]);

          wait(my_env_h[0].env_config.dut_vif_o.done == 1);

          `uvm_info(report_id, "acc compute finished!", UVM_LOW);

          seq2.start(my_vsequencer_h.p_my_sequencer[0]);

          # 100000;

          phase.drop_objection(this);
        end

        // my_env_h[1]: incremental sequence
        begin
          mem_inc_write_seq seq0;
          compute_start_seq seq1;
          mem_read_seq seq2;
          seq0 = mem_inc_write_seq::type_id::create("seq0", this);
          seq1 = compute_start_seq::type_id::create("seq1", this);
          seq2 = mem_read_seq::type_id::create("seq2", this);

          phase.phase_done.set_drain_time(this, 1000);
          phase.raise_objection(this);

          wait(my_env_h[1].env_config.dut_vif_i.rst_n == 1);

          seq0.start(my_vsequencer_h.p_my_sequencer[1]);
          seq1.start(my_vsequencer_h.p_my_sequencer[1]);

          wait(my_env_h[1].env_config.dut_vif_o.done == 1);

          `uvm_info(report_id, "acc compute finished!", UVM_LOW);

          seq2.start(my_vsequencer_h.p_my_sequencer[1]);

          # 100000;

          phase.drop_objection(this);

        end

        // my_env_h[2]: all one sequence
        begin
          mem_allone_write_seq seq0;
          compute_start_seq seq1;
          mem_read_seq seq2;
          seq0 = mem_allone_write_seq::type_id::create("seq0", this);
          seq1 = compute_start_seq::type_id::create("seq1", this);
          seq2 = mem_read_seq::type_id::create("seq2", this);

          phase.phase_done.set_drain_time(this, 1000);
          phase.raise_objection(this);

          wait(my_env_h[2].env_config.dut_vif_i.rst_n == 1);

          seq0.start(my_vsequencer_h.p_my_sequencer[2]);
          seq1.start(my_vsequencer_h.p_my_sequencer[2]);

          wait(my_env_h[2].env_config.dut_vif_o.done == 1);

          `uvm_info(report_id, "acc compute finished!", UVM_LOW);

          seq2.start(my_vsequencer_h.p_my_sequencer[2]);

          # 100000;

          phase.drop_objection(this);
          
        end
      join

    endtask : run_phase
  
  endclass : test0

  
endpackage : my_test_pkg
