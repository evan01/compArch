LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_unsigned.all;

ENTITY forwarding_unit IS
	PORT (
		forwardA: OUT std_logic_vector (1 downto 0);
		forwardB: OUT std_logic_vector (1 downto 0);
		ex_mem_regwrite: IN std_logic;
		mem_wb_regwrite: IN std_logic;
		ex_mem_rd: IN std_logic_vector (4 downto 0);
		id_ex_rs: IN std_logic_vector (4 downto 0); 
		id_ex_rt: IN std_logic_vector (4 downto 0);
		mem_wb_rd: IN std_logic_vector (4 downto 0)
	);
END forwarding_unit;
ARCHITECTURE arch OF forwarding_unit IS

BEGIN
	operation : PROCESS (ex_mem_regwrite, mem_wb_regwrite, ex_mem_rd, id_ex_rs, id_ex_rt, mem_wb_rd)
	BEGIN
	  --EX Hazard
	  if (ex_mem_regwrite = '1') and (ex_mem_rd /= "00000") and (ex_mem_rd = id_ex_rs) then
	  	forwardA <= "10";
	  else
	  	forwardA <= "00";
	  end if;

	  if (ex_mem_regwrite = '1') and (ex_mem_rd /= "00000") and (ex_mem_rd = id_ex_rt) then
	  	forwardB <= "10";
	  else
	  	forwardB <= "00";
	  end if;

	  --MEM Hazard
	  if (mem_wb_regwrite = '1') and (mem_wb_rd /= "00000") and not (ex_mem_regwrite = '1' and ex_mem_rd /= "00000") 
	  	and (ex_mem_rd /= id_ex_rs) and (mem_wb_rd = id_ex_rs) then
	  	forwardA <= "01";
	  else
	  	forwardA <= "00";
	  end if;

	  if (mem_wb_regwrite = '1') and (mem_wb_rd /= "00000") and not (ex_mem_regwrite = '1' and ex_mem_rd /= "00000") 
	  	and (ex_mem_rd /= id_ex_rt) and (mem_wb_rd = id_ex_rt) then
	  	forwardB <= "01";
	  else
	  	forwardB <= "00";
	  end if;

		
	END PROCESS operation;

END arch;