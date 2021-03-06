library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
 Port (
   clock : in std_logic;
   reset : in std_logic;
   pc_write : in std_logic := '1';
   input_address : in std_logic_vector (31 downto 0);
   output_address : out std_logic_vector(31 downto 0) := (others => '0')
   );
end program_counter;

architecture arch of program_counter is
begin

pc: process(clock)
begin
  if (reset = '1') then
    output_address <= (others => '0');
  elsif (rising_edge(clock)) then
    --Used to stall the current instruction
    if (pc_write = '1') then
      output_address <= input_address;
    end if;
  end if;
end process;
end arch;
