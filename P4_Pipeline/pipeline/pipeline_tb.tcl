
proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    #add wave -position end sim:/cache_tb/clk
    #add wave -position end sim:/cache_tb/s_addr
}

vlib work

;# Compile components if any
vcom pipeline.vhd
vcom pipeline_tb.vhd

;# Start simulation
vsim pipeline_tb

;# Add the waves
AddWaves

;# Run for 50 ns
run 1000ns
