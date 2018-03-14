LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_unsigned.all;

ENTITY hazard_detection IS
	PORT (
		in_instruction : IN std_logic_vector (31 DOWNTO 0);
		stall : OUT std_logic;
		out_instruction : OUT std_logic_vector (31 DOWNTO 0)
	);
END hazard_detection;
ARCHITECTURE arch OF hazard_detection IS

	SIGNAL mem_instruction, ex_instruction, id_instruction, if_instruction : std_logic_vector (31 DOWNTO 0);

BEGIN
	operation : PROCESS (if_instruction, id_instruction, ex_instruction, mem_instruction)
	BEGIN
	  -- Keeping a track of the last 4 instructions and updating them as they come in
		mem_instruction <= ex_instruction;
		ex_instruction <= id_instruction;
		id_instruction <= if_instruction;
		if_instruction <= in_instruction (31 DOWNTO 0);

    -- If load was an instruction 3 insttructions ago, insert stall
		IF (mem_instruction(31 DOWNTO 26) = 100011) THEN
			stall <= '1';
			out_instruction <= (OTHERS => '0');

		ELSE
			stall <= '0';
			out_instruction <= in_instruction;
 
		END IF;

	END PROCESS operation;

END arch;