library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;
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
		write_data_to_file: in std_logic;
		address : in std_logic_vector (31 downto 0);
		writedata: in std_logic_vector (31 downto 0); --instead of using alu result, just use forwarded val.
		readdata: out std_logic_vector (31 downto 0)
	);
end data_memory;

architecture arch of data_memory is
	type mem is array(ram_size-1 downto 0) of std_logic_vector(31 downto 0);
	signal ram: mem;
	signal output_file_written: std_logic := '0';
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
				ram(to_integer(unsigned(address))) <= writedata;
			end if;

			if(memread = '1') then
				readdata<= ram(to_integer(unsigned(address)));
			end if;
		end if;

	end process;

	write_data:process (write_data_to_file)
	    file memory_file_pointer: text;
		variable memory_line: line;
	begin
		if(output_file_written = '0' and write_data_to_file = '1') then
		 file_open(memory_file_pointer, "memory.txt", WRITE_MODE);
            for i in 0 to ram_size-1 loop
                --Write the data to the line
                write(memory_line, ram(i)); 
                --Write the line to the file
                writeline(memory_file_pointer, memory_line);
            end loop;
		file_close(memory_file_pointer);
		output_file_written <= '1';
		end if;
	end process;
end arch;