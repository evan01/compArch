
proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/pipe/clock
    add wave -position end sim:/pipe/cpu_reg/register_array
}

vlib work

;# Compile components if any
vcom alu.vhd
vcom branch_comparator.vhd
vcom byte_adder.vhd
vcom cpu_registers.vhd
vcom data_memory.vhd
vcom exmem_register.vhd
vcom forwarding_unit.vhd
vcom hazard_detection.vhd
vcom hazard_detection_mux.vhd
vcom idex_register.vhd
vcom ifid_register.vhd
vcom instruction_memory.vhd
vcom memwb_register.vhd
vcom mux2to1.vhd
vcom mux3to1.vhd
vcom pipeline_controller.vhd
vcom program_counter.vhd
vcom sign_extender.vhd
vcom pipeline.vhd
vcom pipeline_tb.vhd

;# Start simulation
vsim pipeline_tb

;# Add the waves
AddWaves

;# Run for 1000 ns
run 10000ns
