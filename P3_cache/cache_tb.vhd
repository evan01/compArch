library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache_tb is
end cache_tb;

architecture behavior of cache_tb is

component cache is
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
end component;

component memory is
GENERIC(
    ram_size : INTEGER := 32768;
    mem_delay : time := 10 ns;
    clock_period : time := 1 ns
);
PORT (
    clock: IN STD_LOGIC;
    writedata: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    address: IN INTEGER RANGE 0 TO ram_size-1;
    memwrite: IN STD_LOGIC;
    memread: IN STD_LOGIC;
    readdata: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    waitrequest: OUT STD_LOGIC
);
end component;

-- test signals
signal reset : std_logic := '0';
signal clk : std_logic := '0';
constant clk_period : time := 2 ns;

signal s_addr : std_logic_vector (31 downto 0);
signal s_read : std_logic;
signal s_readdata : std_logic_vector (31 downto 0);
signal s_write : std_logic;
signal s_writedata : std_logic_vector (31 downto 0);
signal s_waitrequest : std_logic;

signal m_addr : integer range 0 to 2147483647;
signal m_read : std_logic;
signal m_readdata : std_logic_vector (7 downto 0);
signal m_write : std_logic;
signal m_writedata : std_logic_vector (7 downto 0);
signal m_waitrequest : std_logic;

signal error_signal: std_logic;


-- ADDRESSES AND TEST VALUES. Last 2 bits redundant
CONSTANT ADDRESS_0 : std_logic_vector(14 downto 0) := "000000000000000";
CONSTANT ADDRESS_1 : std_logic_vector(14 downto 0) := "001010100001100";
CONSTANT ADDRESS_2 : std_logic_vector(14 downto 0) := "101010100000000"; --address 2 has the same INDEX as addr1

CONSTANT DATA_8 : std_logic_vector(31 downto 0) := "00000000000000000000000000001000"; --8
CONSTANT DATA_21 : std_logic_vector(31 downto 0) := "00000000000000000000000000010101"; --21

begin

-- Connect the components which we instantiated above to their
-- respective signals.
dut: cache
port map(
    clock => clk,
    reset => reset,

    s_addr => s_addr,
    s_read => s_read,
    s_readdata => s_readdata,
    s_write => s_write,
    s_writedata => s_writedata,
    s_waitrequest => s_waitrequest,

    m_addr => m_addr,
    m_read => m_read,
    m_readdata => m_readdata,
    m_write => m_write,
    m_writedata => m_writedata,
    m_waitrequest => m_waitrequest
);

MEM : memory
port map (
    clock => clk,
    writedata => m_writedata,
    address => m_addr,
    memwrite => m_write,
    memread => m_read,
    readdata => m_readdata,
    waitrequest => m_waitrequest
);

-- CLOCK DRIVER
clk_process : process
begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
end process;


test_process : process

procedure sanityTestRW is --DONE
begin
    --Do a blank write to the cache
    s_addr <= (31 downto 15 => '0') & ADDRESS_1;
    s_read <= '0';
    s_write <= '1';
    s_writedata <= DATA_8;
    WAIT FOR clk_period;
    if(s_waitrequest = '0' ) then
        REPORT "1 >> Wait request sould be set high" SEVERITY ERROR;
        error_signal <= '1';
    end if;
    
    WAIT until s_waitrequest = '0';

    --Then read from the cache the thing we just wrote
    s_read <= '1';
    s_write <= '0';
    WAIT FOR clk_period*2;
    if(s_waitrequest = '0' ) then
        REPORT "2 >> Wait request sould be set high" SEVERITY ERROR;
        error_signal <= '1';
    end if;
    WAIT until s_waitrequest = '0';
     if(s_readdata /= DATA_8) then
        REPORT "3 >> Cache returned the incorrect read data" SEVERITY ERROR;
        error_signal <= '1';
    end if;
    
    reset<= '1';
    WAIT for clk_period*4;
end procedure;

--WRITE TESTS
procedure write_match_clean_valid is --FIX ASSERTION
--No write to mem, dirty bit set internally
begin
    
    s_read <= '0';
    s_write <= '1';
    s_writedata <= DATA_21;
    s_addr <= (31 downto 15 => '0') & ADDRESS_1;
    WAIT FOR clk_period/2;
    ASSERT (s_waitrequest = '1') REPORT "Wait request should be set high" SEVERITY ERROR;
    WAIT until s_waitrequest = '0';

    --ASERTION TEST, need to check that dirty bit is set?
    --ASSERT (s_readdata = DATA_8) REPORT "Cache returned the incorrect read data" SEVERITY ERROR;
    s_read <= '0';
    s_write <= '0';
    reset <= '1';
    WAIT for clk_period*4;

end procedure;

