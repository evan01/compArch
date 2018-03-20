LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY hazard_detection_mux IS
	PORT (
		mux_flush : IN std_logic;
		reg_dst_in : IN std_logic;
		alu_src_in : IN std_logic;
		branch_in : IN std_logic := '0';
		mem_read_in : IN std_logic;
		mem_write_in : IN std_logic;
		reg_write_in : IN std_logic;
		mem_to_reg_in : IN std_logic;
		alu_opcode_in : IN std_logic_vector (4 DOWNTO 0);
		reg_dst_out : OUT std_logic;
		alu_src_out : OUT std_logic;
		branch_out : OUT std_logic := '0';
		mem_read_out : OUT std_logic;
		mem_write_out : OUT std_logic;
		reg_write_out : OUT std_logic;
		mem_to_reg_out : OUT std_logic;
		alu_opcode_out : OUT std_logic_vector (4 DOWNTO 0)
	);
END hazard_detection_mux;

ARCHITECTURE arch OF hazard_detection_mux IS

BEGIN
	PROCESS (mux_flush, reg_dst_in, alu_src_in, branch_in, mem_read_in, mem_write_in, reg_write_in, mem_to_reg_in, alu_opcode_in)
	BEGIN
		IF (mux_flush = '1') THEN
			-- Adding outputs thay correspond to the bubble instrcution
			reg_dst_out <= '0';
			alu_src_out <= '1';
			branch_out <= '0';
			mem_read_out <= '0';
			mem_write_out <= '0';
			reg_write_out <= '0';
			mem_to_reg_out <= '1';
			alu_opcode_out <= "01011";

		ELSE
			reg_dst_out <= reg_dst_in;
			alu_src_out <= alu_src_in;
			branch_out <= branch_in;
			mem_read_out <= mem_read_in;
			mem_write_out <= mem_write_in;
			reg_write_out <= reg_write_in;
			mem_to_reg_out <= mem_to_reg_in;
			alu_opcode_out <= alu_opcode_in;
 
		END IF;
	END PROCESS;

END arch;