library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity pipeline_tb is 
end pipeline_tb;

architecture arch of pipeline_tb is

    signal
    component pipeline is
        port(
            clock: in std_logic; 
            reset: in std_logic
        );
    end component;

    --instantiate signals
    signal clk : std_logic := '0';
    signal reset : std_logic :='0';

    --Data and Register Memory Signals
    type data_mem is array(8192-1 downto 0) of std_logic_vector(31 downto 0);
    signal ram: data_mem;

    type registers is array(31 downto 0) of std_logic_vector(31 downto 0);
    signal reg: registers;

begin
    --1. Hook up component
    pipe : pipeline
    port map(
        clk,reset
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
    
	procedure 10000_clock_cycles is 
	begin
		for i in 0 to 99 loop
		    wait for clk_period;
		end loop;
    end procedure;

    procedure write_data_memory is 
    	file memory_file_pointer: text;
		variable memory_line: line;
        variable memory_data: std_logic_vector(31 downto 0);
    begin
       --First aquire memory data
        ram <= pipe.data_memory.ram;

        --Write output here
        file_open(memory_file_pointer, "memory.txt", WRITE_MODE);
            for i in 0 to 8191 loop
                --Write the data to the line
                write(memory_line, ram(i)); 
                --Write the line to the file
                writeline(memory_file_pointer, memory_line);
            end loop;
		file_close(memory_file_pointer);
    end procedure;

    procedure write_registers is 
    	file register_file_pointer: text;
		variable register_line: line;
		variable register_data: std_logic_vector(31 downto 0);
    begin
        --First aquire register data

        --Write ouput here
        file_open(register_file_pointer, "memory.txt", WRITE_MODE);
            write(r)
			for i in 0 to 8191 loop
                --Write the data to the line
                write(register_line, reg(i)); 
                --Write the line to the file
                writeline(register_file_pointer, register_line);
            end loop;
		file_close(register_file_pointer);
    end procedure;
    
    --RUN PROCEDURES HERE
    10000_clock_cycles;
    write_data_memory;
    write_registers;
	end process;

end arch ; -- arch


-- Todo
-- 1. Assert signals that are inside of the pipeline component... 
-- 2. Make sure that the pipeline can handle 1024 instructions
-- 3. Must run for 10,000 clock cycles, and output must be written to files???
-- Contents of data memory should be written to memory.txt (should have 8192 lines)
-- Contents of registers should be written to register_file.txt (Should have 21 lines)