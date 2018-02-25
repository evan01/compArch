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
TYPE CACHE IS ARRAY(31 downto 0) OF STD_LOGIC_VECTOR(127 DOWNTO 0);
signal cache_array: CACHE;
type  read_states is (I, R, MR, MW, RP, D);  -- Define the states
signal state : read_states;
signal hit: std_logic := '0';
signal valid: std_logic := '0';
signal dirty: std_logic := '0';
signal m_waitrequest: std_logic := '0';
signal temp_data: std_logic_vector(127 downto 0);


BEGIN


read_fsm : process(clock, reset)
variable offset: integer := 0;
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
                if (hit = '1') then
                    if (valid = '1') then
                        state <= D;
                    end if;
                else
                    if (valid = '1') then
                        if (dirty = '1') then
                            state <= MW;
                        else
                            state <= MR;
                        end if;
                    else
                        state <= MR;
                    end if;
                end if;
            when D =>
                offset := to_integer(unsigned(s_addr(6 downto 0)));
                if(offset + 32 > 125) then
                    --TODO: handle offset
                else
                    s_readdata <= temp_data(offset+32 downto offset);
                end if;
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
END process read_fsm;


compare : process(clock)
BEGIN
    if (state = R) then
        For i in 0 to 31 LOOP
            if (cache_array(i)(125 downto 123) = s_addr(15 downto 13)) then
                hit <= '1';
                dirty <= cache_array(i)(126);
                valid <= cache_array(i)(127);
                temp_data <= cache_array(i);
            end if;
        END LOOP;
    end if;

END process compare;

END arch;
