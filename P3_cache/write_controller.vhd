library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity write_controller is
    generic( ram_size : INTEGER := 32768);
    port(
    clock : in std_logic;
    reset : in std_logic;
    s_addr: in std_logic_vector(31 downto 0);
    s_write : in std_logic;
	s_writedata : in std_logic_vector (31 downto 0);
    s_waitrequest : out std_logic
    );
end write_controller;

architecture arch of write_controller is

BEGIN


end arch;
