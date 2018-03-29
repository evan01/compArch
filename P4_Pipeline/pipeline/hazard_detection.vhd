LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY hazard_detection IS
	PORT(
		id_instruction : IN  std_logic_vector(31 DOWNTO 0); -- instruction in if-id stage
		ex_rt_register : IN  std_logic_vector(4 DOWNTO 0); -- rt register in the id-ex stage
		ex_rd_register : IN  std_logic_vector(4 DOWNTO 0); -- rt register in the id-ex stage
		ex_mem_read    : IN  std_logic; -- if memory is being read
		ex_reg_write    : IN  std_logic; -- if memory is being read
		ex_mem_to_reg    : IN  std_logic; -- if memory is being read
		idex_flush            : OUT std_logic := '0'; -- To add bubble
		pc_write             : OUT std_logic := '1' -- used to stall current instruction
	);
END hazard_detection;

ARCHITECTURE arch OF hazard_detection IS

	TYPE instruction_type IS (r_type, i_type, j_type, b_type);
	SIGNAL input_instruction_type : instruction_type;
	signal last_instruction_type : instruction_type;
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

	PROCESS(id_instruction, ex_mem_read, ex_reg_write, ex_mem_to_reg)
	variable current_instruction_type : instruction_type;
	BEGIN
    current_instruction_type := get_instruction_type(id_instruction);
		if (first_instruction = '1') then
			first_instruction <= '0';
		else
      if (ex_mem_read = '1') THEN
        if(ex_rt_register /= "00000" and (id_instruction(25 downto 21) = ex_rt_register or id_instruction(20 downto 16) = ex_rt_register)) THEN
          pc_write  <= '0';
          idex_flush <= '1';
        end if;
      else
        -- for branching
        if (current_instruction_type = b_type) then
          -- if we're writing to the cpu reg and the destination is what we need for the branch, stall
          if(ex_reg_write = '1' and ex_mem_to_reg='0') then
            -- if last instruction was r type and the register is used in the branch, stall
            if(ex_rd_register /= "00000" and last_instruction_type = r_type and (id_instruction(25 downto 21) = ex_rd_register or id_instruction(20 downto 16) = ex_rd_register)) then
              pc_write  <= '0';
              idex_flush <= '1';
            end if;
            -- if last instruction was i type and the register is used in the branch, stall
            if(ex_rt_register /= "00000" and last_instruction_type = i_type and (id_instruction(25 downto 21) = ex_rt_register or id_instruction(20 downto 16) = ex_rt_register)) then
              pc_write  <= '0';
              idex_flush <= '1';
            end if;
          else
            pc_write  <= '1';
            idex_flush <= '0';
          end if;
        else
          pc_write  <= '1';
          idex_flush <= '0';
        end if;
		end if;
    last_instruction_type <= current_instruction_type;
  end if;
END PROCESS;

END arch;
