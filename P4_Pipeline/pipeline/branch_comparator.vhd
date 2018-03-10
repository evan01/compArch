library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity branch_controller is
port (
  -- Control signal dictating whether instruction is branch
  branch: in std_logic;
  -- register 1
  operand_a : in std_logic_vector(31 downto 0);
  -- register 2
  operand_b : in std_logic_vector(31 downto 0);
  -- The actual alu operation
  alu_opcode : in std_logic_vector (4 downto 0);
  branch_taken : out std_logic := '0'
);
end branch_controller;

architecture arch of branch_controller is
begin

zero_calc: process (operand_a, operand_b)
variable take_branch : std_logic;
begin
  case alu_opcode is
    when "10110" =>
      -- beq
      if(unsigned(operand_a) = unsigned(operand_b)) then
        take_branch := '1';
      else
        take_branch := '0';
      end if;
    when "10111" =>
      -- bneq
      if(unsigned(operand_a) = unsigned(operand_b)) then
        take_branch := '0';
      else
        take_branch := '1';
      end if;
    when others =>
      take_branch := '1';
  end case;

  branch_taken <= take_branch and branch;
end process;
end arch;
