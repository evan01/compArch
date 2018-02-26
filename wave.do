onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cache_tb/error_signal
add wave -noupdate -divider CPU
add wave -noupdate /cache_tb/clk
add wave -noupdate -radix binary /cache_tb/s_addr
add wave -noupdate /cache_tb/s_waitrequest
add wave -noupdate /cache_tb/s_read
add wave -noupdate /cache_tb/s_write
add wave -noupdate -radix unsigned /cache_tb/s_readdata
add wave -noupdate -radix unsigned /cache_tb/s_writedata
add wave -noupdate /cache_tb/reset
add wave -noupdate -divider READ_CONTROLLER
add wave -noupdate -label READ_STATE /cache_tb/dut/read_contr/state
add wave -noupdate -label CPU_WAIT /cache_tb/dut/read_contr/s_waitrequest
add wave -noupdate -label TAG /cache_tb/dut/read_contr/tag
add wave -noupdate -label INDEX /cache_tb/dut/read_contr/index
add wave -noupdate -label OFFSET /cache_tb/dut/read_contr/offset
add wave -noupdate -label {CACHE ROW} /cache_tb/dut/read_contr/cache_block
add wave -noupdate -radix hexadecimal /cache_tb/dut/read_contr/s_addr
add wave -noupdate -label READ_DATA -radix hexadecimal /cache_tb/dut/read_contr/s_readdata
add wave -noupdate -divider WRITE_CONTROLLER
add wave -noupdate -label WRITE_STATE /cache_tb/dut/write_contr/state
add wave -noupdate -label CPU_WAIT /cache_tb/dut/write_contr/s_waitrequest
add wave -noupdate -label W_TAG /cache_tb/dut/write_contr/tag
add wave -noupdate -label W_INDEX -radix unsigned /cache_tb/dut/write_contr/index
add wave -noupdate -label OFFSET /cache_tb/dut/write_contr/offset
add wave -noupdate -label {CACHE ROW} -radix binary /cache_tb/dut/write_contr/cache_row
add wave -noupdate -label {Block Number} /cache_tb/dut/write_contr/block_number
add wave -noupdate -label cpu_WriteData -radix unsigned /cache_tb/dut/write_contr/s_writedata
add wave -noupdate -label MEM_RW_REQ /cache_tb/dut/write_contr/mem_rw_requested
add wave -noupdate -label MEM_READ /cache_tb/dut/mem_contr/mem_controller_read
add wave -noupdate -label MEM_WRITE /cache_tb/dut/mem_contr/mem_controller_write
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -divider {CACHE MEMORY}
add wave -noupdate -radix unsigned -childformat {{/cache_tb/dut/read_contr/cache_array(31) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(30) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(29) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(28) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(27) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(26) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(25) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(24) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(23) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(22) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(21) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(20) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(19) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(18) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(17) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(16) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(15) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(14) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(13) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(12) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(11) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(10) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(9) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(8) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(7) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(6) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(5) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(4) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(3) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(2) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(1) -radix unsigned} {/cache_tb/dut/read_contr/cache_array(0) -radix unsigned}} -expand -subitemconfig {/cache_tb/dut/read_contr/cache_array(31) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(30) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(29) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(28) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(27) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(26) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(25) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(24) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(23) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(22) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(21) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(20) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(19) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(18) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(17) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(16) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(15) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(14) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(13) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(12) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(11) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(10) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(9) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(8) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(7) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(6) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(5) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(4) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(3) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(2) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(1) {-radix unsigned} /cache_tb/dut/read_contr/cache_array(0) {-radix unsigned}} /cache_tb/dut/read_contr/cache_array
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2807 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 224
configure wave -valuecolwidth 206
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
WaveRestoreZoom {0 ps} {21744 ps}
