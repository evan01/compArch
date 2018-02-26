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
constant clk_period : time := 1 ns;

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


-- ADDRESSES AND TEST VALUES. Last 2 bits redundant
CONSTANT ADDRESS_0 : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
CONSTANT ADDRESS_1 : std_logic_vector(31 downto 0) := "00000000000000000000000110000000";
CONSTANT ADDRESS_2 : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
CONSTANT ADDRESS_3 : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
CONSTANT ADDRESS_4 : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
CONSTANT ADDRESS_5 : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

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

procedure sanityTestRW is 
begin
    s_addr <= ADDRESS_0;
    s_read <= '0';
    s_write <= '1';
    s_writedata <= DATA_8;
    WAIT FOR clk_period/2;
    ASSERT (s_waitrequest = '1') REPORT "Wait request should be set high" SEVERITY ERROR;
    WAIT until s_waitrequest = '0';
    s_read <= '1';
    s_write <= '0';
    WAIT FOR clk_period;
    ASSERT (s_waitrequest = '1') REPORT "Wait request should be set high" SEVERITY ERROR;
    WAIT until s_waitrequest = '0';
    ASSERT (s_readdata = DATA_8) REPORT "Cache returned the incorrect read data" SEVERITY ERROR;
    s_read <= '0';
    s_write <= '1';
    ASSERT (s_waitrequest = '0') REPORT "Wait request should be set low" SEVERITY ERROR;
    WAIT for clk_period*4;
end procedure;

--WRITE TESTS
procedure write_match_clean_valid is 
begin
    --Only difference is that there should be a dirty bit set internally
    s_read <= '0';
    s_write <= '1';
    s_writedata <= DATA_21;
    s_addr <= ADDRESS_1;
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

procedure write_mismatch_clean_valid is 
begin
    --Just write, no memory change!!!!

    --Just need to write to the same area in the cache twice.
    s_read <= '0';
    s_write <= '1';
    s_writedata <= DATA_21;
    s_addr <= ADDRESS_1;
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

procedure write_match_dirty_valid is 
begin
    s_read <= '0';
    s_write <= '1';
end procedure;

procedure write_mismatch_dirty_valid is 
begin
    s_read <= '0';
    s_write <= '1';
end procedure;

procedure write_match_clean_invalid is --Not so relevant
begin
    s_read <= '0';
    s_write <= '1';
end procedure;

--READ TESTS
procedure read_match_clean_valid is 
begin
end procedure;

procedure read_mismatch_clean_valid is 
begin
end procedure;

procedure read_match_dirty_valid is 
begin
end procedure;

procedure read_mismatch_dirty_valid is 
begin
end procedure;

procedure read_match_clean_invalid is --Relevant
begin
end procedure;

begin
--Run all of the procedures here.
sanityTestRW; --TEST a siiple read and write of an integer.

write_match_clean_valid;
write_mismatch_clean_valid;
write_match_dirty_valid;
write_mismatch_dirty_valid;
write_match_clean_invalid;
read_match_clean_valid;
read_mismatch_clean_valid;
read_match_dirty_valid;
read_mismatch_dirty_valid;
read_match_clean_invalid;
std.env.stop(0);

end process;

end;

--TEST REQUIREMENTS
--      1. MAKE SURE THAT CACHE WORKS WITH AVALON
--      2.  