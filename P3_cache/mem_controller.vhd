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
		m_waitrequest : in std_logic; --this comes from memory! Can't interact with until low again
        m_readdata : in std_logic_vector (7 downto 0);
        
        --This goes to both the read and write controller
        mem_controller_wait: out std_logic;

        --These go towards the main memory
        m_addr : out integer range 0 to ram_size-1;
		m_read : out std_logic;
		m_write : out std_logic;
		m_writedata : out std_logic_vector (7 downto 0)
);
end mem_controller;

architecture arch of mem_controller is
signal mem_index : integer := 0;
type  mem_states is (I, MR, MW);  -- Define the states
signal state: mem_states := I;
begin

memory_comm : process(clock, reset)
variable var_mem_index: integer := mem_index;
variable var_mem_controller_data:  std_logic_vector (127 downto 0) := mem_controller_data;


--Evans changes
--variable idx: integer :=  mem_index;

begin
    if (reset ='1') then
        var_mem_index := 0;
		mem_controller_data <= (others => '0');
        m_read <='0';
        m_write <='0';
        m_addr <= 0;
        state <= I;
        m_writedata <= (others => '0');
        mem_controller_wait <= '0';
    elsif (rising_edge(clock)) then
        case state is
            when I =>
                if(mem_controller_read ='1' xor mem_controller_write ='1') then
                    --time to do a read or write, leave idle state
                    mem_controller_wait <= '1'; -- Set the mem controller signal to busy
                    var_mem_index := 0;
                    m_addr <= to_integer(unsigned(mem_controller_addr(14 downto 4) & "0000")) + var_mem_index;
                    
                    if(mem_controller_read = '1') then
                        --We will start reading
                        m_read <= '1';
                        m_write <= '0';
                        state <= MR;
                    else
                        --We will start writing
                        m_write <= '1';
                        m_read <= '0';
                        var_mem_controller_data := mem_controller_data;
                        m_writedata <= mem_controller_data( 7 downto 0);
                        state <= MW;
                    end if; 
                end if;

            when MR =>
                --We need to read 1 block from memory (16 bytes)
                if(m_waitrequest = '0') then --only read when available
                    --if not the first ever read, read the data that should be available
                    if(var_mem_index > 0) then
                        --We will shift our data 8 bits to the right, and read
                        m_read <='1';
                        var_mem_controller_data := std_logic_vector(shift_right(unsigned(var_mem_controller_data), 8));
                        var_mem_controller_data( 127 downto 120) := m_readdata;
                    elsif(var_mem_index > 16) then
                        --We are done
                        state <= I;
                        mem_controller_data <= var_mem_controller_data;
                        mem_controller_wait <= '0';
                    else
                        --This is our first read, read directly from m_readdata
                        m_read <='1';
                         var_mem_controller_data( 127 downto 120) := m_readdata;
                    end if;
                    
                   --Update our address
                   var_mem_index := var_mem_index + 1;
                   m_addr <= to_integer(unsigned(mem_controller_addr(14 downto 4) & "0000")) + var_mem_index;
                else
                    m_read <='0';
                end if;

            when MW =>
                --We need to write 1 block t0 memory (16 bytes)
                --We've already written the first byte by now
                if(m_waitrequest = '0') then
                    if(var_mem_index <= 16) then
                        --Get the next byte to write to memory
                        m_write <= '1';
                        var_mem_controller_data := std_logic_vector(shift_right(unsigned(var_mem_controller_data), 8));
                        m_writedata <= var_mem_controller_data( 7 downto 0);
                    else
                         --We are done
                        state <= I;
                        mem_controller_wait <= '0';
                    end if;
                    var_mem_index := var_mem_index + 1;
                    m_addr <= to_integer(unsigned(mem_controller_addr(14 downto 4) & "0000")) + var_mem_index;
                else
                    m_write <= '0';
                end if;
        end case;

        mem_index <= var_mem_index;
        mem_controller_data <= var_mem_controller_data;
    end if;

end process memory_comm;

end arch;
