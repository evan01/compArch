library ieee;
use ieee.std_logic_1164.all;

package cache_pkg is
  type cache_type is array(31 downto 0) of std_logic_vector(135 downto 0);
end package cache_pkg;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.cache_pkg.all;

entity cache is
generic( ram_size : INTEGER := 32768);
port(
	clock : in std_logic;
	reset : in std_logic;

	-- INPUT <-> CACHE--
	s_addr : in std_logic_vector (31 downto 0);
	s_read : in std_logic;
  s_write : in std_logic;
  s_writedata : in std_logic_vector (31 downto 0);

  s_waitrequest : out std_logic;
  s_readdata : out std_logic_vector (31 downto 0);

  --CACHE<->MEM
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
  s_readdata : out std_logic_vector(31 downto 0);
  s_waitrequest : out std_logic;
    cache_array: inout cache_type;
  --"internal" signals interfacing with mem_controller
  mem_controller_data: inout std_logic_vector(127 downto 0);
  mem_controller_addr: out std_logic_vector(14 downto 0);
  mem_controller_read : out std_logic;
  mem_controller_write: out std_logic;
  mem_controller_wait: in std_logic
);
end component;

component write_controller port(
    clock : in std_logic;
    reset : in std_logic;
    s_addr: in std_logic_vector(31 downto 0);
    s_write : in std_logic;
    s_writedata : in std_logic_vector (31 downto 0);
    s_waitrequest : out std_logic;
    cache_array: inout cache_type;
     --"internal" signals interfacing with mem_controller
    mem_controller_data: inout std_logic_vector(127 downto 0);
    mem_controller_addr: out std_logic_vector(14 downto 0);
    mem_controller_read : out std_logic;
    mem_controller_write: out std_logic;
    mem_controller_wait: in std_logic
);
end component;

component mem_controller port(
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
end component;

signal mem_controller_wait: std_logic;
signal mem_controller_read: std_logic;
signal mem_controller_write: std_logic;
signal mem_controller_data: std_logic_vector(127 downto 0);
signal mem_controller_addr: std_logic_vector(14 downto 0);
signal cache_array_signal: cache_type;
signal read_wait: std_logic:= '0';
signal write_wait: std_logic:= '0';

begin

    read_contr: read_controller PORT MAP(
        clock => clock,
        reset => reset,
        s_addr => s_addr,
        s_read => s_read,
        s_readdata => s_readdata,
        s_waitrequest => read_wait,
        cache_array=> cache_array_signal,
				mem_controller_read => mem_controller_read,
				mem_controller_write => mem_controller_write,
				mem_controller_addr => mem_controller_addr,
				mem_controller_data => mem_controller_data,
				mem_controller_wait => mem_controller_wait
     );

     write_contr: write_controller PORT MAP(
         clock => clock,
         reset => reset,
         s_addr => s_addr,
         s_write => s_write,
         s_writedata => s_writedata,
         s_waitrequest => write_wait,
         cache_array=> cache_array_signal,
				 mem_controller_read => mem_controller_read,
				 mem_controller_write => mem_controller_write,
				 mem_controller_addr => mem_controller_addr,
				 mem_controller_data => mem_controller_data,
				 mem_controller_wait => mem_controller_wait
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
          mem_controller_read => mem_controller_read,
          mem_controller_write => mem_controller_write,
          mem_controller_addr => mem_controller_addr,
					mem_controller_data => mem_controller_data,
          mem_controller_wait => mem_controller_wait
      );
-- make circuits here
    s_waitrequest <= read_wait or write_wait;
end arch;
