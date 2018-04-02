onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pipeline_tb/pipe/clock
add wave -noupdate /pipeline_tb/pipe/if_pc_output_address
add wave -noupdate /pipeline_tb/pipe/if_pc_input_address
add wave -noupdate -radix binary /pipeline_tb/pipe/if_instruction
add wave -noupdate -radix binary /pipeline_tb/pipe/id_instruction
add wave -noupdate /pipeline_tb/pipe/id_jump
add wave -noupdate /pipeline_tb/pipe/hazard_detect/first_instruction
add wave -noupdate /pipeline_tb/pipe/hazard_detect/ex_rt_register
add wave -noupdate /pipeline_tb/pipe/hazard_detect/ex_rd_register
add wave -noupdate -divider {Hazzard Detection}
add wave -noupdate /pipeline_tb/pipe/hazard_detect/idex_out_mem_read
add wave -noupdate /pipeline_tb/pipe/hazard_detect/mux_flush
add wave -noupdate /pipeline_tb/pipe/hazard_detect/pc_write
add wave -noupdate /pipeline_tb/pipe/hazard_detect/fflush
add wave -noupdate /pipeline_tb/pipe/hazard_detect/input_instruction_type
add wave -noupdate /pipeline_tb/pipe/hazard_detect/last_instruction_type
add wave -noupdate /pipeline_tb/pipe/hazard_detect/currently_stalling
add wave -noupdate -divider JUMP
add wave -noupdate /pipeline_tb/pipe/id_jump
add wave -noupdate /pipeline_tb/pipe/id_jump_sel
add wave -noupdate /pipeline_tb/pipe/id_pc_src
add wave -noupdate /pipeline_tb/pipe/id_branch_taken
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -divider CPU_REGISTERS
add wave -noupdate -expand /pipeline_tb/pipe/cpu_reg/register_array
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3727 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 235
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {8487 ps}
