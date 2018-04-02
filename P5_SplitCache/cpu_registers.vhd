library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity cpu_registers is
 Port (
   clock : in std_logic;
   reset : in std_logic;
   write_registers_to_file: in std_logic;
   read_register_1 : in std_logic_vector (4 downto 0);
   read_register_2 : in std_logic_vector (4 downto 0);
   write_register : in std_logic_vector (4 downto 0);
   write_data : in std_logic_vector (31 downto 0);
   read_data_1 : out std_logic_vector (31 downto 0);
   read_data_2 : out std_logic_vector (31 downto 0);
   regwrite : in std_logic := '0'
   );
end cpu_registers;

architecture arch of cpu_registers is
type register_array_type is array(31 downto 0) of std_logic_vector(31 downto 0);
signal register_array: register_array_type;
signal output_file_written: std_logic := '0';

begin

cpu_registers_process: process(clock)
begin
  IF(now < 1 ps)THEN
				register_array(0) <= (others => '0');
	end if;


  if (reset = '1') then
     register_array <= (others => (others => 'U'));
  elsif (falling_edge(clock)) then
    read_data_1 <= register_array(to_integer(unsigned(read_register_1)));
    read_data_2 <= register_array(to_integer(unsigned(read_register_2)));
  elsif(rising_edge(clock)) then
    if (regwrite = '1' and (write_register/="00000")) then
      register_array(to_integer(unsigned(write_register))) <= write_data;
    end if;
  end if;

end process cpu_registers_process;

write_register_data:process (write_registers_to_file)
	  file register_file_pointer: text;
		variable register_line: line;
	  begin
		if(output_file_written = '0' and write_registers_to_file = '1') then
		 file_open(register_file_pointer, "register_file.txt", WRITE_MODE);
            for i in 0 to 31 loop
                --Write the data to the line
                write(register_line, register_array(i)); 
                --Write the line to the file
                writeline(register_file_pointer, register_line);
            end loop;
		file_close(register_file_pointer);
		output_file_written <= '1';
		end if;
	end process;

end arch;