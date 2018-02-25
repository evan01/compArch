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

--mem signals, should be handled by mem_controller
signal m_waitrequest: std_logic := '0';
signal m_writedata: std_logic_vector(7 downto 0);
signal m_readdata: std_logic_vector(7 downto 0);
signal m_write: std_logic := '0';
signal m_read: std_logic := '0';

signal cache_index: integer;
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
                --not too sure about this part
                offset := to_integer(unsigned(s_addr(6 downto 0)));
                s_readdata <= cache_array(cache_index)(offset+32 downto offset);
                s_waitrequest <= '0';
                state <= I;
            when MW =>
                m_writedata <= temp_data(7 downto 0);
                m_write <= '1';
                --not too sure about which byte to send
                if (m_waitrequest = '1') then
                    state <= MW;
                else
                    m_write <= '0';
                    state <= MR;
                end if;
            when MR =>
                m_read <= '1';
                if (m_waitrequest = '1') then
                    state <= MR;
                else
                    m_read <= '0';
                    state <= RP;
                end if;
            when RP =>
                cache_array(cache_index)(7 downto 0) <= m_readdata;
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
                --temp_data <= cache_array(i);
                cache_index <= i;
            end if;
        END LOOP;
    end if;

END process compare;

END arch;
