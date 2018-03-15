library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

begin
    --1. Hook up component
    pipe : pipeline
    port map(
        clk,reset
    );

	--2. CLOCK PROCESS
	clk_process : process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
    end process;
    
    --3. TEST PROCESS
    test_process : process
    
    	--Procedure 1, this fills our ir with instructions
	procedure fetch_instructions is 
	begin
		-- mwrite <= '1';
		-- for i in 0 to 99 loop
		-- 	pc <= std_logic_vector(to_unsigned(i,pc'length));
		-- 	writedata <= std_logic_vector(to_unsigned(i,writedata'length));
		-- 	wait for clk_period;
		-- end loop;
		-- mwrite <= '0';
    end procedure;
    
    --RUN PROCEDURES HERE
    fetch_instructions;

	end process;

end arch ; -- arch