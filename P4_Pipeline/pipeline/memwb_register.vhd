library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memwb_register is
port (
  clock: in std_logic;

  ------------------- Control Signals -------------------

  -- Write-back stage control lines
  memwb_in_reg_write: in std_logic;
  memwb_out_reg_write: out std_logic;
  memwb_in_mem_to_reg: in std_logic;
  memwb_out_mem_to_reg: out std_logic;

  ------------------- Registers and data -------------------

  memwb_in_memory_data: in std_logic_vector(31 downto 0);
  memwb_out_memory_data: out std_logic_vector(31 downto 0);

  memwb_in_alu_result: in std_logic_vector(31 downto 0);
  memwb_out_alu_result: out std_logic_vector(31 downto 0);

  -- Need to propagate through dest register for write instructions
  memwb_in_dest_register: in std_logic_vector(31 downto 0);
  memwb_out_dest_register: out std_logic_vector(31 downto 0)

 );
end memwb_register;

architecture arch of memwb_register is
begin

reg: process(clock)
begin
  if (rising_edge(clock)) then
    memwb_out_reg_write <= memwb_in_reg_write;
    memwb_out_mem_to_reg <= memwb_in_mem_to_reg;
    memwb_out_memory_data <= memwb_in_memory_data;
    memwb_out_alu_result <= memwb_in_alu_result;
    memwb_out_dest_register <= memwb_in_dest_register;
  end if;
end process;
end arch;
