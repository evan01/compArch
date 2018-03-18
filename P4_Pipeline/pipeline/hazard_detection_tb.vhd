library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity hazard_detection_tb is
end hazard_detection_tb;

architecture arch of hazard_detection_tb is

	component hazard_detection is
		port(
			ifid_out_instruction : in  std_logic_vector(31 downto 0);
			idex_out_rt_register : in  std_logic_vector(4 downto 0);
			idex_out_mem_read    : in  std_logic;
			stall                : in  std_logic;
			mux_flush            : out std_logic;
			pc_write             : out std_logic;
			fflush               : out std_logic
		);
	end component;

	--insantiate signals with default start values
	signal ifid_out_instruction : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal idex_out_rt_register : std_logic_vector(4 downto 0)  := "00000";
	signal idex_out_mem_read    : std_logic                     := '0';
	signal stall                : std_logic                     := '0';
	signal mux_flush            : std_logic                     := '0';
	signal pc_write             : std_logic                     := '0';
	signal fflush               : std_logic                     := '0';

begin
	----INSTANTIATE COMPONENT
	mem : hazard_detection
		port map(
			ifid_out_instruction,
			idex_out_rt_register,
			idex_out_mem_read,
			stall,
			mux_flush,
			pc_write,
			fflush
		);

	--TEST
	process
	begin
		ifid_out_instruction <= (others => '0');
		idex_out_rt_register <= (others => '0');
		idex_out_mem_read    <= '0';
		stall                <= '1';

		wait;

		--wait for 2ns;
		--ifid_out_instruction
	end process;
end arch;
