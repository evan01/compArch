library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_controller is
generic( ram_size : INTEGER := 32768);
port(
	clock : in std_logic;
	reset : in std_logic;
    s_read: in std_logic;
    s_write: in std_logic;

    s_addr : in std_logic_vector (31 downto 0);
    m_waitrequest : in std_logic;
    s_writedata : in std_logic_vector (31 downto 0);
    m_readdata : in std_logic_vector (7 downto 0);

    s_readdata : out std_logic_vector (31 downto 0);
    mem_controller_wait: out std_logic;
    m_addr : out integer range 0 to ram_size-1;
	m_read : out std_logic;
	m_write : out std_logic;
	m_writedata : out std_logic_vector (7 downto 0)
);
end mem_controller;

architecture arch of mem_controller is
signal mem_index : integer := 0;
type  mem_states is (S1, S2, S3);  -- Define the states
signal state: mem_states;
signal temp_data : std_logic_vector (31 downto 0);
begin

memory_comm : process(clock, reset)
variable var_mem_index: integer := mem_index;
variable var_temp_data:  std_logic_vector (31 downto 0) := temp_data;
begin
    if (reset ='1') then
        var_mem_index := 0;
        s_readdata <= (others => '0');
    elsif (rising_edge(clock)) then
        case state is
            when S1 =>
                -- Update the mem address to the byte we want to update
                m_addr <= to_integer(unsigned(s_addr(14 downto 2) & "00")) + var_mem_index;
                -- Set the mem controller signal busy
                mem_controller_wait <= '1';
                -- Shift temp data to prepare for new input
                if (s_read = '1') then
                    m_read <= '1';
                    if (var_mem_index = 0) then
                        var_temp_data := (others => '0');
                    else
                        var_temp_data := std_logic_vector(shift_right(unsigned(var_temp_data), 8));
                    end if;
                elsif (s_write = '1') then
                    m_write <= '1';
                    if (var_mem_index = 0) then
                        var_temp_data := s_writedata;
                    else
                        var_temp_data := std_logic_vector(shift_right(unsigned(var_temp_data), 8));
                    end if;
                    m_writedata <= var_temp_data(7 downto 0);

                end if;
                state <= S2;
            when S2 =>
                if( m_waitrequest = '0') then
                    state <= S3;
                end if;
            when S3 =>
                if (s_read = '1') then
                    m_read <= '0';
                    s_readdata( 31 downto 23) <= m_readdata;
                elsif (s_write = '1') then
                    m_write <= '0';
                end if;

                var_mem_index := var_mem_index + 1;

                if (var_mem_index >= 4) then
                    -- We've processed the entire word
                    var_mem_index := 0;
                    mem_controller_wait <= '0';
                    s_readdata <= var_temp_data;
                end if;
        end case;

        mem_index <= var_mem_index;
        temp_data <= var_temp_data;
    end if;

end process memory_comm;

end arch;
