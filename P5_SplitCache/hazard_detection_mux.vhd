LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY hazard_detection_mux IS
	PORT (
		idex_flush : IN std_logic;
		reg_dst_in : IN std_logic;
		alu_src_in : IN std_logic;
		mem_read_in : IN std_logic;
		mem_write_in : IN std_logic;
		reg_write_in : IN std_logic;
		mem_to_reg_in : IN std_logic;
		alu_opcode_in : IN std_logic_vector (4 DOWNTO 0);
		reg_dst_out : OUT std_logic;
		alu_src_out : OUT std_logic;
		mem_read_out : OUT std_logic;
		mem_write_out : OUT std_logic;
		reg_write_out : OUT std_logic;
		mem_to_reg_out : OUT std_logic;
		alu_opcode_out : OUT std_logic_vector (4 DOWNTO 0)
	);
END hazard_detection_mux;

ARCHITECTURE arch OF hazard_detection_mux IS

BEGIN
reg_dst_out <= reg_dst_in when idex_flush ='0' else '0';
alu_src_out <= alu_src_in when idex_flush ='0' else '1';
mem_read_out <= mem_read_in when idex_flush ='0' else '0';
mem_write_out <= mem_write_in when idex_flush ='0' else '0';
reg_write_out <= reg_write_in when idex_flush ='0' else '0';
mem_to_reg_out <= mem_to_reg_in when idex_flush ='0' else '0';
alu_opcode_out <= alu_opcode_in when idex_flush ='0' else "01011";
END arch;
