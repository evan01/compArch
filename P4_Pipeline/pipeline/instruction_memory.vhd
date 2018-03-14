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
		reset: in std_logic;
		memwrite: in std_logic := '0';
		pc : in std_logic_vector (31 downto 0);
		writedata: in std_logic_vector (31 downto 0); --instead of using alu result, just use forwarded val.
		instruction_out: out std_logic_vector (31 downto 0)
	);
end instruction_memory;

architecture arch of instruction_memory is
	type mem is array(ram_size-1 downto 0) of std_logic_vector(31 downto 0);
	signal ram: mem;
begin
	mem_proc: process (clock)
	--The following code taken from https://stackoverflow.com/questions/20912683/how-to-simulate-memory-on-vhdl-test-bench
		file in_file: text open read_mode is "instructions.txt";
		variable line_str: line;
		variable address: std_logic_vector(31 downto 0);
		variable data: std_logic_vector(31 downto 0);
	begin
		if (now < 1 ps) then --INITIALIZE Memory to file!!
			-- for i in 0 to ram_size-1 loop
			-- 	ram(i) <= std_logic_vector(to_unsigned(0,32));
			-- end loop;
			readline(in_file, line_str);
			hread(line_str, address);
			starting_pc <= address;
			while not endfile(in_file) loop
				readline(in_file, line_str);
        		hread(line_str, address);
        		read(line_str, data);
        		ram(to_integer(unsigned(address))) <= data;
        		report "Initialized " & integer'image(to_integer(unsigned(address))) & " to " & 
              		integer'image(to_integer(unsigned(data)));
			end loop;
		end if;

		--Memory logic
		if(rising_edge(clock)) then
			if(memwrite ='1') then
				ram(to_integer(unsigned(pc))) <= writedata;
			else
				instruction_out <= ram(to_integer(unsigned(pc)));
			end if;
		end if;

	end process;
end arch;