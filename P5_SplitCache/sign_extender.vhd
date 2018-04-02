library ieee;
use ieee.std_logic_1164.all;

entity sign_extender is
port (
  input_16  : in  STD_LOGIC_VECTOR (15 downto 0);
  output_32   : out STD_LOGIC_VECTOR (31 downto 0));
end sign_extender;

architecture arch of sign_extender is
begin

output_32(15 downto 0) <= input_16;
output_32(31 downto 16) <= (31 downto 16 => input_16(15));

end arch;
