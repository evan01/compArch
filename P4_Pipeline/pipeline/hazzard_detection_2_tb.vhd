library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hazzard_detection_tb is 
end hazzard_detection_tb;

architecture arch of hazzard_detection_tb is 

	component hazzard_detection is
		port(
			clock :std_logic;
			id_instruction : std_logic_vector(31 DOWNTO 0); -- instructionif-id stage
			ex_rd_register : std_logic_vector(4 DOWNTO 0); -- rt registerthe id-ex stage
			ex_rs_register : std_logic_vector(4 DOWNTO 0); -- rt registerthe id-ex stage
			ex_rt_register : std_logic_vector(4 DOWNTO 0); -- rt registerthe id-ex stage
			idex_out_mem_read : std_logic; -- if memory is being read
			mux_flush : std_logic := '0'; -- To add bubble
			pc_write : std_logic := '1'; -- used to stall current instruction
			fflush : std_logic := '0' -- Flush instructions if j type
		);
	end component;

	--EVAN MIDDLE OF WRITING TESTS FOR THIS THING... 
	--insantiate signals with default start values
	signal clk : std_logic := '0';
	constant clk_period : time := 1 ns;
	signal ex_rd_register,
	signal ex_rs_register,
	signal ex_rt_register,
	signal idex_out_mem_read,
	signal mux_flush,
	signal pc_write,
		fflush

begin
	----INSTANTIATE COMPONENT
	hd : hazzard_detection 
	port map(
		clk,
		id_instruction,
		ex_rd_register,
		ex_rs_register,
		ex_rt_register,
		idex_out_mem_read,
		mux_flush,
		pc_write,
		fflush
	);

	--CLOCK
	clk_process : process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;
	
	--TEST
	test_process : process
	--Procedure 1, test the hazzard detection unit
	procedure test_hd_unit is 
	begin
	
	wait for clk_period;

	00100000000000010000000000000001
	00100000000000100000000000000010
	00100000000000110000000000000011
	00010000011000000000000000000010
	00100000000000111111111111111111
	00001000000000000000000000000011

			
	end procedure;

	begin
	
	--seed_memory_with_data;
	test_hd_unit;

	end process;
end arch;