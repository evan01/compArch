library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ifid_register is
port (
  fflush: in std_logic := '0';
  ifid_write: in std_logic := '1';
  clock: in std_logic;
  ifid_in_incremented_pc_address: in std_logic_vector(31 downto 0);
  ifid_out_incremented_pc_address: out std_logic_vector(31 downto 0);
  ifid_in_instruction: in std_logic_vector(31 downto 0);
  ifid_out_instruction: out std_logic_vector(31 downto 0)
 );
end ifid_register;

architecture arch of ifid_register is
begin

reg: process(clock)
begin
  if (rising_edge(clock)) then
    if (fflush = '1') then
      -- Insert bubble/nop (used during jump instruction)
      ifid_out_instruction <= (others => '0');
    else
      if(ifid_write = '1') then
        -- Propagate new data through, else keep the current data (if stall)
        ifid_out_incremented_pc_address <= ifid_in_incremented_pc_address;
        ifid_out_instruction <= ifid_in_instruction;
      end if;
    end if;
  end if;
end process;
end arch;
