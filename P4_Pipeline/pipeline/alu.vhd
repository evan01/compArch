library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
 Port ( operand_a : in std_logic_vector (31 downto 0);
 operand_b : in std_logic_vector (31 downto 0);
 opcode : in std_logic_vector (4 downto 0);
 result : out std_logic_vector(31 downto 0));
end alu;

architecture arch of alu is

signal hi, lo : std_logic_vector(31 downto 0);
signal temp : std_logic_vector(63 downto 0);
begin
operation : process(operand_a, operand_b, opcode)
begin
  case opcode is
    when "00000" =>
      -- add
      result <= std_logic_vector(to_unsigned(to_integer(unsigned(operand_a)) + to_integer(unsigned(operand_b)), result'length));
    when "00001" =>
      -- sub
      result <= std_logic_vector(to_unsigned(to_integer(unsigned(operand_a)) - to_integer(unsigned(operand_b)), result'length));
    when "00010" =>
      -- addi
      result <= std_logic_vector(to_unsigned(to_integer(unsigned(operand_a)) + to_integer(unsigned(operand_b)), result'length));
    when "00011" =>
      -- mult
      temp <=  std_logic_vector(to_unsigned(to_integer(unsigned(operand_a)) * to_integer(unsigned(operand_b)), temp'length));
      hi <= temp(63 downto 32);
      lo <= temp(31 downto 0);
      result <= lo;
    when "00100" =>
      -- div
      lo <= std_logic_vector(to_unsigned(to_integer(unsigned(operand_a)) / to_integer(unsigned(operand_b)), lo'length));
      hi <= std_logic_vector(to_unsigned(to_integer(unsigned(operand_a)) mod to_integer(unsigned(operand_b)), hi'length));
      result <= lo;
    when "00101" =>
      -- slt
      if (unsigned(operand_a) < unsigned(operand_b)) then
        result <= std_logic_vector(to_unsigned(1, result'length));
      else
      result <= (others => '0');
      end if;
    when "00110" =>
      -- slti
      if (unsigned(operand_a) < unsigned(operand_b)) then
        result <= std_logic_vector(to_unsigned(1, result'length));
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
      result <= operand_a and operand_b;
    when "01100" =>
      -- ori
      result <= operand_a and operand_b;
    when "01101" =>
      -- xori
      result <= operand_a xor operand_b;
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
      result <= std_logic_vector(unsigned(operand_a) sll to_integer(unsigned(operand_b)));
    when "10010" =>
      -- srl
      result <= std_logic_vector(unsigned(operand_a) srl to_integer(unsigned(operand_b)));
    when "10011" =>
      -- sra
      result <= to_stdlogicvector(to_bitvector(operand_a) sra to_integer(unsigned(operand_b)));
    when "10100" =>
      -- lw
      result <= std_logic_vector(to_unsigned(to_integer(unsigned(operand_a)) + to_integer(unsigned(operand_b)), result'length));
    when "10101" =>
      -- sw
      result <= std_logic_vector(to_unsigned(to_integer(unsigned(operand_a)) + to_integer(unsigned(operand_b)), result'length));
    when "10110" =>
      -- beq
      result <= std_logic_vector(to_unsigned(to_integer(unsigned(operand_a)) + to_integer(unsigned(operand_b)), result'length));
    when "10111" =>
      -- bne
      result <= std_logic_vector(to_unsigned(to_integer(unsigned(operand_a)) + to_integer(unsigned(operand_b)), result'length));
    when "11000" =>
      -- j
      -- Make sure the current address is in operand a, the 26 bit offset in operand b
      result <= operand_a(31 downto 28) & operand_b(25 downto 0) & "00";
    when "11001" =>
      -- jr
      result <= operand_a;
    when "11010" =>
      -- jal
      -- Make sure the current address is in operand a, the 26 bit offset in operand b
      result <= operand_a(31 downto 28) & operand_b(25 downto 0) & "00";
    when others =>
      NULL;
  end case;
end process operation;



end arch;
