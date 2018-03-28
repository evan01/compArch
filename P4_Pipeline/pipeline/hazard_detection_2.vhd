LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY hazard_detection IS
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
END hazard_detection;


ARCHITECTURE arch OF hazard_detection IS

	TYPE instr IS (
		addi, slti, andi, ori, xori, lui, lw, sw,
		s_ll, s_rl, s_ra, add, sub, mult, div, slt, nd, o_r, n_or, x_or, mfhi, mflo,
		jr,jal,j,
        beq, bne,
        invalid
	);

    TYPE instr_type IS (
        r_type, 
        i_type, 
        j_type, 
        b_type
    );
    
    TYPE hazzard_state is (
        stall,
        flush,
        bubble,
        normal,
        start
    );

    signal state: hazzard_state := start;
    signal next_state: hazzard_state := normal;
    signal instruction_type : instr_type;
    signal instruction : instr;
    signal last_instruction_type : instr_type;

begin

    instruction_type <=
            i_type when       id_instruction(31 downto 26) = "001000" else
            i_type when       id_instruction(31 downto 26) = "001000" else
            i_type when       id_instruction(31 downto 26) = "001100" else
            i_type when       id_instruction(31 downto 26) = "001101" else
            i_type when       id_instruction(31 downto 26) = "001110" else
            i_type when       id_instruction(31 downto 26) = "001111" else
            j_type when       id_instruction(31 downto 26) = "000000" and id_instruction(5 downto 0) = "001000" else
            i_type when       id_instruction(31 downto 26) = "100011" else
            i_type when       id_instruction(31 downto 26) = "101011" else
            b_type when       id_instruction(31 downto 26) = "000100" else
            b_type when       id_instruction(31 downto 26) = "000101" else
            j_type when       id_instruction(31 downto 26) = "000010" else
            j_type when       id_instruction(31 downto 26) = "000011" else
            r_type;

    instruction <=
        addi    when      id_instruction(31 downto 26) = "001000"    else
        slti    when      id_instruction(31 downto 26) = "001010"    else
        andi    when      id_instruction(31 downto 26) = "001100"    else
        ori     when      id_instruction(31 downto 26) = "001101"    else
        xori    when      id_instruction(31 downto 26) = "001110"    else
        lui     when      id_instruction(31 downto 26) = "001111"    else
        s_ll    when      id_instruction(31 downto 26) = "000000"    and id_instruction(5 downto 0) =  "000000" else
        s_rl    when      id_instruction(31 downto 26) = "000000"    and id_instruction(5 downto 0) =  "000010" else
        s_ra    when      id_instruction(31 downto 26) = "000000"    and id_instruction(5 downto 0) =  "000011" else
        jr      when      id_instruction(31 downto 26) = "000000"    and id_instruction(5 downto 0) =  "001000" else
        add     when      id_instruction(31 downto 26) = "000000"    and id_instruction(5 downto 0) =  "100000" else
        sub     when      id_instruction(31 downto 26) = "000000"    and id_instruction(5 downto 0) =  "100010" else
        mult    when      id_instruction(31 downto 26) = "000000"    and id_instruction(5 downto 0) =  "011000" else
        div     when      id_instruction(31 downto 26) = "000000"    and id_instruction(5 downto 0) =  "011010" else
        slt     when      id_instruction(31 downto 26) = "000000"    and id_instruction(5 downto 0) =  "101010" else
        nd      when      id_instruction(31 downto 26) = "000000"    and id_instruction(5 downto 0) =  "100100" else
        o_r     when      id_instruction(31 downto 26) = "000000"    and id_instruction(5 downto 0) =  "100101" else
        n_or    when      id_instruction(31 downto 26) = "000000"    and id_instruction(5 downto 0) =  "100111" else
        x_or    when      id_instruction(31 downto 26) = "000000"    and id_instruction(5 downto 0) =  "100110" else
        mfhi    when      id_instruction(31 downto 26) = "000000"    and id_instruction(5 downto 0) =  "010000" else
        mflo    when      id_instruction(31 downto 26) = "000000"    and id_instruction(5 downto 0) =  "010010" else
        lw      when      id_instruction(31 downto 26) = "100011"    else
        sw      when      id_instruction(31 downto 26) = "101011"    else
        beq     when      id_instruction(31 downto 26) = "000100"    else
        bne     when      id_instruction(31 downto 26) = "000101"    else
        j       when      id_instruction(31 downto 26) = "000010"    else
        jal     when      id_instruction(31 downto 26) = "000011"    else
        invalid;

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