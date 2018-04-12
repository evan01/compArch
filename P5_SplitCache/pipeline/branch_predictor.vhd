library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity branch_predictor is
  generic (
      --4096 entry size  chosen based on slides, indicating that a value above this produces little gain
      branch_prediction_table_size : integer := 4096
  );
  port (
    clock: in std_logic;
    id_stall_write: in std_logic;
    if_instruction: in std_logic_vector(31 downto 0);
    id_instruction: in std_logic_vector(31 downto 0);
    id_branch_taken: in std_logic;
    id_branch_target_address: in std_logic_vector(31 downto 0);
    if_pc: in std_logic_vector(31 downto 0);
    id_pc: in std_logic_vector(31 downto 0);

    predict_branch_taken: out std_logic := '0';
    branch_target_address : out std_logic_vector(31 downto 0) := (others => '0')
  );
end branch_predictor;

architecture arch of branch_predictor is
--Access the branch prediction table by the branch address from the pc
--Access the particular predictor using last_branch_1 and last_branch_2
--Branch prediction table entry is
-- | 2 bit predictor | 2 bit predictor | 2 bit predictor | 2 bit predictor | 2 bit predictor | 2 bit predictor | 2 bit predictor | 2 bit predictor
type branch_prediction_table is array(branch_prediction_table_size - 1 downto 0) of std_logic_vector(15 downto 0);
--Branch address table is just branch target address (32 bits)
type branch_address_table is array(branch_prediction_table_size - 1 downto 0) of std_logic_vector(31 downto 0);
signal bpt: branch_prediction_table := (others => (others => '0'));
signal bat: branch_address_table := (others => (others => '0'));
--Used to index into which predictor to use based on taken of last 2 branches
signal last_branch_1: std_logic := '0';
signal last_branch_2: std_logic := '0';
signal last_branch_3: std_logic := '0';
signal internal_branch_taken: std_logic := '0';
signal global_predictor: std_logic_vector(2 downto 0);
begin

global_predictor <= last_branch_3 & last_branch_2 & last_branch_1;

predict_branch: process(if_pc, if_instruction)
	variable var_bpt_row: std_logic_vector(15 downto 0);
  variable var_local_predictor: std_logic_vector(1 downto 0);
	variable var_global_predictor_index: integer;
	variable var_predict_branch_taken: std_logic;
  begin
    --If the current instruction is a branch, make a prediction
    if (if_instruction(31 downto 26) = "000100" or if_instruction(31 downto 26) = "000101") then
      --Get the branch predictors for a particular branch using the pc
      var_bpt_row := bpt(to_integer(unsigned(if_pc(13 downto 2))));
      --Based on the history, select the predictor
      var_global_predictor_index := to_integer(unsigned(global_predictor)) * 2;

      --Based on the predictor state, make a prediction
      var_local_predictor := var_bpt_row(var_global_predictor_index + 1 downto var_global_predictor_index);
      case var_local_predictor is
        when "00" =>
          var_predict_branch_taken := '0';
        when "01" =>
          var_predict_branch_taken := '0';
        when "10" =>
          var_predict_branch_taken := '1';
        when "11" =>
          var_predict_branch_taken := '1';
          when others =>
            var_predict_branch_taken := 'X';
      end case;

      predict_branch_taken <= var_predict_branch_taken;
      internal_branch_taken <= var_predict_branch_taken;

    end if;
    --Get branch target address from array
    branch_target_address <= bat(to_integer(unsigned(if_pc(13 downto 2))));
end process;

--Need to update prediction if current instruction in ID is branch
update_prediction: process(clock, id_pc, id_branch_taken, id_branch_target_address, id_stall_write, id_instruction, internal_branch_taken)
  variable var_bpt_row: std_logic_vector(15 downto 0);
  variable var_local_predictor: std_logic_vector(1 downto 0);
	variable var_global_predictor_index: integer;
  begin
    if (rising_edge(clock)) then
      --Make sure we arent stalling when updating whether we took the last branch
      if(internal_branch_taken = '1') then
        last_branch_1 <= '1';
      end if;
      if ((id_instruction(31 downto 26) = "000100" or id_instruction(31 downto 26) = "000101") and id_stall_write = '1') then
         -- Update the global branch taken
        last_branch_1 <= id_branch_taken;
        last_branch_2 <= last_branch_1;
        last_branch_3 <= last_branch_2;

        ------update bpt -----
        --Index subtract by 1 since this is the incremented pc address, not the pc address of the branch
        var_bpt_row := bpt(to_integer(unsigned(id_pc(13 downto 2)) - 1 ));
        --Based on the history in the id stage, select the predictor
        var_global_predictor_index := to_integer(unsigned(global_predictor) * 2);
        --Update the 2 bit predictor based on whether the branch was taken
        var_local_predictor := var_bpt_row(var_global_predictor_index + 1 downto var_global_predictor_index);

        case var_local_predictor is
          when "00" =>
            if(id_branch_taken = '1') then
              var_local_predictor := "01";
            end if;
          when "01" =>
            if(id_branch_taken = '1') then
              var_local_predictor := "11";
            else
              var_local_predictor := "00";
            end if;
          when "10" =>
            if(id_branch_taken = '0') then
              var_local_predictor := "00";
            else
            var_local_predictor := "11";
            end if;
          when "11" =>
            if(id_branch_taken = '0') then
              var_local_predictor := "10";
            end if;
          when others =>
        end case;


        -- Update the branch target address and store it so we can make predictions in the if stage in the future
        bat(to_integer(unsigned(id_pc(13 downto 2))) - 1) <= id_branch_target_address;
        --Update the predictor in the prediction table row
        var_bpt_row(var_global_predictor_index + 1 downto var_global_predictor_index) := var_local_predictor;
        --Update the row in the table
        bpt(to_integer(unsigned(id_pc(13 downto 2))) - 1) <= var_bpt_row;
      end if;
    end if;
end process;

end arch;
