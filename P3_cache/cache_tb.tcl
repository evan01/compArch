proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/cache_tb/clk
    add wave -position end sim:/cache_tb/s_addr
    add wave -position end sim:/cache_tb/s_read
    add wave -position end sim:/cache_tb/s_readdata
    add wave -position end sim:/cache_tb/s_write
    add wave -position end sim:/cache_tb/s_writedata
    add wave -position end sim:/cache_tb/m_addr
    add wave -position end sim:/cache_tb/m_read
    add wave -position end sim:/cache_tb/m_readdata
    add wave -position end sim:/cache_tb/m_write
    add wave -position end sim:/cache_tb/m_writedata
    add wave -position end sim:/cache_tb/m_waitrequest
    add wave -position end  sim:/cache_tb/dut/mem_contr/mem_controller_read
    add wave -position end  sim:/cache_tb/dut/mem_contr/mem_controller_write
    add wave -position end  sim:/cache_tb/dut/mem_contr/mem_controller_addr
    add wave -position end  sim:/cache_tb/dut/mem_contr/mem_controller_wait
    add wave -position end  sim:/cache_tb/dut/mem_contr/state
}

vlib work

;# Compile components if any
vcom cache.vhd
vcom mem_controller.vhd
vcom read_controller.vhd
vcom write_controller.vhd
vcom memory.vhd
vcom memory_tb.vhd
vcom cache_tb.vhd

;# Start simulation
vsim cache_tb

;# Add the waves
AddWaves

;# Run for 50 ns
run 1000ns
