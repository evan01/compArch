library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cache_pkg.all;


entity write_controller is
    generic( ram_size : INTEGER := 32768);
    port(
    clock : in std_logic;
    reset : in std_logic;
    s_addr: in std_logic_vector(31 downto 0);
    s_write : in std_logic;
	s_writedata : in std_logic_vector (31 downto 0);
	s_waitrequest : out std_logic;
	cache_array: inout cache_type;
    mem_controller_wait: in std_logic;
	mem_controller_read: out std_logic;
	mem_controller_write: out std_logic;
	mem_controller_data: inout std_logic_vector(127 downto 0);
	mem_controller_addr: out std_logic_vector(31 downto 0)
    );
end write_controller;

architecture arch of write_controller is
-- TYPE CACHE IS ARRAY(31 downto 0) OF STD_LOGIC_VECTOR(135 DOWNTO 0);
-- signal cache_array: CACHE;


type  read_states is (idle, W, mem_write, mem_read, write_cache);  -- Define the states
signal state : read_states;
signal next_state : read_states;

signal tag: std_logic_vector(5 downto 0); --remaining bits up to 15th
signal index: std_logic_vector(4 downto 0); --next 5 bits
signal offset: std_logic_vector(3 downto 0); --Last 4 bits of address - 2 last
signal cache_row : std_logic_vector(135 downto 0);
signal m_waitrequest: std_logic := '0';
signal temp_data: std_logic_vector(127 downto 0);
signal new_cache_addr : std_logic_vector(31 downto 0);
signal block_number: integer := 0;
signal mem_rw_requested: std_logic := '0';

BEGIN
  
write_fsm : process(clock, reset)
    variable count :integer := 0;
BEGIN
    if (reset ='1') then
        state <= idle;
    elsif (rising_edge(clock)) then
        case state is
            when idle =>
              if (s_write = '1') then 
                next_state <= W;
            end if;

			when W =>
				tag <= s_addr(14 downto 9);
				index <= s_addr(8 downto 4);
				offset <= s_addr(3 downto 0);
				block_number <= to_integer(unsigned(s_addr(3 downto 2)));
				cache_row <= cache_array(to_integer(unsigned(index)));
				
				--Figure out if there is a match
				if cache_row(133 downto 128) = tag then
					next_state <= write_cache; --There is a match
				else
					--Check if dirty or not
					if(cache_row(134) = '1') then
						--Then it is dirty, write to mem, then read correct block, then  write to cache
						next_state <= mem_write; --No match
					else
						--Not dirty, so read the correct block to cache, then write
						next_state <= mem_read;
					end if;
				end if;

		    -- The location needed for the write is available in the cache
		    when write_cache =>
			
			   -- Write the data and tag and set the valid and the dirty bit
			   --cache_row(to_integer(unsigned(offset)) * 32 + 31) downto (to_integer(unsigned(offset))*32)) <= s_writedata(31 downto 0);	
			   cache_row(block_number*32+31 downto block_number*32 )<= s_writedata;
			   
			   --Set data,valid and tag
			   cache_row(134) <= '1';
			   cache_row(135) <= '1';
			   cache_row(133 downto 128) <= tag;
			
			next_state <= idle;
				s_waitrequest <= '0';
			   
			when mem_write =>
				--Tell the mem controller we want to write
				mem_controller_write <= '1';
				mem_controller_read <= '0';
					
				--Send details to mem controller
				mem_controller_addr <= "00000000000000000"&tag & index & offset;
				mem_controller_data <= cache_row(127 downto 0);

				--Only go to mem_read state if already written old cache data (CHECK IF OLD CACHE DATA)
				if(mem_controller_wait = '0' and mem_rw_requested ='1') then 
					mem_controller_write <= '0';
					mem_controller_read <= '0';
					next_state <= mem_read;
					mem_rw_requested <= '0';
				else
					mem_rw_requested <= '1';
				end if;
			      

			when mem_read =>
				--reads a block into the cache from memorty
				--Tell the mem controller we want to write
				mem_controller_write <= '0';
				mem_controller_read <= '1';
					
				--Send details to mem controller
				mem_controller_addr <= "00000000000000000"&tag & index & offset;


				--Only go to mem_read state
				if(mem_controller_wait = '0'and mem_rw_requested='1') then 
					mem_controller_write <= '0';
					mem_controller_read <= '0';
					
					--Write the new block to cache
					cache_row(133 downto 128) <= tag;
					cache_row(135 downto 134) <= "11"; --dirty and valid
					cache_row(127 downto 0) <= mem_controller_data;
					next_state <= write_cache;
					mem_rw_requested <= '0';
				else
					mem_rw_requested <= '1';
				end if;
		end case;

				end if;
					end process;
end arch;
