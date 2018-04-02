package hazzard_detection_pkg is
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
end package hazzard_detection_pkg;
USE work.hazzard_detection_pkg.all;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY instruction_decoder IS
	PORT(
		id_instruction : IN  std_logic_vector(31 DOWNTO 0);
		instruction    : OUT  instr;
		instruction_type: OUT instr_type
	);
END instruction_decoder;

ARCHITECTURE arch OF instruction_decoder IS

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
	
end arch;