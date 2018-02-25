library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache is
generic( ram_size : INTEGER := 32768);
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

    m_readdata : in std_logic_vector (7 downto 0);
    m_waitrequest : in std_logic;
	m_addr : out integer range 0 to ram_size-1;
	m_read : out std_logic;
	m_write : out std_logic;
	m_writedata : out std_logic_vector (7 downto 0)
);
end cache;

architecture arch of cache is

-- declare signals here
component read_controller port(
    clock : in std_logic;
    reset : in std_logic;
    s_addr: in std_logic_vector(31 downto 0);
    s_read : in std_logic;
    s_readdata : out std_logic_vector (31 downto 0);
    s_waitrequest : out std_logic
);
end component;

component write_controller port(
    clock : in std_logic;
    reset : in std_logic;
    s_addr: in std_logic_vector(31 downto 0);
    s_write : in std_logic;
    s_writedata : in std_logic_vector (31 downto 0);
    s_waitrequest : out std_logic
);
end component;

component mem_controller port(
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
end component;

begin

    read_contr: read_controller PORT MAP(
        clock => clock,
        reset => reset,
        s_addr => s_addr,
        s_read => s_read,
        s_readdata => s_readdata,
        s_waitrequest => s_waitrequest
     );

     write_contr: write_controller PORT MAP(
         clock => clock,
         reset => reset,
         s_addr => s_addr,
         s_write => s_write,
         s_writedata => s_writedata,
         s_waitrequest => s_waitrequest
      );

      mem_contr: mem_controller PORT MAP(
          clock => clock,
          reset => reset,
          m_addr => m_addr,
          m_read => m_read,
          m_readdata => m_readdata,
          m_write => m_write,
          m_writedata => m_writedata,
          m_waitrequest => m_waitrequest,
          s_read => s_read,
          s_write => s_write,
          s_addr => s_addr,
          s_writedata => s_writedata,
          s_readdata => s_readdata
      );
-- make circuits here

end arch;
