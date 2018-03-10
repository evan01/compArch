library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity byte_adder is
 Port (
   input_address : in std_logic_vector(31 downto 0);
   output_address : out std_logic_vector(31 downto 0)
 );
end byte_adder;

architecture arch of byte_adder is
begin
output_address <= std_logic_vector(to_unsigned(to_integer(unsigned(input_address)) + 4, 32));
end arch;
