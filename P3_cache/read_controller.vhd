library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity read_controller is
    generic( ram_size : INTEGER := 32768);
    port(
    clock : in std_logic;
    reset : in std_logic;
    s_addr: in std_logic_vector(31 downto 0);
    s_read : in std_logic;
	s_readdata : out std_logic_vector (31 downto 0);
    s_waitrequest : out std_logic
    );
end read_controller;

architecture arch of read_controller is

BEGIN


end arch;
