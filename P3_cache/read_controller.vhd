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

ARCHITECTURE arch OF read_controller IS
type  read_states is (I, R, MR, MW, RP, D);  -- Define the states
signal state : read_states;

BEGIN

read_fsm : process(clock, reset)
variable var_hit: std_logic := '0';
variable var_valid: std_logic := '0';
variable var_dirty: std_logic := '0';
variable m_waitrequest: std_logic := '0';
BEGIN
    if (reset ='1') then
        state <= I;
    elsif (rising_edge(clock)) then
        case state is
            when I =>
                if (s_read = '1') then             
                    state <= R;
                end if;
            when R =>
                s_waitrequest <= '1';
                if (var_hit = '1') then
                    if (var_valid = '1') then
                        state <= D;
                    end if;
                else
                    if (var_valid = '1') then
                        if (var_dirty = '1') then
                            state <= MW;
                        else
                            state <= MR;
                        end if;
                    end if;
                end if;
            when D =>
                s_waitrequest <= '0';
                state <= I;
            when MW =>
                if (m_waitrequest = '1') then
                    state <= MW;
                else
                    state <= MR;
                end if;
            when MR =>
                if (m_waitrequest = '1') then
                    state <= MR;
                else
                    state <= RP;
                end if;
            when RP =>
                state <= D;
        end case;
    end if;

end process read_fsm;

end arch;
