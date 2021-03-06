library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_memory_tb is 
end instruction_memory_tb;

architecture arch of instruction_memory_tb is 

	component instruction_memory is 
		generic(
			ram_size : integer := 8192; --This is in WORDS  32768 bytes
			clock_period : time := 1 ns	
		);
		port(
			clock: in std_logic;
			memwrite: in std_logic;
			pc : in std_logic_vector (31 downto 0);
			writedata: in std_logic_vector (31 downto 0); --instead of using alu result, just use forwarded val.
			instruction_out: out std_logic_vector (31 downto 0)
			);
	end component;

	--insantiate signals with default start values
	signal clk : std_logic := '0';
	constant clk_period : time := 1 ns;
	signal mwrite: std_logic := '0';
	signal pc: std_logic_vector (31 downto 0);
	signal writedata: std_logic_vector(31 downto 0);
	signal instruction_out: std_logic_vector(31 downto 0);

begin
	----INSTANTIATE COMPONENT
	mem : instruction_memory 
	generic map(
		ram_size => 100
	)
	port map(
		clk,
		mwrite,
		pc,
		writedata,
		instruction_out
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
	
	--Procedure 1, this fills our ir with instructions
	procedure seed_memory_with_data is 
	begin
		mwrite <= '1';
		for i in 0 to 99 loop
			pc <= std_logic_vector(to_unsigned(i,pc'length));
			writedata <= std_logic_vector(to_unsigned(i,writedata'length));
			wait for clk_period;
		end loop;
		mwrite <= '0';
	end procedure;

	--Procedure 2, read the data!
	procedure read_data is 
	begin
		for i in 0 to 99 loop
			pc <= std_logic_vector(to_unsigned(i,pc'length));
			wait for clk_period;
			assert (unsigned(instruction_out) /= 0) report "Error, the memory didn't return the correct instruction";
		end loop;
	end procedure;

	begin
	
	--seed_memory_with_data;
	read_data;

	end process;
end arch;