//=====================================================================
// Description:
// my environment package
// Designer : Huang Chaofan, extraordinary.h@sjtu.edu.cn
// Revision History:
// V0 date: 4.6 Initial version, Huang Chaofan
// V1 date: 4.28 Add my_subscriber_o, Huang Chaofan
// V2 date: 5.9 Add behavior model of my_model, Zhang bowen
// ====================================================================

package my_env_pkg;

  import uvm_pkg::*;
  import my_sequence_pkg::*;
  import my_agent_pkg::*;

  class my_env_config extends uvm_object;
    virtual dut_if dut_vif_i;
    virtual dut_if dut_vif_o;
  endclass : my_env_config
  
  class my_subscriber_i extends uvm_subscriber #(my_transaction);
    `uvm_component_utils(my_subscriber_i)

    string report_id = get_type_name();
    
    logic              done;
    logic              start;
    logic [31:0]       input_base;
    logic [31:0]       output_base;
    logic              soc_write_en;
    logic [63:0]       soc_data_in;
    logic [31:0]       soc_addr;
    logic [63:0]       soc_data_out;

    covergroup cover_if_i;
      option.per_instance = 1;
      option.name = {get_full_name(), ".cover_if_i"};
    
      //coverpoint defined here
      cov_soc_write_en : coverpoint soc_write_en {
        bins soc_write_en_0 = {0};
        bins soc_write_en_1 = {1};
      }

      cov_start : coverpoint start {
        bins start_0 = {0};
        bins start_1 = {1};
      }

      cov_soc_data_in : coverpoint soc_data_in {
        bins all_zero = {64'b0};
        bins all_one  = {64'hFFFF_FFFF_FFFF_FFFF};
        bins inc_seq  = {[64'h1 : 64'h10]};
        bins random[] = default;
      }

      cov_soc_addr : coverpoint soc_addr {
        bins bar0 = {[32'h0000_0000 : 32'h0000_0FFF]}; // O, X
        bins bar1 = {[32'h0000_1000 : 32'h0000_1FFF]}; // Q
        bins bar2 = {[32'h0000_2000 : 32'h0000_2FFF]}; // K
        bins bar3 = {[32'h0000_3000 : 32'h0000_3FFF]}; // V
      }

    endgroup : cover_if_i

    function new(string name, uvm_component parent);
      super.new(name, parent);
      cover_if_i = new();
    endfunction : new

    function void write(my_transaction t);
      `uvm_info(report_id, "Get a transaction from AP", UVM_HIGH);
      //t.print();
      done            = t.done;                  
      start           = t.start;
      input_base      = t.input_base;
      output_base     = t.output_base;
      soc_write_en    = t.soc_write_en;
      soc_data_in     = t.soc_data_in;
      soc_addr        = t.soc_addr;
      soc_data_out    = t.soc_data_out;
      cover_if_i.sample();
    endfunction : write  

  endclass : my_subscriber_i


  class my_subscriber_o extends uvm_subscriber #(my_transaction);
    `uvm_component_utils(my_subscriber_o)

    string report_id = get_type_name();
    
    logic              done;
    logic              start;
    logic [31:0]       input_base;
    logic [31:0]       output_base;
    logic              soc_write_en;
    logic [63:0]       soc_data_in;
    logic [31:0]       soc_addr;
    logic [63:0]       soc_data_out;

    covergroup cover_if_o;
      option.per_instance = 1;
      option.name = {get_full_name(), ".cover_if_o"};
    
      //coverpoint defined here
      cov_done : coverpoint done {
        bins done_0 = {0};
        bins done_1 = {1};
      }
    
    endgroup : cover_if_o

    function new(string name, uvm_component parent);
      super.new(name, parent);
      cover_if_o = new();
    endfunction : new

    function void write(my_transaction t);
      `uvm_info(report_id, "Get a transaction from AP", UVM_HIGH);
      //t.print();
      done            = t.done;                  
      start           = t.start;
      input_base      = t.input_base;
      output_base     = t.output_base;
      soc_write_en    = t.soc_write_en;
      soc_data_in     = t.soc_data_in;
      soc_addr        = t.soc_addr;
      soc_data_out    = t.soc_data_out;
      cover_if_o.sample();
    endfunction : write

  endclass : my_subscriber_o

  class my_model extends uvm_component;
    `uvm_component_utils(my_model)

    uvm_blocking_get_port #(my_transaction) bgp;
    uvm_analysis_port #(my_transaction) ap;

    string report_id = get_type_name();

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
      bgp = new("bgp", this);
      ap  = new("ap", this);
    endfunction : build_phase

    function void store_input_data(
      my_transaction tx_model_i,
      int transaction_count,
      ref logic [7:0] X[32][128],
      ref logic [7:0] Wq[128][128],
      ref logic [7:0] Wk[128][128],
      ref logic [7:0] Wv[128][128],
      ref logic [7:0] Wo[128][128]
    );
      logic [63:0] data_in = tx_model_i.soc_data_in;

      if (transaction_count < 512) begin
        // Store X data
        for (int i = 0; i < 8; i++) begin
          X[i + (transaction_count % 4) * 8][transaction_count / 4] = data_in[63 - i * 8 -: 8];
        end
      end else if (transaction_count < 512 + 2048) begin
        // Store Wq data
        for (int i = 0; i < 8; i++) begin
          Wq[(transaction_count - 512) / 16][i + ((transaction_count - 512) % 16) * 8] = data_in[63 - i * 8 -: 8];
        end
      end else if (transaction_count < 512 + 2048 * 2) begin
        // Store Wk data
        for (int i = 0; i < 8; i++) begin
          Wk[(transaction_count - 512 - 2048) / 16][i + ((transaction_count - 512 - 2048) % 16) * 8] = data_in[63 - i * 8 -: 8];
        end
      end else if (transaction_count < 512 + 2048 * 3) begin
        // Store Wv data
        for (int i = 0; i < 8; i++) begin
          Wv[(transaction_count - 512 - 2048 * 2) / 16][i + ((transaction_count - 512 - 2048 * 2) % 16) * 8] = data_in[63 - i * 8 -: 8];
        end
      end else if (transaction_count < 512 + 2048 * 4) begin
        // Store Wo data
        for (int i = 0; i < 8; i++) begin
          Wo[(transaction_count - 512 - 2048 * 3) / 16][i + ((transaction_count - 512 - 2048 * 3) % 16) * 8] = data_in[63 - i * 8 -: 8];
        end
      end else begin
        `uvm_fatal("ERROR", "Transaction count exceeds expected range");
      end
    endfunction : store_input_data

    function void perform_mhsa_calculation(
      logic [7:0] X[32][128],
      logic [7:0] Wq[128][128],
      logic [7:0] Wk[128][128],
      logic [7:0] Wv[128][128],
      logic [7:0] Wo[128][128],
      ref logic [7:0] result[32][128]
    );
      logic [7:0] Q[32][128];
      logic [7:0] K[32][128];
      logic [7:0] V[32][128];
      logic [7:0] O[32][128];
      logic [7:0] O_head[4][32][32];

      // linear
      for (int i = 0; i < 32; i++) begin
        for (int j = 0; j < 128; j++) begin
          for (int k = 0; k < 128; k++) begin
            Q[i][j] += X[i][k] * Wq[k][j];
            K[i][j] += X[i][k] * Wk[k][j];
            V[i][j] += X[i][k] * Wv[k][j];
          end
        end
      end

      // qkmm
      for (int h = 0; h < 4; h++) begin
        logic [7:0] Q_head[32][32];
        logic [7:0] K_head[32][32];
        logic [7:0] V_head[32][32];
        logic [7:0] QK_head[32][32];

        for (int i = 0; i < 32; i++) begin
          for (int j = 0; j < 32; j++) begin
            Q_head[i][j] = Q[i][j + h * 32];
            K_head[i][j] = K[i][j + h * 32];
            V_head[i][j] = V[i][j + h * 32];
          end
        end

        for (int i = 0; i < 32; i++) begin
          for (int j = 0; j < 32; j++) begin
            for (int k = 0; k < 32; k++) begin
              QK_head[i][j] += Q_head[i][k] * K_head[j][k];
            end
            // softmax
            QK_head[i][j] = (QK_head[i][j] >> 1) + (QK_head[i][j] >> 3) + 
                            (QK_head[i][j] >> 4) + (QK_head[i][j] >> 6);
          end
        end

        // attmm
        for (int i = 0; i < 32; i++) begin
          for (int j = 0; j < 32; j++) begin
            for (int k = 0; k < 32; k++) begin
              O_head[h][i][j] += QK_head[i][k] * V_head[j][k]; //QK * V.T
            end
          end
        end

        for (int i = 0; i < 32; i++) begin
          for (int j = 0; j < 32; j++) begin     
            O[i][j + h * 32] = O_head[h][i][j];
          end
        end
      end

      // connect
      for (int i = 0; i < 32; i++) begin
        for (int j = 0; j < 128; j++) begin
          for (int k = 0; k < 128; k++) begin
            result[i][j] += O[i][k] * Wo[k][j];
          end
        end
      end
    endfunction : perform_mhsa_calculation

    function void write_output_data(
      logic [7:0] result[32][128],
      my_transaction tx_model_o,
      ref uvm_analysis_port #(my_transaction) ap
    );
      logic [63:0] data_out;
      my_transaction tx;

      for (int j = 0; j < 128; j++) begin
        for (int i = 0; i < 4; i++) begin
          for (int k = 0; k < 8; k++) begin
            data_out[(63 - k * 8) -: 8] = result[k + i * 8][j];
          end
          tx = my_transaction::type_id::create("tx");
          tx.copy(tx_model_o);
          tx.soc_data_out = data_out;
          ap.write(tx);
        end
      end
      
    endfunction : write_output_data

    task run_phase(uvm_phase phase);

      my_transaction tx_model_i;
      my_transaction tx_model_o;

      int transaction_count = 0;
      logic [7:0] X[32][128];
      logic [7:0] Wq[128][128];
      logic [7:0] Wk[128][128];
      logic [7:0] Wv[128][128];
      logic [7:0] Wo[128][128];
      logic [7:0] result[32][128];

      forever begin
        // Modeling DUT behavior
        bgp.get(tx_model_i);
        // $display("model get data in : %h", tx_model_i.soc_data_in);
        tx_model_o = my_transaction::type_id::create("tx_model_o");
        tx_model_o.copy(tx_model_i);

        if (transaction_count < 512 + 2048 * 4) 
        begin
          store_input_data(tx_model_i, transaction_count, X, Wq, Wk, Wv, Wo);
          transaction_count++;
        end 
        
        if (transaction_count == 512 + 2048 * 4) 
        begin
          perform_mhsa_calculation(X, Wq, Wk, Wv, Wo, result);
          write_output_data(result, tx_model_o, ap);
          `uvm_info(report_id, "MHSA calculation completed", UVM_LOW);
          transaction_count = 0;
        end

      end
    endtask : run_phase

  endclass : my_model

  class my_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(my_scoreboard)

    string report_id = get_type_name();

    my_transaction exp_queue[$];
    uvm_blocking_get_port #(my_transaction) exp_bgp;
    uvm_blocking_get_port #(my_transaction) act_bgp;

    int total_num;
    int wrong_num;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
      exp_bgp = new("exp_bgp", this);
      act_bgp = new("act_bgp", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
      // compare defined here
      my_transaction exp_tx, act_tx, tmp_tx;
      total_num = 0;
      wrong_num = 0;

      fork
        forever begin
          exp_bgp.get(exp_tx);
          exp_queue.push_back(exp_tx);
        end

        forever begin
          if(total_num == 512) begin
            if(wrong_num == 0) begin
              `uvm_info(report_id, "Check Passed!", UVM_LOW);
              `uvm_info(report_id, $sformatf("Total number of transactions: %0d", total_num), UVM_LOW);
              `uvm_info(report_id, $sformatf("Number of wrong transactions: %0d", wrong_num), UVM_LOW);
              break;
            end
            else begin
              `uvm_error(report_id, "Check Failed!");
              `uvm_info(report_id, $sformatf("Total number of transactions: %0d", total_num), UVM_LOW);
              `uvm_info(report_id, $sformatf("Number of wrong transactions: %0d", wrong_num), UVM_LOW);
              break;
            end
          end
          else begin
            act_bgp.get(act_tx);
            total_num = total_num + 1;

            if(exp_queue.size() > 0) begin
              tmp_tx = exp_queue.pop_front();
              if(tmp_tx.soc_data_out == act_tx.soc_data_out) begin
                continue;
              end
              else begin
                $display("expect: %h, but actual: %h", tmp_tx.soc_data_out, act_tx.soc_data_out);
                wrong_num = wrong_num + 1;
              end
            end
            else begin
              `uvm_error(report_id, "Received a transaction from DUT output, but expect queue is empty!");
              `uvm_info(report_id, $sformatf("Unexpected soc_data_out is: %0d", act_tx.soc_data_out), UVM_LOW);
            end
          end
        end

      join
    endtask : run_phase

  endclass: my_scoreboard

  class my_env extends uvm_env;
    `uvm_component_utils(my_env)

    string report_id = get_type_name();

    my_env_config env_config;
    
    my_agent_config i_agt_cfg;
    my_agent_config o_agt_cfg;

    my_agent my_agent_i_h;
    my_agent my_agent_o_h;
    my_subscriber_i my_subscriber_i_h;
    my_subscriber_o my_subscriber_o_h;
    my_model my_model_h;
    my_scoreboard my_scoreboard_h;

    uvm_tlm_analysis_fifo #(my_transaction) i_agt_mdl_fifo;
    uvm_tlm_analysis_fifo #(my_transaction) o_agt_scb_fifo;
    uvm_tlm_analysis_fifo #(my_transaction) mdl_scb_fifo;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
      i_agt_cfg = new();
      o_agt_cfg = new();

      if(!uvm_config_db #(my_env_config)::get(this, "", "env_config", env_config))                
        `uvm_fatal("NO_ENV_CFG", "Class env_config was not set!")
      i_agt_cfg.dut_vif = env_config.dut_vif_i;
      o_agt_cfg.dut_vif = env_config.dut_vif_o;
      uvm_config_db #(my_agent_config)::set(this, "my_agent_i_h.*", "agent_config", i_agt_cfg);
      uvm_config_db #(my_agent_config)::set(this, "my_agent_o_h.*", "agent_config", o_agt_cfg);
      `uvm_info(report_id, "AGENT_CFG(s) set into config_db", UVM_LOW);

      my_agent_i_h      = my_agent     ::type_id::create("my_agent_i_h", this);
      my_agent_o_h      = my_agent     ::type_id::create("my_agent_o_h", this);
      my_agent_i_h.is_active = UVM_ACTIVE;
      my_agent_o_h.is_active = UVM_PASSIVE;
      my_subscriber_i_h = my_subscriber_i::type_id::create("my_subscriber_i_h", this);
      my_subscriber_o_h = my_subscriber_o::type_id::create("my_subscriber_o_h", this);
      my_model_h = my_model::type_id::create("my_model_h", this);
      my_scoreboard_h = my_scoreboard::type_id::create("my_scoreboard_h", this);

      i_agt_mdl_fifo = new("i_agt_mdl_fifo", this);
      o_agt_scb_fifo = new("o_agt_scb_fifo", this);
      mdl_scb_fifo   = new("mdl_scb_fifo", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
      my_agent_i_h.ap.connect(my_subscriber_i_h.analysis_export);
      my_agent_o_h.ap.connect(my_subscriber_o_h.analysis_export);
      
      my_agent_i_h.ap.connect(i_agt_mdl_fifo.analysis_export);
      my_model_h.bgp.connect(i_agt_mdl_fifo.blocking_get_export);

      my_agent_o_h.ap.connect(o_agt_scb_fifo.analysis_export);
      my_scoreboard_h.act_bgp.connect(o_agt_scb_fifo.blocking_get_export);

      my_model_h.ap.connect(mdl_scb_fifo.analysis_export);
      my_scoreboard_h.exp_bgp.connect(mdl_scb_fifo.blocking_get_export);

    endfunction : connect_phase

  endclass : my_env

endpackage : my_env_pkg