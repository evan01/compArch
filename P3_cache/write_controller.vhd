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
    
    m_addr : out integer range 0 to ram_size -1;
    m_read : out std_logic;
    m_write : out std_logic;
    m_writedata : out std_logic_vector(7 downto 0);
    );
end write_controller;

architecture arch of write_controller is
TYPE CACHE IS ARRAY(31 downto 0) OF STD_LOGIC_VECTOR(127 DOWNTO 0);
signal cache_array: CACHE;


type  state_type is (idle, W, mem_write, mem_read, write_cache);  -- Define the states
signal state : read_states;
signal next_state : read_states;

signal tag: std_logic_vector(7 downto 0);
signal index: std_logic_vector(4 downto 0);
signal offset: std_logic_vector(1 downto 0);
signal cache_row : std_logic_vecor(137 downto 0);
signal m_waitrequest: std_logic := '0';
signal temp_data: std_logic_vector(127 downto 0);
signal new_cache_addr : std_logic_vector(31 downto 0);

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
            
            
        
        when W is =>
            tag <= s_addr(14 downto 7);
            index <= s_addr(6 downto 2);
            offset <= s_addr(1 downto 0);
            cache_row <= cache(to_integer(unsigned(index)));
            
       			if cache_row(152 downto 128) = tag then
				      next_state <= write_cache;
			
		    	   -- If it is valid but not a match
			     elsif cache_row(135 downto 128) /= tag and cache_row(137) = '1'  then
				      next_state <= mem_write;
			
			     -- Have to write something to the cache and the current data in that location is not dirty			
			     else
				      next_state <= mem_read;

			end if;
			
			
		    -- The location needed for the write is available in the cache
		    when write_cache =>
			
			   -- Write the data and tag and set the valid and the dirty bit
			   cache_row(to_integer(unsigned(offset)) * 32 + 31) downto (to_integer(unsigned(offset))*32)) <= s_writedata(31 downto 0);	
			   
			   cache_row(137) <= '1';
			   cache_row(136) <= '1';
			   
			   cache_row(to_integer(unsigned(index))) <= cache_row;
			   
			   s_waitrequest <= '0';
			   next_state <= idle;
			   
			   
			   when mem_write =>
			     if count < 4
			           m_write <= '1';
			           m_read <= '0';
			           new_cache_addr <= cache_row(135 downto 128);
			           new_cache_addr <= "00";
			           new_cache_addr <= index;
			     
			           m_addr <= (to_integer(unsigned(new_cache_addr));
			           m_writedata <= cache(index)(127 downto 0) ((count * 8) + 7 + 32*offset downto  (count * 8) + 32*offset);   
			           count := count + 1;
			           
			      elsif count = 4    
			         next_state <= mem_read;
			      end if;   
			      

			   when mem_read =>
			       count := 0;
			       s_waitrequest <= '0';
			       m_write <= '0';
			       cache_row(127 downto 0) <= s_writedata(31 downto 0);
			       cache_row(135 downto 128) <= tag;
			       cache_row(137 downto 136) <= "01";
		        	cache(to_integer(unsigned(index)) <= cache_row;

				    next_state <= write_cache;
			     

end case;

end arch;
