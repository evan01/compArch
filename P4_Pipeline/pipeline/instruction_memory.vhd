library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;
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
		pc : in std_logic_vector (31 downto 0);
		instruction_out: out std_logic_vector (31 downto 0) := (31 downto 6 => '0')&"100000"
	);
end instruction_memory;

architecture arch of instruction_memory is
	type mem is array(ram_size-1 downto 0) of std_logic_vector(31 downto 0);
	signal ram: mem;
	signal instructions_loaded : std_logic := '0';
begin
	mem_proc: process (clock)
	--The following code taken from https://stackoverflow.com/questions/20912683/how-to-simulate-memory-on-vhdl-test-bench
		file file_pointer: text;
		variable line_num: line;
		variable counter: integer := 0;
		variable data: std_logic_vector(31 downto 0);
	begin
		if (instructions_loaded = '0') then --INITIALIZE Memory to file!!
			for i in 0 to ram_size-1 loop
				ram(i) <= std_logic_vector(to_unsigned(0,32));
			end loop;
			
			file_open(file_pointer, "program.txt", READ_MODE);
			while not endfile(file_pointer) loop
				readline(file_pointer, line_num);
        		read(line_num, data);
				ram(counter) <= data;
				counter := counter + 1;
			end loop;
			file_close(file_pointer);
			instructions_loaded <= '1';
		end if;

		--Memory logic
		if(rising_edge(clock)) then
			if(to_integer(unsigned(pc)) < 8192) then
				instruction_out <= ram(to_integer(unsigned(pc))/4);
			end if;
		end if;

	end process;
end arch;

--MAKE SURE PC NEVER MORE THAN IM