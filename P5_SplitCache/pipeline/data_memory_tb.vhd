library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity data_memory_tb is 
end data_memory_tb;

architecture arch of data_memory_tb is 

	component data_memory is 
		generic(
			ram_size : integer := 8192; --This is in WORDS  32768 bytes
			clock_period : time := 1 ns	
		);
		port(
			clock: in std_logic;
			memwrite: in std_logic;
			memread: in std_logic;
			write_data_to_file: in std_logic;
			address: in std_logic_vector (31 downto 0);
			writedata: in std_logic_vector (31 downto 0); --instead of using alu result, just use forwarded val.
			readdata: out std_logic_vector (31 downto 0)
			);
	end component;

	--insantiate signals with default start values
	signal clk : std_logic := '0';
	constant clk_period : time := 1 ns;
	signal mwrite: std_logic := '0';
	signal mread: std_logic := '0';
	signal address: std_logic_vector(31 downto 0);
	signal writedata: std_logic_vector(31 downto 0);
	signal readdata: std_logic_vector(31 downto 0);
	signal w_data_to_file: std_logic := '0';

begin
	----INSTANTIATE COMPONENT
	mem : data_memory 
	generic map(
		ram_size => 100
	)
	port map(
		clk,
		mwrite,
		mread,
		w_data_to_file,
		address,
		writedata,
		readdata
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
			address <= std_logic_vector(to_unsigned(i,address'length));
			writedata <= std_logic_vector(to_unsigned(i,writedata'length));
			wait for clk_period;
		end loop;
		mwrite <= '0';
	end procedure;

	--Procedure 2, read the data!
	procedure check_data_in_mem is 
	begin
		mwrite <= '0';
		mread <= '1';
		for i in 0 to 99 loop
			address <= std_logic_vector(to_unsigned(i,address'length));
			wait for clk_period;
			if(not unsigned(readdata) = i) then
				report "Error, the memory didn't return the correct instruction";
			end if;
		end loop;
	end procedure;

	procedure write_data_to_file is 
	begin
		w_data_to_file <= '1';
		wait for clk_period;
	end procedure;

	begin
	
	seed_memory_with_data;
	check_data_in_mem;
	write_data_to_file;

	end process;
end arch;