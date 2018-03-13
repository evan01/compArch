library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_registers is
 Port (
   clock : in std_logic;
   reset : in std_logic;
   read_register_1 : in std_logic_vector (4 downto 0);
   read_register_2 : in std_logic_vector (4 downto 0);
   write_register : in std_logic_vector (4 downto 0);
   write_data : in std_logic_vector (31 downto 0);
   read_data_1 : out std_logic_vector (31 downto 0);
   read_data_2 : out std_logic_vector (31 downto 0);
   regwrite : in std_logic := '0';
   regread : in std_logic := '0'
   );
end cpu_registers;

architecture arch of cpu_registers is
type register_array_type is array(31 downto 0) of std_logic_vector(31 downto 0);
signal register_array: register_array_type;
begin

cpu_registers_process: process(clock)
begin
  if (reset = '1') then
     register_array <= (others => (others => '0'));
  elsif (rising_edge(clock)) then
    if (regread = '1') then
      read_data_1 <= register_array(to_integer(unsigned(read_register_1)));
      read_data_2 <= register_array(to_integer(unsigned(read_register_2)));
    end if;
  elsif(falling_edge(clock)) then
    if (regwrite = '1') then
      register_array(to_integer(unsigned(write_register))) <= write_data;
    end if;
  end if;

end process cpu_registers_process;

end arch;
