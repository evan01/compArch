library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache is
generic(
	ram_size : INTEGER := 32768
);
port(
	clock : in std_logic;
	reset : in std_logic;

	-- Avalon interface --
	s_addr : in std_logic_vector (31 downto 0);
	s_read : in std_logic;
	s_readdata : out std_logic_vector (31 downto 0);
	s_write : in std_logic;
	s_writedata : in std_logic_vector (31 downto 0);
	s_waitrequest : out std_logic;

	m_addr : out integer range 0 to ram_size-1;
	m_read : out std_logic;
	m_readdata : in std_logic_vector (7 downto 0);
	m_write : out std_logic;
	m_writedata : out std_logic_vector (7 downto 0);
	m_waitrequest : in std_logic
);
end cache;

architecture arch of cache is
  type  CACHE_STATES is (I, R, W, MR, MW, MWAIT);  -- Define the states
  signal state : CACHE_STATES := I;
  signal cache_block: std_logic_vector(135 downto 0):= (others => '0');
  signal block_byte_index: integer :=0;
  signal has_waited : std_logic := '0';
  type cache_array_type is array(31 downto 0) of std_logic_vector(135 downto 0);
  signal cache_array: cache_array_type;
  signal last_state: CACHE_STATES := I;

begin

cache : process(clock, reset)
  variable tag: std_logic_vector(5 downto 0); --remaining bits up to 15th
  variable index: std_logic_vector(4 downto 0); --next 5 bits
  variable offset: std_logic_vector(1 downto 0); --Last 4 bits of address - 2 last
  variable var_cache_block: std_logic_vector(135 downto 0) := cache_block;
  variable var_block_byte_index: integer := block_byte_index;
  variable valid : std_logic;
  variable dirty : std_logic;
begin
  if (reset = '1') then
    state <= I;
  elsif(rising_edge(clock)) then
    case state is
      when I =>
        if (s_read = '1') then --xor this
          s_waitrequest <= '1';
          state <= R;
        elsif (s_write = '1') then
          s_waitrequest <= '1';
          state <= W;
        else
          s_waitrequest <= '0';
          state <= I;
        end if;
      when R =>
        offset := s_addr(3 downto 2);
        index := s_addr(8 downto 4);
        tag := s_addr(14 downto 9);

        var_cache_block := cache_array(to_integer(unsigned(index)))(135 downto 0);

        valid := var_cache_block(135);
        dirty := var_cache_block(134);

        --check validity
        if(valid = '1') then
            --check for cache hit
            if (var_cache_block(133 downto 128) = tag) then --Hit
                s_readdata <= var_cache_block(31 + to_integer(unsigned(offset)) * 32 downto 0 + 32 * to_integer(unsigned(offset)));
                s_waitrequest <= '0';
                state <= I;
            else
                --Miss
              if (dirty = '1') then
                --if dirty, write cache block to mem then fetch block from memory
                last_state <= R;
                state <= MW;
              else
                --if clean, directly fetch from memory
                last_state <= R;    
                state <= MR;
              end if;
            end if;
        else
            --if invalid, then fetch block from memory
          last_state <= R;  
          state <= MR;
        end if;
      when W =>
        offset := s_addr(3 downto 2);
        index := s_addr(8 downto 4);
        tag := s_addr(14 downto 9);
        var_cache_block := cache_array(to_integer(unsigned(index)));
        valid := var_cache_block(135);
        dirty := var_cache_block(134);

        if(valid = '1') then --the block we want to write to, is maybe in the cache
           if (var_cache_block(133 downto 128) = tag) then --HIT
               -- Write to the correct word in cache block
              var_cache_block(31 + to_integer(unsigned(offset)) * 32 downto 0 + 32 * to_integer(unsigned(offset))) := s_writedata;

              --Set dirty, valid and tag
              var_cache_block(134) := '1'; --dirty
              var_cache_block(133 downto 128) := tag;
              
              --Place whole block back in cache.
              cache_array(to_integer(unsigned(index))) <= var_cache_block;

              state <= I;
              s_waitrequest <= '0';
           else
               --Miss
               --if dirty, write cache block to mem then fetch block from memory
               if (dirty = '1') then
                  last_state <= W;
                  state <= MW;
               else
               --if clean, directly fetch from memory
                  last_state <= W;
                  state <= MR;
               end if;
           end if;
       else
          --if invalid, then fetch block from memory
          state <= MR;
       end if;

      when MW =>
        --Need to write 16 bytes to the cache, our cache block
        m_write <= '1';
        m_addr <= to_integer(unsigned(std_logic_vector'(var_cache_block(133 downto 123) & "0000"))) + var_block_byte_index;
        m_writedata <= cache_block((var_block_byte_index*8 + 7) downto var_block_byte_index*8);
        
        var_block_byte_index := var_block_byte_index + 1;
        
        if(var_block_byte_index >= 16) then 
          --We're done writing block, set 
          var_block_byte_index := 0;
          m_write <= '0';
          state <= MR;
        end if;
      when MR =>
        if(var_block_byte_index < 16) then
          if (has_waited = '0') then
            -- We haven't requested the data yet
            m_addr <= to_integer(unsigned(std_logic_vector'(s_addr(14 downto 4) & "0000"))) + var_block_byte_index;
            m_read <= '1';
            state <= MWAIT;
          else
            -- The data is available
            m_read <= '0';
            cache_block((var_block_byte_index*8 + 7) downto var_block_byte_index*8) <= m_readdata;
            var_block_byte_index := var_block_byte_index + 1;
            has_waited <= '0';
          end if;
        else
          --We are done reading
          m_read <= '0';
          var_block_byte_index := 0;
          has_waited <= '0';
          var_cache_block(134) := '0'; --dirty bit is now clean
          var_cache_block(135) := '1'; --data is valid

          --Place whole block back in cache.
          index := s_addr(8 downto 4);
          cache_array(to_integer(unsigned(index))) <= var_cache_block;

          state <= last_state;
        end if;
      when MWAIT =>
        if (m_waitrequest = '0') then
          has_waited <= '1';
          state <= MR;
        end if;
    end case;

  end if;

  cache_block <= var_cache_block;
  block_byte_index <= var_block_byte_index;

end process cache;



end arch;
