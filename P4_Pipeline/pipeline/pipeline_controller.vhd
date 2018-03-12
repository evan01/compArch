LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- OPCODES taken from http://www.mrc.uidaho.edu/mrc/people/jff/digital/MIPSir.html

ENTITY pipeline_controller IS
	PORT (
		instruction : IN std_logic_vector (31 DOWNTO 0);
		reg_dst : OUT std_logic;
		alu_src : OUT std_logic;
		branch : OUT std_logic;
		mem_read : OUT std_logic;
		mem_write : OUT std_logic;
		reg_write : OUT std_logic;
		mem_to_reg : OUT std_logic;
		alu_opcode : OUT std_logic_vector (4 DOWNTO 0)
	);
END pipeline_controller;

ARCHITECTURE arch OF pipeline_controller IS

	SIGNAL op_code : std_logic_vector (5 DOWNTO 0);
	SIGNAL funct : std_logic_vector (5 DOWNTO 0);

BEGIN
	operation : PROCESS (op_code, funct)
	BEGIN
		op_code <= instruction(31 DOWNTO 26);
		funct <= instruction(5 DOWNTO 0);
 
 
		CASE op_code IS
 
			-- add
			WHEN "100000" => 
				reg_dst <= '1';
				alu_src <= '0';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "00000";

				-- sub 
			WHEN "100010" => 
				reg_dst <= '1';
				alu_src <= '0';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "00001";

				-- addi 
			WHEN "001000" => 
				reg_dst <= '1';
				alu_src <= '0';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "00010"; 

				-- mult
			WHEN "011000" => 
				reg_dst <= '1';
				alu_src <= '0';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "00011";

				-- div
			WHEN "011010" => 
				reg_dst <= '1';
				alu_src <= '0';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "00100";
				-- slt
			WHEN "101010" => 
				reg_dst <= '1';
				alu_src <= '0';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "00101";

				-- slti
			WHEN "001010" => 
				reg_dst <= '1';
				alu_src <= '0';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "00110";

				-- and
			WHEN "100100" => 
				reg_dst <= '1';
				alu_src <= '0';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "00111";

				-- or
			WHEN "100101" => 
				reg_dst <= '1';
				alu_src <= '0';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "01000";

				-- nor
			WHEN "100111" => 
				reg_dst <= '1';
				alu_src <= '0';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "01001";

				-- xor
			WHEN "100110" => 
				reg_dst <= '1';
				alu_src <= '0';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "01010";

				-- andi
			WHEN "001100" => 
				reg_dst <= '1';
				alu_src <= '0';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "01011";

				-- ori
			WHEN "001101" => 
				reg_dst <= '1';
				alu_src <= '0';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "01100";

				-- xori
			WHEN "001110" => 
				reg_dst <= '1';
				alu_src <= '0';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "01101";

				-- mfhi
			WHEN "010000" => 
				reg_dst <= '1';
				alu_src <= '0';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "01110";
				-- mflo
			WHEN "010010" => 
				reg_dst <= '1';
				alu_src <= '0';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "01111";
				-- lui
			WHEN "001111" => 
				reg_dst <= '1';
				alu_src <= '0';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "10000";

				-- sll or srl
			WHEN "000000" => 
				CASE funct IS
					WHEN "000000" => 
						-- sll
						reg_dst <= '1';
						alu_src <= '0';
						branch <= '0';
						mem_read <= '0';
						mem_write <= '0';
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_opcode <= "10001";
 
					WHEN "000010" => 
						-- srl
						reg_dst <= '1';
						alu_src <= '0';
						branch <= '0';
						mem_read <= '0';
						mem_write <= '0';
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_opcode <= "10010";
 
 
					WHEN "000011" => 
						-- sra
						reg_dst <= '1';
						alu_src <= '0';
						branch <= '0';
						mem_read <= '0';
						mem_write <= '0';
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_opcode <= "10011"; 
 
						-- jr
					WHEN "001000" => 
						reg_dst <= '1'; -- dont care
						alu_src <= '0';
						branch <= '1';
						mem_read <= '0';
						mem_write <= '0';
						reg_write <= '0';
						mem_to_reg <= '0'; -- dont care
						alu_opcode <= "11001";
 
					WHEN OTHERS => 
						NULL; 
 
			END CASE; 
			-- lw
			WHEN "100011" => 
				reg_dst <= '0';
				alu_src <= '1';
				branch <= '0';
				mem_read <= '1';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '1';
				alu_opcode <= "10100";

				-- sw
			WHEN "101011" => 
				reg_dst <= '1'; -- dont care
				alu_src <= '1';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '1';
				reg_write <= '0';
				mem_to_reg <= '0'; -- dont care
				alu_opcode <= "10101";

				-- beq
			WHEN "000100" => 
				reg_dst <= '1'; -- dont care
				alu_src <= '0';
				branch <= '1';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '0';
				mem_to_reg <= '0'; -- dont care
				alu_opcode <= "10110";

				-- bne
			WHEN "000101" => 
				reg_dst <= '1'; -- dont care
				alu_src <= '0';
				branch <= '1';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '0';
				mem_to_reg <= '0'; -- dont care
				alu_opcode <= "10111";

				-- j
			WHEN "000010" => 
				reg_dst <= '1'; -- dont care
				alu_src <= '0';
				branch <= '1';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '0';
				mem_to_reg <= '0'; -- dont care
				alu_opcode <= "11000";
 

				-- jal
			WHEN "000011" => 
				reg_dst <= '1'; -- dont care
				alu_src <= '0';
				branch <= '1';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '0';
				mem_to_reg <= '0'; -- dont care
				alu_opcode <= "11010";

 
			WHEN OTHERS => 
				NULL;
		END CASE;

	END PROCESS operation;

END arch;