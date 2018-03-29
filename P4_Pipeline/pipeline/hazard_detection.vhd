LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY hazard_detection IS
	PORT(
		id_instruction : IN  std_logic_vector(31 DOWNTO 0); -- instruction in if-id stage
		ex_rd_register : IN  std_logic_vector(4 DOWNTO 0); -- rt register in the id-ex stage
		ex_rs_register : IN  std_logic_vector(4 DOWNTO 0); -- rt register in the id-ex stage
		ex_rt_register : IN  std_logic_vector(4 DOWNTO 0); -- rt register in the id-ex stage
		idex_out_mem_read    : IN  std_logic; -- if memory is being read
		idex_flush            : OUT std_logic := '0'; -- To add bubble
		pc_write             : OUT std_logic := '1'; -- used to stall current instruction
		fflush               : OUT std_logic := '0' -- Flush instructions if j type
	);
END hazard_detection;

ARCHITECTURE arch OF hazard_detection IS

	TYPE instruction_type IS (r_type, i_type, j_type, b_type);
	SIGNAL input_instruction_type : instruction_type;
	signal last_instruction_type : instruction_type;
	signal second_last_instruction_type : instruction_type;
	signal first_instruction: std_logic := '1';

		function get_instruction_type (id_instruction: std_logic_vector(31 downto 0)) return instruction_type is
	BEGIN
		-- Set the value of input instruction type based on the inputs
		CASE id_instruction(31 DOWNTO 26) IS

			-- addi
			-- I type
			WHEN "001000" =>
				return i_type;
			-- slti
			-- i type
			WHEN "001010" =>
				return i_type;

			-- andi
			-- i type
			WHEN "001100" =>
				return i_type;
			-- ori
			-- i type
			WHEN "001101" =>
				return i_type;
			-- xori
			-- i type
			WHEN "001110" =>
				return i_type;
			-- lui
			-- i type
			WHEN "001111" =>
				return i_type;
			-- sll or srl
			WHEN "000000" =>
				CASE id_instruction(5 DOWNTO 0) IS
					WHEN "000000" =>
						-- sll
						-- r type
						return r_type;

					WHEN "000010" =>
						-- srl
						-- r type
						return r_type;
					WHEN "000011" =>
						-- sra
						-- r type
						return r_type;

					-- jr
					-- r type
					WHEN "001000" =>
						return j_type;

					-- add
					-- R Type
					WHEN "100000" =>
						return r_type;

					-- sub
					-- R type
					WHEN "100010" =>
						return r_type;

					-- mult
					-- r type
					WHEN "011000" =>
						return r_type;

					-- div
					-- r type
					WHEN "011010" =>
						return r_type;
					-- slt
					-- r type
					WHEN "101010" =>
						return r_type;
					-- and
					-- r type
					WHEN "100100" =>
						return r_type;

					-- or
					-- r type
					WHEN "100101" =>
						return r_type;

					-- nor
					-- r type
					WHEN "100111" =>
						return r_type;

					-- xor
					-- r type
					WHEN "100110" =>
						return r_type;

					-- mfhi
					-- r type
					WHEN "010000" =>
						return r_type;

					-- mflo
					-- r type
					WHEN "010010" =>
						return r_type;

					-- Cannot assign null, assigning r_type since they are the majority type
					WHEN OTHERS =>
						return r_type;

				END CASE;
			-- lw
			-- i type
			WHEN "100011" =>
				return i_type;

			-- sw
			-- i type
			WHEN "101011" =>
				return i_type;

			-- beq
			-- i type
			WHEN "000100" =>
				return b_type;

			-- bne
			-- i type
			WHEN "000101" =>
				return b_type;

			-- j
			-- j type
			WHEN "000010" =>
				return j_type;
			-- jal
			-- j type
			WHEN "000011" =>
				return j_type;

			-- Cannot assign null, assigning r_type since they are the majority type
			WHEN OTHERS =>
				return r_type;

		END CASE;
	END get_instruction_type;


BEGIN

	PROCESS(id_instruction, ex_rd_register, ex_rt_register)
	variable current_instruction_type : instruction_type;
	BEGIN
		if (first_instruction = '1') then
			first_instruction <= '0';
		else
			IF (idex_out_mem_read = '1') THEN
				pc_write  <= '0';
				fflush    <= '0';
				idex_flush <= '1';
			END IF;
			current_instruction_type := get_instruction_type(id_instruction);
			CASE current_instruction_type IS
				WHEN r_type =>
					if (last_instruction_type = r_type) then
						--Check Rd in EX stage against Rs and Rt in ID stage
						IF ((id_instruction(25 DOWNTO 21) = ex_rd_register or id_instruction(20 DOWNTO 16) = ex_rd_register) and ex_rd_register /= "00000") THEN
							pc_write  <= '0';
							fflush    <= '0';
							idex_flush <= '1';
						END IF;
					elsif last_instruction_type = i_type then
						IF ((id_instruction(25 DOWNTO 21) = ex_rt_register or id_instruction(20 DOWNTO 16) = ex_rt_register) and ex_rt_register /= "00000") THEN
							pc_write  <= '0';
							fflush    <= '0';
							idex_flush <= '1';
						END IF;
					end if;

				WHEN i_type =>
					if (last_instruction_type = r_type) then
						IF (id_instruction(25 DOWNTO 21) = ex_rd_register and ex_rd_register /= "00000") THEN --Compare Rd in EX stage to Rs in ID stage
							pc_write  <= '0';
							fflush    <= '0';
							idex_flush <= '1';
						END IF;
					elsif last_instruction_type = i_type then
						IF (id_instruction(25 DOWNTO 21) = ex_rt_register and ex_rt_register /= "00000") THEN --Compare Rd in EX stage to Rs in ID stage
							pc_write  <= '0';
							fflush    <= '0';
							idex_flush <= '1';
						END IF;
					end if;

				When b_type =>
					if (last_instruction_type = r_type) then
						--Compare Rs in ID stage to Rd in ex stage
						IF ((id_instruction(25 DOWNTO 21) = ex_rd_register or id_instruction(20 DOWNTO 16) = ex_rd_register) and ex_rd_register /= "00000") THEN
							pc_write  <= '0';
							fflush    <= '0';
							idex_flush <= '1';
						END IF;
					elsif last_instruction_type = i_type then
						--Compare Rd in EX stage to Rs in ID stage
						IF ((id_instruction(25 DOWNTO 21) = ex_rt_register or id_instruction(20 DOWNTO 16) = ex_rt_register) and ex_rt_register /= "00000") THEN
							pc_write  <= '0';
							fflush    <= '0';
							idex_flush <= '1';
						END IF;
					end if;

				WHEN j_type =>
					pc_write  <= '1';
					fflush    <= '1';
					idex_flush <= '0';

				WHEN OTHERS =>
					pc_write  <= '1';
					fflush    <= '0';
					idex_flush <= '0';
			END CASE;

      last_instruction_type <= current_instruction_type;
      second_last_instruction_type <= last_instruction_type;
		END IF;
	END PROCESS;


END arch;
