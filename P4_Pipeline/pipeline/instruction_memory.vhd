library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--NOTE, the majority of this code is taken from the Quartus Design and Synthesis handbook
--as well as the faculty of Engineering at McGill University, Computer Architecture Course

entity instruction_memory is 
	generic(
		-- ram_size : INTEGER := 32768;
		ram_size : integer := 8192; --This is in WORDS
		clock_period : time := 1 ns
	);
	port(
		clock: in std_logic;
		memwrite: in std_logic;
		pc : in integer range 0 to 8192-1;
		writedata: in std_logic_vector (31 downto 0); --instead of using alu result, just use forwarded val.
		instruction_out: out std_logic_vector (31 downto 0)
	);
end instruction_memory;

architecture arch of instruction_memory is
	type mem is array(ram_size-1 downto 0) of std_logic_vector(31 downto 0);
	signal ram: mem;
begin
	mem_proc: process (clock)
	begin
		
		if (now < 1 ps) then --INITIALIZE Memory TO ALL 0's
			for i in 0 to ram_size-1 loop
				ram(i) <= std_logic_vector(to_unsigned(0,32));
			end loop;
		end if;

		--Memory logic
		if(rising_edge(clock)) then
			if(memwrite ='1') then
				ram(pc) <= writedata;
			else
				instruction_out <= ram(pc);
			end if;
		end if;

	end process;
end arch;