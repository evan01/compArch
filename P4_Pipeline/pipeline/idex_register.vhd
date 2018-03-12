library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ifid_register is
port (
  clock: in std_logic;

  ------------------- Control Signals -------------------

  -- Execution/address calculation stage control lines
  idex_in_RegDst: in std_logic;
  idex_out_RegDst: out std_logic;
  idex_in_ALUOp1: in std_logic;
  idex_out_ALUOp1: out std_logic;
  idex_in_ALUOp0: in std_logic;
  idex_out_ALUOp0: out std_logic;
  idex_in_ALUSrc: in std_logic;
  idex_out_ALUSrc: out std_logic;

  --Memory access stage control lines
  idex_in_branch: in std_logic;
  idex_out_branch: out std_logic;
  idex_in_mem_read: in std_logic;
  idex_out_mem_read: out std_logic;
  idex_in_mem_write: in std_logic;
  idex_out_mem_write: out std_logic;

  -- Write-back stage control lines
  idex_in_reg_write: in std_logic;
  idex_out_reg_write: out std_logic;
  idex_in_mem_to_reg: in std_logic;
  idex_out_mem_to_reg: out std_logic;

  ------------------- Registers and data -------------------

  idex_in_operand_a: in std_logic_vector(31 downto 0);
  idex_out_operand_a: out std_logic_vector(31 downto 0);

  idex_in_operand_b: in std_logic_vector(31 downto 0);
  idex_out_operand_b: out std_logic_vector(31 downto 0);

  idex_in_sign_extend_imm: in std_logic_vector(31 downto 0);
  idex_out_sign_extend_imm: out std_logic_vector(31 downto 0);

  -- Used for forwarding, uncomment when ready
  -- idex_in_rs_register: in std_logic_vector(31 downto 0);
  -- idex_out_rs_register: out std_logic_vector(31 downto 0);

  -- Need to propagate through rd and rt to determine destination register on certain write instructions
  idex_in_rt_register: in std_logic_vector(31 downto 0);
  idex_out_rt_register: out std_logic_vector(31 downto 0);

  idex_in_rd_register: in std_logic_vector(31 downto 0);
  idex_out_rd_register: out std_logic_vector(31 downto 0)
 );
end ifid_register;

architecture arch of ifid_register is
begin

reg: process(clock)
begin
  if (rising_edge(clock)) then
    idex_out_RegDst <= idex_in_RegDst;
    idex_out_ALUOp1 <= idex_in_ALUOp1;
    idex_out_ALUOp0 <= idex_in_ALUOp0;
    idex_out_ALUSrc <= idex_in_ALUSrc;
    idex_out_branch <= idex_in_branch;
    idex_out_mem_read <= idex_in_mem_read;
    idex_out_mem_write <= idex_in_mem_write;
    idex_out_reg_write <= idex_in_reg_write;
    idex_out_mem_to_reg <= idex_in_mem_to_reg;
    idex_out_operand_a <= idex_in_operand_a;
    idex_out_sign_extend_imm <= idex_in_sign_extend_imm;
    idex_out_rt_register <= idex_in_rt_register;
    idex_out_rd_register <= idex_in_rd_register;
    idex_out_operand_a <= idex_in_operand_a;
    idex_out_operand_b <= idex_in_operand_b;
  end if;
end process;
end arch;
