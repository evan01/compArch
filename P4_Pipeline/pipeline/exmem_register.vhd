library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exmem_register is
port (
  clock: in std_logic;

  ------------------- Control Signals -------------------

  --Memory access stage control lines
  exmem_in_branch: in std_logic;
  exmem_out_branch: out std_logic;
  exmem_in_mem_read: in std_logic;
  exmem_out_mem_read: out std_logic;
  exmem_in_mem_write: in std_logic;
  exmem_out_mem_write: out std_logic;

  -- Write-back stage control lines
  exmem_in_reg_write: in std_logic;
  exmem_out_reg_write: out std_logic;
  exmem_in_mem_to_reg: in std_logic;
  exmem_out_mem_to_reg: out std_logic;

  ------------------- Registers and data -------------------

  exmem_in_alu_result: in std_logic_vector(31 downto 0);
  exmem_out_alu_result: out std_logic_vector(31 downto 0);

  exmem_in_mem_write_data: in std_logic_vector(31 downto 0);
  exmem_out_mem_write_data: out std_logic_vector(31 downto 0);

  -- Need to propagate through dest register for write instructions
  exmem_in_dest_register: in std_logic_vector(31 downto 0);
  exmem_out_dest_register: out std_logic_vector(31 downto 0)

 );
end exmem_register;

architecture arch of exmem_register is
begin

reg: process(clock)
begin
  if (rising_edge(clock)) then
    exmem_out_branch <= exmem_in_branch;
    exmem_out_mem_read <= exmem_in_mem_read;
    exmem_out_mem_write <= exmem_in_mem_write;
    exmem_out_reg_write <= exmem_in_reg_write;
    exmem_out_mem_to_reg <= exmem_in_mem_to_reg;
    exmem_out_mem_write_data <= exmem_in_mem_write_data;
    exmem_out_dest_register <= exmem_in_dest_register;
  end if;
end process;
end arch;
