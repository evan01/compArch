library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--NOTE, the majority of this code is taken from the Quartus Design and Synthesis handbook
--as well as the faculty of Engineering at McGill University, Computer Architecture Course

entity data_memory is 
	generic(
		-- ram_size : INTEGER := 32768;
		ram_size : integer := 8192; --This is in WORDS
		clock_period : time := 1 ns	
	);
	port(
		clock: in std_logic;
		memwrite: in std_logic;
		memread: in std_logic;
		address : in integer;
		writedata: in std_logic_vector (31 downto 0); --instead of using alu result, just use forwarded val.
		readdata: out std_logic_vector (31 downto 0)
	);
end data_memory;

architecture arch of data_memory is
	type mem is array(ram_size-1 downto 0) of std_logic_vector(31 downto 0);
	signal ram: mem;
begin
	mem_proc:process (clock)
	begin
		--INITIALIZE Memory TO ALL 0's
		if (now < 1 ps) then
			for i in 0 to ram_size-1 loop
				ram(i) <= std_logic_vector(to_unsigned(0,32));
			end loop;
		end if;

		--Memory logic
		if(rising_edge(clock)) then
			if(memwrite ='1') then
				ram(address) <= writedata;
			end if;

			if(memread = '1') then
				readdata<= ram(address);
			end if;
		end if;

	end process;
end arch;