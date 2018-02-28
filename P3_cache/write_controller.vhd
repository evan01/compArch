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
	mem_controller_addr: out std_logic_vector(14 downto 0)
    );
end write_controller;

architecture arch of write_controller is
-- TYPE CACHE IS ARRAY(31 downto 0) OF STD_LOGIC_VECTOR(135 DOWNTO 0);
-- signal cache_array: CACHE;


type  read_states is (I, W, MW, MR, WC, WAIT_CYCLE);  -- Define the states
signal state : read_states;

signal tag: std_logic_vector(5 downto 0); --remaining bits up to 15th
signal index: std_logic_vector(4 downto 0); --next 5 bits
signal offset: std_logic_vector(3 downto 0); --Last 4 bits of address - 2 last
signal cache_row : std_logic_vector(135 downto 0) := (others => '0');
signal block_number: integer := 0;
signal mem_rw_requested: std_logic := '0';

--Wait counters setup
signal last_state: read_states;
signal wait_counter: integer := 0;

BEGIN
  
write_fsm : process(clock, reset)
	variable count :integer := 0;
	variable var_wait_counter: integer := wait_counter;

BEGIN
    if (reset ='1') then
        state <= I;
    elsif (rising_edge(clock)) then
        case state is
            when I =>
			  if (s_write = '1') then 
			  	s_waitrequest <= '1';
				state <= W;
				else
					s_waitrequest <= '0';
				end if;

			when W =>
				tag <= s_addr(14 downto 9);
				index <= s_addr(8 downto 4);
				offset <= s_addr(3 downto 0);
				block_number <= to_integer(unsigned(s_addr(3 downto 2)));
				cache_row <= cache_array(to_integer(unsigned(index)));
				
				--Figure out if there is a match
				if cache_row(133 downto 128) = tag then
					state <= WC; --There is a match
				else
					--Check if dirty or not
					if(cache_row(134) = '1') then
						--Then it is dirty, write to mem, then read correct block, then  write to cache
						state <= MW; --No match
					else
						--Not dirty, so read the correct block to cache, then write
						state <= MR;
					end if;
				end if;

		    -- The location needed for the write is available in the cache
		    when WC => --WRITES 1 BLOCK to cache
			
				-- Write the data and tag and set the valid and the dirty bit
				--cache_row(to_integer(unsigned(offset)) * 32 + 31) downto (to_integer(unsigned(offset))*32)) <= s_writedata(31 downto 0);	
				cache_row(block_number*32+31 downto block_number*32 )<= s_writedata;
				
				--Set data,valid and tag
				cache_row(134) <= '1';
				cache_row(135) <= '1';
				cache_row(133 downto 128) <= tag;
				
				--Place whole block back in cache.
				cache_array(to_integer(unsigned(index))) <= cache_row;

				state <= I;
				s_waitrequest <= '0';
			   
			when MW =>
				--Tell the mem controller we want to write
				mem_controller_write <= '1';
				mem_controller_read <= '0';
					
				--Send details to mem controller
				mem_controller_addr <= tag & index & offset;
				mem_controller_data <= cache_row(127 downto 0);

				--Only go to mem_read state if already written old cache data (CHECK IF OLD CACHE DATA)
				if(mem_rw_requested = '1' and mem_controller_wait ='0') then
					mem_controller_write <= '0';
					mem_controller_read <= '0';
					state <= MR;
					mem_rw_requested <= '0';
				else
					if(mem_controller_wait ='1') then
					mem_rw_requested <= '1';
				end if;
				end if;
			      

			when MR =>
				--reads a block into the cache from memory
				
				if(mem_rw_requested = '1') then 
					-- When we get to here, we should ready have the data, just write the block to cache
					cache_row(127 downto 0) <= mem_controller_data;
					state <= WC;
					mem_controller_read <= '0';
					mem_rw_requested <= '0';
				else
					mem_controller_addr <= tag & index & offset;
					mem_controller_write <= '0';
					mem_controller_read <= '1';
					mem_rw_requested <= '1';
					last_state <= MR;
					state <= WAIT_CYCLE;
				end if;
			when WAIT_CYCLE =>
				if(mem_controller_wait ='0' and wait_counter > 1) then
					state <= last_state;
					var_wait_counter := 0;
				else
					var_wait_counter := wait_counter + 1;
				end if;
		end case;
		wait_counter <= var_wait_counter;			
	end if;
end process;
end arch;
