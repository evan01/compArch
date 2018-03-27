LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- OPCODES taken from http://www.mrc.uidaho.edu/mrc/people/jff/digital/MIPSir.html

ENTITY pipeline_controller IS
	PORT (
		instruction : IN std_logic_vector (31 DOWNTO 0);
		reg_dst : OUT std_logic;
		alu_src : OUT std_logic;
		branch : OUT std_logic := '0';
		mem_read : OUT std_logic;
		mem_write : OUT std_logic;
		reg_write : OUT std_logic;
		mem_to_reg : OUT std_logic;
		shift_instr : OUT std_logic;
		jump_sel : OUT std_logic;
		jump : OUT std_logic;
		alu_opcode : OUT std_logic_vector (4 DOWNTO 0)
	);
END pipeline_controller;

ARCHITECTURE arch OF pipeline_controller IS


BEGIN

	operation : PROCESS (instruction)

	BEGIN
		CASE instruction(31 downto 26) IS

				-- addi
				-- I type
			WHEN "001000" =>
				reg_dst <= '0';
				alu_src <= '1';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "00010";
				shift_instr <= '0';
				jump <= '0';
				jump_sel <= '0';

				-- slti
				-- i type
			WHEN "001010" =>
				reg_dst <= '0';
				alu_src <= '1';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "00110";
				shift_instr <= '0';
				jump <= '0';
				jump_sel <= '0';

				-- andi
				-- i type
			WHEN "001100" =>
				reg_dst <= '0';
				alu_src <= '1';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "01011";
				shift_instr <= '0';
				jump <= '0';
				jump_sel <= '0';
				-- ori
				-- i type
			WHEN "001101" =>
				reg_dst <= '0';
				alu_src <= '1';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "01100";
				shift_instr <= '0';
				jump <= '0';
				jump_sel <= '0';
				-- xori
				-- i type
			WHEN "001110" =>
				reg_dst <= '0';
				alu_src <= '1';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "01101";
				shift_instr <= '0';
				jump <= '0';
				jump_sel <= '0';

				-- lui
				-- i type
			WHEN "001111" =>
				reg_dst <= '0';
				alu_src <= '1';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_opcode <= "10000";
				shift_instr <= '0';
				jump <= '0';
				jump_sel <= '0';
				-- sll or srl
			WHEN "000000" =>
				CASE instruction(5 downto 0) IS
					WHEN "000000" =>
						-- sll
						-- r type
						reg_dst <= '1';
						alu_src <= '0';
						branch <= '0';
						mem_read <= '0';
						mem_write <= '0';
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_opcode <= "10001";
						shift_instr <= '1';
						jump <= '0';
						jump_sel <= '0';
					WHEN "000010" =>
						-- srl
						-- r type
						reg_dst <= '1';
						alu_src <= '0';
						branch <= '0';
						mem_read <= '0';
						mem_write <= '0';
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_opcode <= "10010";
						shift_instr <= '1';
						jump <= '0';
						jump_sel <= '0';
					WHEN "000011" =>
						-- sra
						-- r type
						reg_dst <= '1';
						alu_src <= '0';
						branch <= '0';
						mem_read <= '0';
						mem_write <= '0';
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_opcode <= "10011";
						shift_instr <= '1';
						jump <= '0';
						jump_sel <= '0';
						
						-- jr
						-- i type
					WHEN "001000" =>
						reg_dst <= '1'; -- dont care
						alu_src <= '0';
						branch <= '0';
						mem_read <= '0';
						mem_write <= '0';
						reg_write <= '0';
						mem_to_reg <= '0'; -- dont care
						alu_opcode <= "11001";
						shift_instr <= '0';
						jump <= '1';
						jump_sel <= '1';

					-- add
					-- R Type
					WHEN "100000" =>
						reg_dst <= '1';
						alu_src <= '0';
						branch <= '0';
						mem_read <= '0';
						mem_write <= '0';
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_opcode <= "00000";
						shift_instr <= '0';
						jump <= '0';
						jump_sel <= '0';
					-- sub
					-- R type
					WHEN "100010" =>
						reg_dst <= '1';
						alu_src <= '0';
						branch <= '0';
						mem_read <= '0';
						mem_write <= '0';
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_opcode <= "00001";
						shift_instr <= '0';
						jump <= '0';
						jump_sel <= '0';
					-- mult
					-- r type
					WHEN "011000" =>
					reg_dst <= '1';
					alu_src <= '0';
					branch <= '0';
					mem_read <= '0';
					mem_write <= '0';
					reg_write <= '1';
					mem_to_reg <= '0';
					alu_opcode <= "00011";
					shift_instr <= '0';
					jump <= '0';
					jump_sel <= '0';
					-- div
					-- r type
					WHEN "011010" =>
					reg_dst <= '1';
					alu_src <= '0';
					branch <= '0';
					mem_read <= '0';
					mem_write <= '0';
					reg_write <= '1';
					mem_to_reg <= '0';
					alu_opcode <= "00100";
					shift_instr <= '0';
					jump <= '0';
					jump_sel <= '0';
					-- slt
					-- r type
					WHEN "101010" =>
					reg_dst <= '1';
					alu_src <= '0';
					branch <= '0';
					mem_read <= '0';
					mem_write <= '0';
					reg_write <= '1';
					mem_to_reg <= '0';
					alu_opcode <= "00101";
					shift_instr <= '0';
					jump <= '0';
					jump_sel <= '0';
					-- and
					-- r type
					WHEN "100100" =>
						reg_dst <= '1';
						alu_src <= '0';
						branch <= '0';
						mem_read <= '0';
						mem_write <= '0';
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_opcode <= "00111";
						shift_instr <= '0';
						jump <= '0';
						jump_sel <= '0';
					-- or
					-- r type
					WHEN "100101" =>
						reg_dst <= '1';
						alu_src <= '0';
						branch <= '0';
						mem_read <= '0';
						mem_write <= '0';
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_opcode <= "01000";
						shift_instr <= '0';
						jump <= '0';
						jump_sel <= '0';
						-- nor
						-- r type
					WHEN "100111" =>
						reg_dst <= '1';
						alu_src <= '0';
						branch <= '0';
						mem_read <= '0';
						mem_write <= '0';
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_opcode <= "01001";
						shift_instr <= '0';
						jump <= '0';
						jump_sel <= '0';
						-- xor
						-- r type
					WHEN "101000" =>
						reg_dst <= '1';
						alu_src <= '0';
						branch <= '0';
						mem_read <= '0';
						mem_write <= '0';
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_opcode <= "01010";
						shift_instr <= '0';
						jump <= '0';
						jump_sel <= '0';
						-- mfhi
						-- r type
					WHEN "010000" =>
						reg_dst <= '1';
						alu_src <= '0';
						branch <= '0';
						mem_read <= '0';
						mem_write <= '0';
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_opcode <= "01110";
						shift_instr <= '0';
						jump <= '0';
						jump_sel <= '0';
						-- mflo
						-- r type
					WHEN "010010" =>
						reg_dst <= '1';
						alu_src <= '0';
						branch <= '0';
						mem_read <= '0';
						mem_write <= '0';
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_opcode <= "01111";
						shift_instr <= '0';
						jump <= '0';
						jump_sel <= '0';
					WHEN OTHERS =>
						reg_dst <= '0'; -- dont care
						alu_src <= '0';
						branch <= '0';
						mem_read <= '0';
						mem_write <= '0';
						reg_write <= '0';
						mem_to_reg <= '0'; -- dont care
						alu_opcode <= "00000";
						shift_instr <= '0';
						jump <= '0';
						jump_sel <= '0';
			END CASE;
			-- lw
			-- i type
			WHEN "100011" =>
				reg_dst <= '0';
				alu_src <= '1';
				branch <= '0';
				mem_read <= '1';
				mem_write <= '0';
				reg_write <= '1';
				mem_to_reg <= '1';
				alu_opcode <= "10100";
				shift_instr <= '0';
				jump <= '0';
				jump_sel <= '0';
				-- sw
				-- i type
			WHEN "101011" =>
				reg_dst <= '1'; -- dont care
				alu_src <= '1';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '1';
				reg_write <= '0';
				mem_to_reg <= '0'; -- dont care
				alu_opcode <= "10101";
				shift_instr <= '0';
				jump <= '0';
				jump_sel <= '0';
				-- beq
				-- i type
			WHEN "000100" =>
				reg_dst <= '1'; -- dont care
				alu_src <= '0';
				branch <= '1';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '0';
				mem_to_reg <= '0'; -- dont care
				alu_opcode <= "10110";
				shift_instr <= '0';
				jump <= '0';
				jump_sel <= '0';
				-- bne
				-- i type
			WHEN "000101" =>
				reg_dst <= '1'; -- dont care
				alu_src <= '0';
				branch <= '1';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '0';
				mem_to_reg <= '0'; -- dont care
				alu_opcode <= "10111";
				shift_instr <= '0';
				jump <= '0';
				jump_sel <= '0';

				-- j
				-- j type
			WHEN "000010" =>
				reg_dst <= '1'; -- dont care
				alu_src <= '0';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '0';
				mem_to_reg <= '0'; -- dont care
				alu_opcode <= "11000";
				shift_instr <= '0';
				jump <= '1';
				jump_sel <= '0';

				-- jal
				-- j type
			WHEN "000011" =>
				reg_dst <= '1'; -- dont care
				alu_src <= '0';
				branch <= '0';
				mem_read <= '0';
				mem_write <= '0';
				reg_write <= '0';
				mem_to_reg <= '0'; -- dont care
				alu_opcode <= "11010";
				shift_instr <= '0';
				jump <= '1';
				jump_sel <= '0';

			WHEN OTHERS =>
				NULL;
		END CASE;

	END PROCESS operation;

END arch;