procedure write_mismatch_clean_valid is --FIX ASSERTION
--No write to memory, because data is clean
begin
    --To set up this test you need to read to the cache location, then write to same location with dif tag
    --Just need to write to the same area in the cache twice. (NO WRITES TO MEMORY)
    s_read <= '1';
    s_write <= '0';
    s_addr <= (31 downto 15 => '0') & ADDRESS_1;
    WAIT FOR clk_period/2;
    ASSERT (s_waitrequest = '1') REPORT "Wait request should be set high" SEVERITY ERROR;
    WAIT until s_waitrequest = '0';

     --Just need to write to the same area in the cache twice.
    s_read <= '0';
    s_write <= '1';
    s_writedata <= DATA_8;
    s_addr <= (31 downto 15 => '0') & ADDRESS_2;
    WAIT FOR clk_period/2;
    ASSERT (s_waitrequest = '1') REPORT "Wait request should be set high" SEVERITY ERROR;
    WAIT until s_waitrequest = '0';

    --ASERTION TEST
    --ASSERT (s_readdata = DATA_8) REPORT "Cache returned the incorrect read data" SEVERITY ERROR;
    s_read <= '0';
    s_write <= '0';
    reset <= '1';
    WAIT for clk_period*4;
end procedure;

procedure write_match_dirty_valid is -- FIX ASSERTION
-- No write to memory, just overwrite cache data
begin
    --Just write to the cache twice for this to happen
    s_read <= '0';
    s_write <= '1';
    s_writedata <= DATA_8;
    s_addr <= (31 downto 15 => '0') & ADDRESS_2;
    WAIT FOR clk_period/2;
    ASSERT (s_waitrequest = '1') REPORT "Wait request should be set high" SEVERITY ERROR;
    WAIT until s_waitrequest = '0';

    s_writedata <= DATA_21;
    s_addr <= (31 downto 15 => '0') & ADDRESS_2;
    WAIT FOR clk_period/2;
    ASSERT (s_waitrequest = '1') REPORT "Wait request should be set high" SEVERITY ERROR;
    WAIT until s_waitrequest = '0';

    --ASERTION TEST
    --ASSERT (s_readdata = DATA_8) REPORT "Cache returned the incorrect read data" SEVERITY ERROR;
    s_read <= '0';
    s_write <= '0';
    reset <= '1';
    WAIT for clk_period*4;
end procedure;

procedure write_mismatch_dirty_valid is -- FIX ASSERTION
--Write old cache val to mem, load new cache value into cache, overwrite cache data
begin
    --To set up this test you need to read to the cache location, then write to same location
    --Then you need to write again with a different tag.
    s_read <= '1';
    s_write <= '0';
    s_addr <= (31 downto 15 => '0') & ADDRESS_1;
    WAIT FOR clk_period/2;
    ASSERT (s_waitrequest = '1') REPORT "Wait request should be set high" SEVERITY ERROR;
    WAIT until s_waitrequest = '0';

    s_read <= '0';
    s_write <= '1';
    s_writedata <= DATA_8;
    s_addr <= (31 downto 15 => '0') & ADDRESS_1;
    WAIT FOR clk_period/2;
    ASSERT (s_waitrequest = '1') REPORT "Wait request should be set high" SEVERITY ERROR;
    WAIT until s_waitrequest = '0';

     --Just need to write to the same area in the cache twice.
    s_read <= '0';
    s_write <= '1';
    s_writedata <= DATA_8;
    s_addr <= (31 downto 15 => '0') & ADDRESS_2;
    WAIT FOR clk_period/2;
    ASSERT (s_waitrequest = '1') REPORT "Wait request should be set high" SEVERITY ERROR;
    WAIT until s_waitrequest = '0';

    --ASERTION TEST
    --ASSERT (s_readdata = DATA_8) REPORT "Cache returned the incorrect read data" SEVERITY ERROR;
    s_read <= '0';
    s_write <= '0';
    reset <= '1';
    WAIT for clk_period*4;
end procedure;

--READ TESTS
procedure seed_memory_with_data is
--Should write to memory and the cache!!!2
begin
    for i in 0 to 30 loop --Write to 30 slots in the cache
        --s_addr = 17reduntantbits & 3tag bits $ 5 index bits $ 7 offset bits
        s_addr <= (31 downto 15 => '0') & std_logic_vector(to_unsigned(3,i mod 3))  & std_logic_vector(to_unsigned(5,i)) & "0010000";
        --s_writedata <= --needs a standard logic vector
        WAIT for clk_period/2;
        WAIT until m_waitrequest = '0';
    end loop;
end procedure;

--MEMORY DUMP FOR TESTING PURPOSES

procedure read_match_clean_valid is 
--Read directly from cache, no memory access
begin
    
    s_read <= '1';
    s_write <= '0';
    s_addr <= (31 downto 15 => '0') & ADDRESS_1; -- Should have
    WAIT FOR clk_period/2;
    ASSERT (s_waitrequest = '1') REPORT "Wait request should be set high" SEVERITY ERROR;
    WAIT until s_waitrequest = '0';

    --ASERTION TEST
    ASSERT (s_readdata = DATA_8) REPORT "Cache returned the incorrect read data" SEVERITY ERROR;
    s_read <= '0';
    s_write <= '0';
    reset <= '1';
    WAIT for clk_period*4;

