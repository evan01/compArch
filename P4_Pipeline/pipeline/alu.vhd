library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
 port (
   operand_a : in std_logic_vector (31 downto 0);
   operand_b : in std_logic_vector (31 downto 0);
   alu_opcode : in std_logic_vector (4 downto 0);
   result : out std_logic_vector(31 downto 0)
 );
end alu;

--Rules
-- Operand a is always a register
-- Operand b is a register, offset,  jump address, immediate etc.
-- Assume that any 16 bit immediate in operand b is always sign extended

architecture arch of alu is

signal hi, lo : std_logic_vector(31 downto 0);
begin
operation : process(operand_a, operand_b, alu_opcode)
variable temp : std_logic_vector(63 downto 0);
begin
  case alu_opcode is
    when "00000" =>
      -- add
      result <= std_logic_vector(to_signed(to_integer(signed(operand_a)) + to_integer(signed(operand_b)), result'length));
    when "00001" =>
      -- sub
      result <= std_logic_vector(to_signed(to_integer(signed(operand_a)) - to_integer(signed(operand_b)), result'length));
    when "00010" =>
      -- addi
      result <= std_logic_vector(to_signed(to_integer(signed(operand_a)) + to_integer(signed(operand_b)), result'length));
    when "00011" =>
      -- mult
      temp <=  std_logic_vector(to_signed(to_integer(signed(operand_a)) * to_integer(signed(operand_b)), temp'length));
      hi <= temp(63 downto 32);
      lo <= temp(31 downto 0);
      result <= lo;
    when "00100" =>
      -- div
      lo <= std_logic_vector(to_signed(to_integer(signed(operand_a)) / to_integer(signed(operand_b)), lo'length));
      hi <= std_logic_vector(to_signed(to_integer(signed(operand_a)) mod to_integer(signed(operand_b)), hi'length));
      result <= lo;
    when "00101" =>
      -- slt
      if (signed(operand_a) < signed(operand_b)) then
        result <= std_logic_vector(to_signed(1, result'length));
      else
      result <= (others => '0');
      end if;
    when "00110" =>
      -- slti
      if (signed(operand_a) < signed(operand_b)) then
        result <= std_logic_vector(to_signed(1, result'length));
      else
      result <= (others => '0');
      end if;
    when "00111" =>
      -- and
      result <= operand_a and operand_b;
    when "01000" =>
      -- or
      result <= operand_a or operand_b;
    when "01001" =>
      -- nor
      result <= operand_a nor operand_b;
    when "01010" =>
      -- xor
      result <= operand_a xor operand_b;
    when "01011" =>
      -- andi
      -- Need to zero extend andi according to MIPS data sheet
      result <= operand_a and ((31 downto 16 => '0') & operand_b(15 downto 0));
    when "01100" =>
      -- ori
      -- Need to zero extend ori according to MIPS data sheet
      result <= operand_a or ((31 downto 16 => '0') & operand_b(12 downto 0));
    when "01101" =>
      -- xori
      -- Need to zero extend xori according to MIPS data sheet
      result <= operand_a xor ((31 downto 16 => '0') & operand_b(15 downto 0));
    when "01110" =>
      -- mfhi
      result <= hi;
    when "01111" =>
      -- mflo
      result <= lo;
    when "10000" =>
      -- lui
      result <= operand_b(15 downto 0) & std_logic_vector(to_unsigned(0, 16));
    when "10001" =>
      -- sll
      result <= std_logic_vector(signed(operand_a) sll to_integer(unsigned(operand_b)));
    when "10010" =>
      -- srl
      result <= std_logic_vector(signed(operand_a) srl to_integer(unsigned(operand_b)));
    when "10011" =>
      -- sra
      result <= to_stdlogicvector(to_bitvector(operand_a) sra to_integer(signed(operand_b)));
    when "10100" =>
      -- lw
      -- Offset is in operand_b and is sign extended
      result <= std_logic_vector(to_unsigned(to_integer(unsigned(operand_a)) + to_integer(signed(operand_b)), result'length));
    when "10101" =>
      -- sw
      -- Offset is in operand_b and is sign extended
      result <= std_logic_vector(to_unsigned(to_integer(unsigned(operand_a)) + to_integer(signed(operand_b)), result'length));
    when "10110" =>
      -- beq
      -- operand_a is pc + 4, operand_b is sign extended offset shifted 2 bits
      --calculates the branch address
      result <= std_logic_vector(to_signed(to_integer(signed(operand_a)) + to_integer(signed(operand_b) sll 2), result'length));
    when "10111" =>
      -- bne
      -- operand_a is pc + 4, operand_b is sign extended offset shifted 2 bits
      --calculates the branch address
      result <= std_logic_vector(to_signed(to_integer(signed(operand_a)) + to_integer(signed(operand_b) sll 2), result'length));
    when "11000" =>
      -- j
      -- Make sure the current address is in operand a, the 26 bit offset in operand b
      --Take the 4 msb from the incremented PC address, add to 26 bit offset shifted by 2 bits
      result <= operand_a(31 downto 28) & operand_b(25 downto 0) & "00";
    when "11001" =>
      -- jr
      -- Jump to address specified in register (operand_a)
      result <= operand_a;
    when "11010" =>
      -- jal
      -- Make sure the incremented pc address  is in operand a, the 26 bit offset in operand b
      --Take the 4 msb from the PC address, add to 26 bit offset shifted by 2 bits
      result <= operand_a(31 downto 28) & operand_b(25 downto 0) & "00";
    when others =>
      NULL;
  end case;
end process operation;



end arch;
