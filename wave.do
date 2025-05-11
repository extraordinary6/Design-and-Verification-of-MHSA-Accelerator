onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate {/my_top/genblk1[0]/u_dut/u_dut_top/u_mhsa_acc_wrapper/clk}
add wave -noupdate {/my_top/genblk1[0]/u_dut/u_dut_top/u_mhsa_acc_wrapper/rst_n}
add wave -noupdate {/my_top/genblk1[0]/u_dut/u_dut_top/u_mhsa_acc_wrapper/done}
add wave -noupdate {/my_top/genblk1[0]/u_dut/u_dut_top/u_mhsa_acc_wrapper/start}
add wave -noupdate {/my_top/genblk1[0]/u_dut/u_dut_top/u_mhsa_acc_wrapper/input_base}
add wave -noupdate {/my_top/genblk1[0]/u_dut/u_dut_top/u_mhsa_acc_wrapper/output_base}
add wave -noupdate {/my_top/genblk1[0]/u_dut/u_dut_top/u_mhsa_acc_wrapper/soc_write_en}
add wave -noupdate {/my_top/genblk1[0]/u_dut/u_dut_top/u_mhsa_acc_wrapper/soc_data_in}
add wave -noupdate {/my_top/genblk1[0]/u_dut/u_dut_top/u_mhsa_acc_wrapper/soc_addr}
add wave -noupdate {/my_top/genblk1[0]/u_dut/u_dut_top/u_mhsa_acc_wrapper/soc_data_out}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {448075000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 602
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {448028875 ps} {448235171 ps}
