library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_controller is
generic( ram_size : INTEGER := 32768);
port(
		clock : in std_logic;
		reset : in std_logic;
    mem_controller_read: in std_logic;
    mem_controller_write: in std_logic;
    mem_controller_addr : in std_logic_vector (14 downto 0);

		mem_controller_data :inout std_logic_vector (127 downto 0);

		m_waitrequest : in std_logic;
		m_readdata : in std_logic_vector (7 downto 0);
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
begin

memory_comm : process(clock, reset)
variable var_mem_index: integer := mem_index;
variable var_mem_controller_data:  std_logic_vector (127 downto 0) := mem_controller_data;
begin
    if (reset ='1') then
        var_mem_index := 0;
				mem_controller_data <= (others => '0');
        m_read <='0';
        m_write <='0';
        m_addr <= 0;
        m_writedata <= (others => '0');
        mem_controller_wait <= '0';
        case state is
            when S1 =>
                -- Update the mem address to the byte we want to update
                m_addr <= to_integer(unsigned(mem_controller_addr(14 downto 4) & "0000")) + var_mem_index;
                -- Set the mem controller signal busy
                mem_controller_wait <= '1';

                if (s_read = '1') then
                    m_read <= '1';
                    if (var_mem_index = 0) then
                        var_mem_controller_data := (others => '0');
                    end if;
                elsif (s_write = '1') then
                    m_write <= '1';
                    if (var_mem_index = 0) then
                        var_mem_controller_data := s_writedata;
                    end if;
                    m_writedata <= var_mem_controller_data(7 downto 0);
                end if;
								-- Shift mem controller data
								var_mem_controller_data := std_logic_vector(shift_right(unsigned(var_mem_controller_data), 8));
                state <= S2;
            when S2 =>
                if( m_waitrequest = '0') then
                    state <= S3;
                end if;
            when S3 =>
                if (s_read = '1') then
                    m_read <= '0';
										-- Read the memory data into the top part of the mem controller data
                    var_mem_controller_data( 127 downto 119) <= m_readdata;
                elsif (s_write = '1') then
                    m_write <= '0';
                end if;

                var_mem_index := var_mem_index + 1;

                if (var_mem_index >= 16) then
                    -- We've processed the entire block, finished
                    var_mem_index := 0;
                    mem_controller_wait <= '0';
                end if;
								state <= S1;
        end case;

        mem_index <= var_mem_index;
        mem_controller_data <= var_mem_controller_data;
    end if;

end process memory_comm;

end arch;
