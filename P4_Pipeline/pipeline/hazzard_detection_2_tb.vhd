library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.hazzard_detection_pkg.all;
use work.all;

entity hazzard_detection_tb2 is 
end hazzard_detection_tb2;

architecture arch of hazzard_detection_tb2 is 

	component hazard_detection_2 is
		port(
			clock				 : IN std_logic;
			id_instruction : IN  std_logic_vector(31 DOWNTO 0); -- instruction in if-id stage
			ex_rd_register : IN  std_logic_vector(4 DOWNTO 0); -- rt register in the id-ex stage
			ex_rs_register : IN  std_logic_vector(4 DOWNTO 0); -- rt register in the id-ex stage
			ex_rt_register : IN  std_logic_vector(4 DOWNTO 0); -- rt register in the id-ex stage
			idex_out_mem_read    : IN  std_logic; -- if memory is being read
			mux_flush            : OUT std_logic; -- To add bubble
			pc_write             : OUT std_logic; -- used to stall current instruction
			fflush               : OUT std_logic -- Flush instructions if j type
		);
	end component;

	signal clock : std_logic := '0';
	constant clk_period : time := 1 ns;
	signal id_instruction : std_logic_vector(31 downto 0);
	signal ex_rd_register: std_logic_vector(4 DOWNTO 0);
	signal ex_rs_register: std_logic_vector(4 DOWNTO 0);
	signal ex_rt_register: std_logic_vector(4 DOWNTO 0);
	signal idex_out_mem_read: std_logic;
	signal mux_flush : std_logic;
	signal pc_write : std_logic;
	signal fflush : std_logic;
	
	type instr_array is array(5 downto 0) of std_logic_vector(31 downto 0);
	signal instructions : instr_array := (
		"00100000000000010000000000000001",
		"00100000000000100000000000000010",
		"00100000000000110000000000000011",
		"00010000011000000000000000000010",
		"00100000000000111111111111111111",
		"00001000000000000000000000000011"
	);

begin
	----INSTANTIATE COMPONENT
	haz : hazard_detection_2 
	port map(
		clock,
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
		clock <= '0';
		wait for clk_period/2;
		clock <= '1';
		wait for clk_period/2;
	end process;
	
	--TEST
	test_process : process
	--Procedure 1, test the hazzard detection unit
	procedure test_hd_unit is 
	begin
	
	id_instruction <= instructions(0);
	wait for clk_period;
	id_instruction <= instructions(1);
	
	end procedure;

	begin
	
	--seed_memory_with_data;
	test_hd_unit;

	end process;
end arch;