library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity pipeline_tb is 
end pipeline_tb;

architecture arch of pipeline_tb is
    component pipeline is
        port(
            clock: in std_logic; 
            reset: in std_logic;
            write_data_to_file : in std_logic;
            write_registers_to_file : in std_logic
        );
    end component;

    --instantiate signals
    signal clk : std_logic := '0';
    signal reset : std_logic :='0';
    signal write_data_to_file : std_logic :='0';
    signal write_registers_to_file : std_logic :='0';
    constant clk_period : time := 1 ns;

begin
    --1. Hook up component
    pipe : pipeline
    port map(
        clk,
        reset,
        write_data_to_file,
        write_registers_to_file
    );

	--2. CLOCK PROCESS and COUNTER PROCESS
	clk_process : process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
        wait for clk_period/2;
    end process;

    --3. TEST PROCESS
    test_process : process
    
        procedure ten_k_clock_cycles is 
        begin
            for i in 0 to 10000 loop
                wait for clk_period;
            end loop;
        end procedure;

        procedure write_data_and_registers_to_memory is 
        begin
            write_data_to_file <= '1';
            write_registers_to_file <= '1';
            wait for clk_period*100;
        end procedure;

        --RUN PROCEDURES HERE
        begin
        ten_k_clock_cycles;
        write_data_and_registers_to_memory;
	end process;

end arch;


-- Todo
-- 1. Assert signals that are inside of the pipeline component... 
-- 2. Make sure that the pipeline can handle 1024 instructions
-- 3. Must run for 10,000 clock cycles, and output must be written to files???
-- Contents of data memory should be written to memory.txt (should have 8192 lines)
-- Contents of registers should be written to register_file.txt (Should have 21 lines)