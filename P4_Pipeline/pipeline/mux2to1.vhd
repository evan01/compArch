library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux2to1 is
    Port ( sel : in  STD_LOGIC;
          --0 INPUT
           input_0  : in  STD_LOGIC_VECTOR (31 downto 0);
           --1 INPUT
           input_1   : in  STD_LOGIC_VECTOR (31 downto 0);
           X   : out STD_LOGIC_VECTOR (31 downto 0));
end mux2to1;

architecture arch of mux2to1 is
begin
    X <= input_0 when (sel = '0') else input_1;
end arch;
