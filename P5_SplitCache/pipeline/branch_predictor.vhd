library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.hazzard_detection_pkg.all;

entity branch_predictor is
    generic (
        history_table_size : integer := 32768
    );
    port (
        clk: in std_logic;
        if_instruction: in std_logic_vector(31 downto 0);
        id_branch_taken: in std_logic;
        id_branch_dest: in std_logic_vector(31 downto 0); --todo investigate why we need this.
        pc: in std_logic_vector(31 downto 0);
        predict_br_taken: out std_logic;
        br_dest : out std_logic_vector(31 downto 0)
    );
end branch_predictor;

architecture arch of branch_predictor is
    --Signal definitions, 
    --First you get the row of the bht by the branch addr
    --If the past branch history is 10(taken, not-taken) (oldest_hist/last_hist), then use the predictor in the row that 
    --is related to that history
    --The structure of our bht is as follows
    --[oldest_hist, last_hist, 11-predictor, 10 predictor, 01 predictor, 00 predictor] would be a record in the bht
    type branch_history_table is array(history_table_size-1 downto 0) of std_logic_vector(9 downto 0);
    signal bht: branch_history_table;
    
    --Signals required for making predictions
    signal inst_type: instr_type;
    signal inst: instr;
    

    --Signals required for updating the bht
    signal prediction_made: std_logic := '0';
    

    --Component definitions
    component instruction_decoder IS
        PORT(
            id_instruction : IN  std_logic_vector(31 DOWNTO 0);
            instruction    : OUT  instr;
            instruction_type: OUT instr_type
        );
    END component;


begin
    decoder : instruction_decoder
    port map(
        if_instruction,
        inst,
        inst_type
    );

    clk_process: process(clk)
	variable bht_row: std_logic_vector(9 downto 0);
    	variable br_indx: std_logic_vector(15 downto 0);
    	variable br_history: std_logic_vector(1 downto 0);
    	variable br_predictor: std_logic_vector(1 downto 0);
    begin
        if(rising_edge(clk)) then 
            if(inst_type = b_type) then
                --need to make a prediction
                    --first get the branch target addr 
                    br_indx := if_instruction(15 downto 0);
                    --Then get the branch history table row
                    bht_row := bht(to_integer(unsigned(br_indx)));
                    --Then get the history
                    br_history := bht_row(9 downto 8);
                    --Based on the history, select the predictor
                    case br_history is
                        when "00" =>
                            br_predictor := bht_row(1 downto 0);	
                         when "01" =>
                            br_predictor := bht_row(3 downto 2);	
                        when "10" =>
                            br_predictor := bht_row(5 downto 4);	
                        when "11" =>
                            br_predictor := bht_row(7 downto 6);
			when others =>
			    br_predictor := "XX";	
                    end case;
                    
                    --Based on the predictor, make a prediction
                    case br_predictor is 
                        when "00" =>
                            predict_br_taken <= '0';
                        when "01" =>
                            predict_br_taken <= '0';
                        when "10" =>
                            predict_br_taken <= '1';
                        when "11" =>
                            predict_br_taken <= '1';
			when others =>
			    predict_br_taken <= 'X';
                    end case;
                    br_dest <= id_branch_dest;
                    prediction_made <= '1';
            end if;

           
        end if;
    end process;
    
    --Need to know exactly 1 cc after we made a prediction whether or not the prediction was correct.
    update_prediction: process(prediction_made)
	variable bht_indx: integer;
    begin
         if(prediction_made = '1') then
                --update bht
                    --first get the branch target addr indx
                    bht_indx := to_integer(unsigned(id_branch_dest(15 downto 0)));
                    --Then get the branch history table row and update it (shift history left and add newest result)
                    bht(bht_indx) <= bht(bht_indx)(8) & id_branch_taken & bht(bht_indx)(7 downto 0);
                    prediction_made <= '0';
            end if;
    end process;
end arch;