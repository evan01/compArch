LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.hazzard_detection_pkg.all;

ENTITY hazard_detection_2 IS
	PORT(
		clock				 : IN std_logic;
		id_instruction : IN  std_logic_vector(31 DOWNTO 0); -- instruction in if-id stage
		ex_rd_register : IN  std_logic_vector(4 DOWNTO 0); -- rt register in the id-ex stage
		ex_rs_register : IN  std_logic_vector(4 DOWNTO 0); -- rt register in the id-ex stage
		ex_rt_register : IN  std_logic_vector(4 DOWNTO 0); -- rt register in the id-ex stage
		idex_out_mem_read    : IN  std_logic; -- if memory is being read
		mux_flush            : OUT std_logic := '0'; -- To add bubble
		pc_write             : OUT std_logic := '1'; -- used to stall current instruction
		fflush               : OUT std_logic := '0' -- Flush instructions if j type
	);
END hazard_detection_2;

ARCHITECTURE arch OF hazard_detection_2 IS

    COMPONENT instruction_decoder IS
	PORT(
		id_instruction : in std_logic_vector(31 DOWNTO 0); -- instruction
		instruction    :  out instr;
		instruction_type: out instr_type
	);
    END component;

    signal state: hazzard_state := start;
    signal next_state: hazzard_state := normal;
    signal instruction_type : instr_type;
    signal instruction : instr;
    signal last_instruction_type : instr_type;

begin
    ----INSTANTIATE DECODER COMPONENT, for sanity sake, outputs instruction and type
	hd : instruction_decoder 
	port map(
        id_instruction,
        instruction,
        instruction_type
	);

    process(id_instruction, instruction, instruction_type) -- Does this handle the case where you get 2 of the same instruction in a row??? Use PC?
    begin
        state <= bubble;
    end process;
    
    --ONLY the outputs/state should be determined by the clock, and held for 1 period.
    process(state)
    begin
        case state is 
            when start =>
                pc_write <= '1';
                fflush <= '0';
                mux_flush <= '0';

            when normal =>
                pc_write <= '1';
                fflush <= '0';
                mux_flush <= '0';

            when flush =>
                fflush <= '1';
                mux_flush <= '0';
                pc_write <= '0';
                
            when bubble =>
                fflush <= '1';
                mux_flush <= '1';
                pc_write <= '0';

            when stall =>
                pc_write <= '0';
                fflush <= '0';
                mux_flush <= '0';

            when others =>
                pc_write <= '1';
                fflush <= '0';
                mux_flush <= '0';
        end case;
    end process;
 

END arch;