end procedure;

procedure read_mismatch_clean_valid is 
--Replace cache with propper memory, then read from cache
begin
    --Assuming that the wrong block is in the cache...
    s_read <= '1';
    s_write <= '0';
    s_addr <= (31 downto 15 => '0') & ADDRESS_1;
    WAIT FOR clk_period/2;
    ASSERT (s_waitrequest = '1') REPORT "Wait request should be set high" SEVERITY ERROR;
    WAIT until s_waitrequest = '0';

    --
    s_read <= '0';
    s_write <= '1';
    s_writedata <= DATA_8;
    s_addr <= (31 downto 15 => '0') & ADDRESS_1;
    WAIT FOR clk_period/2;
    ASSERT (s_waitrequest = '1') REPORT "Wait request should be set high" SEVERITY ERROR;
    WAIT until s_waitrequest = '0';

    --ASERTION TEST
    ASSERT (s_readdata = DATA_8) REPORT "Cache returned the incorrect read data" SEVERITY ERROR;
    s_read <= '0';
    s_write <= '0';
    reset <= '1';
    WAIT for clk_period*4;
end procedure;

procedure read_match_dirty_valid is --DONE
--Read directly from cache, no memory access
begin
    --First write to an address in the cache to make a bit dirty
    s_read <= '0';
    s_write <= '1';
    s_writedata <= DATA_8;
    s_addr <= (31 downto 15 => '0') & ADDRESS_2;
    WAIT FOR clk_period/2;
    ASSERT (s_waitrequest = '1') REPORT "Wait request should be set high" SEVERITY ERROR;
    WAIT until s_waitrequest = '0';

    --Then read from that same adress
    s_read <= '1';
    s_write <= '0';
    s_addr <= (31 downto 15 => '0') & ADDRESS_2;
    WAIT FOR clk_period/2;
    ASSERT (s_waitrequest = '1') REPORT "Wait request should be set high" SEVERITY ERROR;
    WAIT until s_waitrequest = '0';

    --ASERTION TEST: Check that the address read back is the right one
    ASSERT (s_readdata = DATA_8) REPORT "Cache returned the incorrect read data" SEVERITY ERROR;
    s_read <= '0';
    s_write <= '0';
    reset <= '1';
    WAIT for clk_period*4;
end procedure;

procedure read_mismatch_dirty_valid is  --DONE
--Write the dirty cache values back to memory, replace cache with propper mem, then read from cache
begin
     --First write to an address in the cache to make a section dirty
    s_read <= '0';
    s_write <= '1';
    s_writedata <= DATA_8;
    s_addr <= (31 downto 15 => '0') & ADDRESS_2;
    WAIT FOR clk_period/2;
    ASSERT (s_waitrequest = '1') REPORT "Wait request should be set high" SEVERITY ERROR;
    WAIT until s_waitrequest = '0';

    --Then read from a different address with the same index
    s_read <= '1';
    s_write <= '0';
    s_addr <= (31 downto 15 => '0') & ADDRESS_1;
    WAIT FOR clk_period/2;
    ASSERT (s_waitrequest = '1') REPORT "Wait request should be set high" SEVERITY ERROR;
    WAIT until s_waitrequest = '0';

    --ASERTION TEST: Check that the address read back is the right one
    ASSERT (s_readdata /= DATA_8) REPORT "Cache returned the incorrect read data" SEVERITY ERROR;
    s_read <= '0';
    s_write <= '0';
    reset <= '1';
    WAIT for clk_period*4;
end procedure;

procedure read_match_clean_invalid is --FIGURE OUT ASSERTION.
-- Read from memory into cache, then read from cache
begin
    s_read <= '1';
    s_write <= '0';
    s_addr <= (31 downto 15 => '0') & ADDRESS_1;
    WAIT FOR clk_period/2;
    ASSERT (s_waitrequest = '1') REPORT "Wait request should be set high" SEVERITY ERROR;
    WAIT until s_waitrequest = '0';

    --ASERTION TEST: Check that the address read back is the right one
    ASSERT (s_readdata /= DATA_8) REPORT "Cache returned the incorrect read data" SEVERITY ERROR;
    s_read <= '0';
    s_write <= '0';
    reset <= '1';
    WAIT for clk_period*4;

end procedure;

begin
--Run all of the procedures here.
sanityTestRW; --TEST a siiple read and write of an integer.

write_match_clean_valid;
write_mismatch_clean_valid;
write_match_dirty_valid;
write_mismatch_dirty_valid;
--FOR THESE TESTS< SEED THE MEMORY WITH DATA.
seed_memory_with_data;

read_match_clean_valid;
read_mismatch_clean_valid;
read_match_dirty_valid;
read_mismatch_dirty_valid;
read_match_clean_invalid;

end process;

end;

--TEST REQUIREMENTS
--      1. MAKE SURE THAT CACHE WORKS WITH AVALON
--      2.  