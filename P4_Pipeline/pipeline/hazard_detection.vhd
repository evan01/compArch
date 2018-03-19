LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY hazard_detection IS
	PORT(
		ifid_out_instruction : IN  std_logic_vector(31 DOWNTO 0); -- instruction in if-id stage
		idex_out_rt_register : IN  std_logic_vector(4 DOWNTO 0); -- rt register in the id-ex stage
		idex_out_mem_read    : IN  std_logic; -- if memory is being read
		branch_taken         : IN  std_logic; -- input from the branch_comparator
		mux_flush            : OUT std_logic; -- To add bubble
		pc_write             : OUT std_logic; -- used to stall current instruction
		fflush               : OUT std_logic -- Flush instructions if j type
	);
END hazard_detection;

ARCHITECTURE arch OF hazard_detection IS

	TYPE instruction_type IS (r_type, i_type, j_type);
	SIGNAL input_instruction_type : instruction_type;

BEGIN
	PROCESS(input_instruction_type, ifid_out_instruction, idex_out_rt_register, idex_out_mem_read, branch_taken)
	BEGIN
		IF (branch_taken = '1') THEN
			pc_write  <= '1';
			fflush    <= '0';
			mux_flush <= '1';
		END IF;

		IF (idex_out_mem_read = '1') THEN
			pc_write  <= '1';
			fflush    <= '0';
			mux_flush <= '1';
		END IF;

		CASE input_instruction_type IS
			WHEN r_type =>
				IF (ifid_out_instruction(25 DOWNTO 21) = idex_out_rt_register or ifid_out_instruction(21 DOWNTO 17) = idex_out_rt_register or ifid_out_instruction(16 DOWNTO 12) = idex_out_rt_register) THEN
					pc_write  <= '1';
					fflush    <= '0';
					mux_flush <= '1';
				END IF;

			WHEN i_type =>
				IF (ifid_out_instruction(25 DOWNTO 21) = idex_out_rt_register) THEN
					pc_write  <= '1';
					fflush    <= '0';
					mux_flush <= '1';
				END IF;

			WHEN j_type =>
				pc_write  <= '0';
				fflush    <= '1';
				mux_flush <= '0';

			WHEN OTHERS =>
				pc_write  <= 'Z';
				fflush    <= 'Z';
				mux_flush <= 'Z';

		END CASE;

	END PROCESS;

	PROCESS(ifid_out_instruction)
	BEGIN
		-- Set the value of input instruction type based on the inputs
		CASE ifid_out_instruction(31 DOWNTO 26) IS

			-- addi
			-- I type
			WHEN "001000" =>
				input_instruction_type <= i_type;
			-- slti
			-- i type
			WHEN "001010" =>
				input_instruction_type <= i_type;

			-- andi
			-- i type
			WHEN "001100" =>
				input_instruction_type <= i_type;
			-- ori
			-- i type
			WHEN "001101" =>
				input_instruction_type <= i_type;
			-- xori
			-- i type
			WHEN "001110" =>
				input_instruction_type <= i_type;
			-- lui
			-- i type
			WHEN "001111" =>
				input_instruction_type <= i_type;
			-- sll or srl
			WHEN "000000" =>
				CASE ifid_out_instruction(5 DOWNTO 0) IS
					WHEN "000000" =>
						-- sll
						-- r type
						input_instruction_type <= r_type;

					WHEN "000010" =>
						-- srl
						-- r type
						input_instruction_type <= r_type;
					WHEN "000011" =>
						-- sra
						-- r type
						input_instruction_type <= r_type;

					-- jr
					-- r type
					WHEN "001000" =>
						input_instruction_type <= j_type;

					-- add
					-- R Type
					WHEN "100000" =>
						input_instruction_type <= r_type;

					-- sub
					-- R type
					WHEN "100010" =>
						input_instruction_type <= r_type;

					-- mult
					-- r type
					WHEN "011000" =>
						input_instruction_type <= r_type;

					-- div
					-- r type
					WHEN "011010" =>
						input_instruction_type <= r_type;
					-- slt
					-- r type
					WHEN "101010" =>
						input_instruction_type <= r_type;
					-- and
					-- r type
					WHEN "100100" =>
						input_instruction_type <= r_type;

					-- or
					-- r type
					WHEN "100101" =>
						input_instruction_type <= r_type;

					-- nor
					-- r type
					WHEN "100111" =>
						input_instruction_type <= r_type;

					-- xor
					-- r type
					WHEN "100110" =>
						input_instruction_type <= r_type;

					-- mfhi
					-- r type
					WHEN "010000" =>
						input_instruction_type <= r_type;

					-- mflo
					-- r type
					WHEN "010010" =>
						input_instruction_type <= r_type;

					-- Cannot assign null, assigning r_type since they are the majority type
					WHEN OTHERS =>
						input_instruction_type <= r_type;

				END CASE;
			-- lw
			-- i type
			WHEN "100011" =>
				input_instruction_type <= i_type;

			-- sw
			-- i type
			WHEN "101011" =>
				input_instruction_type <= i_type;

			-- beq
			-- i type
			WHEN "000100" =>
				input_instruction_type <= i_type;

			-- bne
			-- i type
			WHEN "000101" =>
				input_instruction_type <= i_type;

			-- j
			-- j type
			WHEN "000010" =>
				input_instruction_type <= j_type;
			-- jal
			-- j type
			WHEN "000011" =>
				input_instruction_type <= j_type;

			-- Cannot assign null, assigning r_type since they are the majority type
			WHEN OTHERS =>
				input_instruction_type <= r_type;

		END CASE;
	END PROCESS;
END arch;
