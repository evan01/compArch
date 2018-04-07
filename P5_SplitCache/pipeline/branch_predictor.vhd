library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity branch_predictor is
  generic (
      --4096 entry size  chosen based on slides, indicating that a value above this produces little gain
      branch_prediction_table_size : integer := 4096
  );
  port (
    if_instruction: in std_logic_vector(31 downto 0);
    id_instruction: in std_logic_vector(31 downto 0);
    id_branch_taken: in std_logic;
    id_branch_target_address: in std_logic_vector(31 downto 0); --todo investigate why we need this.
    if_pc: in std_logic_vector(31 downto 0);
    id_pc: in std_logic_vector(31 downto 0);

    predict_branch_taken: out std_logic := '0';
    branch_target_address : out std_logic_vector(31 downto 0) := (others => '0')
  );
end branch_predictor;

architecture arch of branch_predictor is
--Access the branch prediction table by the branch address from the pc
--Access the particular predictor using last_branch_1 and last_branch_2
--Branch prediction table entry is | 2 bit predictor | 2 bit predictor | 2 bit predictor | 2 bit predictor
type branch_prediction_table is array(branch_prediction_table_size - 1 downto 0) of std_logic_vector(7 downto 0);
--Branch address table is just branch target address (32 bits)
type branch_address_table is array(branch_prediction_table_size - 1 downto 0) of std_logic_vector(31 downto 0);
signal bpt: branch_prediction_table;

--Used to index into which predictor to use based on taken of last 2 branches
signal last_branch_1: std_logic := '0';
signal last_branch_2: std_logic := '0';
signal id_last_branch_1: std_logic := '0';
signal id_last_branch_2: std_logic := '0';
signal global_predictor: std_logic_vector(1 downto 0);
signal id_global_predictor: std_logic_vector(1 downto 0);

begin

global_predictor <= last_branch_1 & last_branch_2;
id_global_predictor <= id_last_branch_1 & id_last_branch_2;

predict_branch: process(if_pc)
	variable var_bpt_row: std_logic_vector(7 downto 0);
	variable var_local_predictor: std_logic_vector(1 downto 0);
	variable var_global_predictor_index: integer;
  begin
    --If the current instruction is a branch, make a prediction
    if (if_instruction(31 downto 26) = "000100" or if_instruction(31 downto 26) = "000101") then
      --Get the branch predictors for a particular branch using the pc
      var_bpt_row := bpt(to_integer(unsigned(if_pc(11 downto 0))));
      --Based on the history, select the predictor
      var_global_predictor_index := to_integer(unsigned(global_predictor)) * 2;
      var_local_predictor := var_bpt_row(var_global_predictor_index + 1 downto var_global_predictor_index);

      --Based on the predictor state, make a prediction
      case var_local_predictor is
        when "00" =>
          predict_branch_taken <= '0';
        when "01" =>
          predict_branch_taken <= '0';
        when "10" =>
          predict_branch_taken <= '1';
        when "11" =>
          predict_branch_taken <= '1';
      	when others =>
    	    predict_branch_taken <= 'X';
      end case;

      --Need to propagate the values we used to index the branch predictor
      id_last_branch_1 <= last_branch_1;
      id_last_branch_2 <= last_branch_2;
    end if;
end process;

--Need to update prediction if current instruction in ID is branch
update_prediction: process(id_pc)
  variable var_bpt_row: std_logic_vector(7 downto 0);
	variable var_local_predictor: std_logic_vector(1 downto 0);
	variable var_global_predictor_index: integer;
  begin
   if (id_instruction(31 downto 26) = "000100" or id_instruction(31 downto 26) = "000101") then
     -- Update the global branch taken
     last_branch_2 <= last_branch_1;
     last_branch_1 <= id_branch_taken;

    ------update bpt -----

    --first get the predictor entry
    var_bpt_row := bpt(to_integer(unsigned(id_pc(11 downto 0))));

    --Based on the history in the id stage, select the predictor
    var_global_predictor_index := to_integer(unsigned(id_global_predictor)) * 2;
    var_local_predictor := var_bpt_row(var_global_predictor_index + 1 downto var_global_predictor_index);

    --Update the 2 bit predictor based on whether the branch was taken
    case var_local_predictor is
      when "00" =>
        if(id_branch_taken = '1') then
          var_local_predictor := "01";
        end if;
      when "01" =>
        if(id_branch_taken = '1') then
          var_local_predictor := "11";
        end if;
      when "10" =>
        if(id_branch_taken = '0') then
          var_local_predictor := "00";
        end if;
      when "11" =>
        if(id_branch_taken = '0') then
          var_local_predictor := "10";
        end if;
      when others =>
    end case;

    --Update the predictor in the prediction table row
    var_bpt_row(var_global_predictor_index + 1 downto var_global_predictor_index) := var_local_predictor;

    --Update the row in the table
    bpt(to_integer(unsigned(id_pc(11 downto 0)))) <= var_bpt_row;
  end if;
end process;

end arch;
