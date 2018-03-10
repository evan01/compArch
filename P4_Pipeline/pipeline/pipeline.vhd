library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline is
 port (
   clk : in std_logic;
   reset : in std_logic
   );
end pipeline;

architecture arch of pipeline is

------------------------- IF STAGE -------------------------
component program_counter is
 port (
   clk : in std_logic;
   reset : in std_logic;
   input_address : in std_logic_vector (31 downto 0) := (others => '0');
   output_address : out std_logic_vector(31 downto 0) := (others => '0')
   );
end component;

component mux2to1 is
    port ( sel : in  STD_LOGIC;
           input_0  : in  STD_LOGIC_VECTOR (31 downto 0);
           input_1   : in  STD_LOGIC_VECTOR (31 downto 0);
           X   : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component byte_adder is
 port (
   input_address : in std_logic_vector(31 downto 0);
   output_address : out std_logic_vector(31 downto 0)
 );
end component;

signal pc_output_address: std_logic_vector(31 downto 0);
signal pc_input_address: std_logic_vector(31 downto 0);
signal incremented_pc_address: std_logic_vector(31 downto 0);
signal branch_address: std_logic_vector(31 downto 0);
signal pc_sel: std_logic;
------------------------- IF STAGE -------------------------

begin

------------------------- IF STAGE -------------------------
  pc: program_counter PORT MAP(
    clk => clk,
    reset => reset,
    input_address => pc_input_address,
    output_address => pc_output_address
  );

  pc_input_mux : mux2to1 PORT MAP(
    sel => pc_sel,
    input_0 => incremented_pc_address,
    input_1 => branch_address,
    X => pc_input_address
  );

  pc_incrementer: byte_adder PORT MAP(
    input_address => pc_output_address,
    output_address => incremented_pc_address
  );
------------------------- IF STAGE -------------------------

end arch;
