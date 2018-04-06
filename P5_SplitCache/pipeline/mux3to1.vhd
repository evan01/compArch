library ieee;
use ieee.std_logic_1164.all;

entity mux3to1 is
port (
  sel : in  std_logic_vector(1 downto 0);
  --0 INPUT
  input_0  : in  std_logic_vector (31 downto 0);
  --1 INPUT
  input_1   : in  std_logic_vector (31 downto 0);
  --2 INPUT
  input_2   : in  std_logic_vector (31 downto 0);
  X   : out std_logic_vector (31 downto 0));
end mux3to1;

architecture arch of mux3to1 is
begin
  X <= input_0 when sel = "00" else
       input_1 when sel = "01" else
       input_2 when sel = "10" else
       (others => '0') when sel = "11";

end arch;
