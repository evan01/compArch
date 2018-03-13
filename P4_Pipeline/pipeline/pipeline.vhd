library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline is
 port (
   clock : in std_logic;
   reset : in std_logic
   );
end pipeline;

architecture arch of pipeline is
  ----------------------------- IF STAGE ---------------------------------
component program_counter is
 port (
   clock : in std_logic;
   reset : in std_logic;
   input_address : in std_logic_vector (31 downto 0) := (others => '0');
   output_address : out std_logic_vector(31 downto 0) := (others => '0')
   );
end component;

component byte_adder is
 port (
   input_address : in std_logic_vector(31 downto 0);
   output_address : out std_logic_vector(31 downto 0)
 );
end component;

component instruction_memory is
	generic(
		-- ram_size : INTEGER := 32768;
		ram_size : integer := 8192; --This is in WORDS
		clock_period : time := 1 ns
	);
	port(
		clock: in std_logic;
		memwrite: in std_logic;
		pc : in integer range 0 to 8192-1;
		writedata: in std_logic_vector (31 downto 0); --instead of using alu result, just use forwarded val.
		instruction_out: out std_logic_vector (31 downto 0)
	);
end component;

signal pc_output_address: std_logic_vector(31 downto 0);
signal pc_input_address: std_logic_vector(31 downto 0);
signal incremented_pc_address: std_logic_vector(31 downto 0);
signal branch_target_address: std_logic_vector(31 downto 0);
signal pc_sel: std_logic;
----------------------------- END IF STAGE -----------------------------

component ifid_register is
port (
  fflush: in std_logic := '0';
  ifid_write: in std_logic := '1';
  clock: in std_logic;
  ifid_in_incremented_pc_address: in std_logic_vector(31 downto 0);
  ifid_out_incremented_pc_address: out std_logic_vector(31 downto 0);
  ifid_in_instruction: in std_logic_vector(31 downto 0);
  ifid_out_instruction: out std_logic_vector(31 downto 0)
 );
end component;

----------------------------- ID STAGE ---------------------------------
component cpu_registers is
 port (
   clock : in std_logic;
   reset : in std_logic;
   read_register_1 : in std_logic_vector (4 downto 0);
   read_register_2 : in std_logic_vector (4 downto 0);
   write_register : in std_logic_vector (4 downto 0);
   write_data : in std_logic_vector (31 downto 0);
   read_data_1 : out std_logic_vector (31 downto 0);
   read_data_2 : out std_logic_vector (31 downto 0);
   regwrite : in std_logic := '0';
   regread : in std_logic := '0'
 );
end component;


component pipeline_controller is
 port (
   instruction : in std_logic_vector (31 downto 0);
   reg_dst : out std_logic;
   alu_src :  out std_logic;
   branch :  out std_logic;
   mem_read :  out std_logic;
   mem_write:  out std_logic;
   reg_write:  out std_logic;
   mem_to_reg :  out std_logic;
   alu_opcode : out std_logic_vector (4 downto 0)
 );
end component;

component sign_extender is
port (
  input_16  : in  STD_LOGIC_VECTOR (15 downto 0);
  output_32   : out STD_LOGIC_VECTOR (31 downto 0));
end component;

------------------------------ END ID STAGE ------------------------------

component idex_register is
port (
  clock: in std_logic;

  idex_in_RegDst: in std_logic;
  idex_out_RegDst: out std_logic;
  idex_in_ALUOp1: in std_logic;
  idex_out_ALUOp1: out std_logic;
  idex_in_ALUOp0: in std_logic;
  idex_out_ALUOp0: out std_logic;
  idex_in_ALUSrc: in std_logic;
  idex_out_ALUSrc: out std_logic;

  idex_in_branch: in std_logic;
  idex_out_branch: out std_logic;
  idex_in_mem_read: in std_logic;
  idex_out_mem_read: out std_logic;
  idex_in_mem_write: in std_logic;
  idex_out_mem_write: out std_logic;

  idex_in_reg_write: in std_logic;
  idex_out_reg_write: out std_logic;
  idex_in_mem_to_reg: in std_logic;
  idex_out_mem_to_reg: out std_logic;

  idex_in_operand_a: in std_logic_vector(31 downto 0);
  idex_out_operand_a: out std_logic_vector(31 downto 0);

  idex_in_operand_b: in std_logic_vector(31 downto 0);
  idex_out_operand_b: out std_logic_vector(31 downto 0);

  idex_in_sign_extend_imm: in std_logic_vector(31 downto 0);
  idex_out_sign_extend_imm: out std_logic_vector(31 downto 0);

  idex_in_rt_register: in std_logic_vector(31 downto 0);
  idex_out_rt_register: out std_logic_vector(31 downto 0);

  idex_in_rd_register: in std_logic_vector(31 downto 0);
  idex_out_rd_register: out std_logic_vector(31 downto 0)
 );
end component;

----------------------------- EX STAGE ---------------------------------

component alu is
 port (
   operand_a : in std_logic_vector (31 downto 0);
   operand_b : in std_logic_vector (31 downto 0);
   alu_opcode : in std_logic_vector (4 downto 0);
   result : out std_logic_vector(31 downto 0);
   zero: out std_logic
 );
end component;

------------------------------ END EX STAGE ------------------------------


component exmem_register is
port (
  clock: in std_logic;

  exmem_in_branch: in std_logic;
  exmem_out_branch: out std_logic;
  exmem_in_mem_read: in std_logic;
  exmem_out_mem_read: out std_logic;
  exmem_in_mem_write: in std_logic;
  exmem_out_mem_write: out std_logic;

  exmem_in_reg_write: in std_logic;
  exmem_out_reg_write: out std_logic;
  exmem_in_mem_to_reg: in std_logic;
  exmem_out_mem_to_reg: out std_logic;
  exmem_in_alu_result: in std_logic_vector(31 downto 0);
  exmem_out_alu_result: out std_logic_vector(31 downto 0);

  exmem_in_mem_write_data: in std_logic_vector(31 downto 0);
  exmem_out_mem_write_data: out std_logic_vector(31 downto 0);

  exmem_in_dest_register: in std_logic_vector(31 downto 0);
  exmem_out_dest_register: out std_logic_vector(31 downto 0)
 );
end component;

----------------------------- MEM STAGE ---------------------------------

component data_memory is
	generic(
		-- ram_size : INTEGER := 32768;
		ram_size : integer := 8192; --This is in WORDS
		clock_period : time := 1 ns
	);
	port(
		clock: in std_logic;
		memwrite: in std_logic;
		memread: in std_logic;
		address : in integer;
		writedata: in std_logic_vector (31 downto 0); --instead of using alu result, just use forwarded val.
		readdata: out std_logic_vector (31 downto 0)
	);
end component;

----------------------------- END MEM STAGE -----------------------------

component memwb_register is
port (
  clock: in std_logic;

  memwb_in_reg_write: in std_logic;
  memwb_out_reg_write: out std_logic;
  memwb_in_mem_to_reg: in std_logic;
  memwb_out_mem_to_reg: out std_logic;

  memwb_in_memory_data: in std_logic_vector(31 downto 0);
  memwb_out_memory_data: out std_logic_vector(31 downto 0);

  memwb_in_alu_result: in std_logic_vector(31 downto 0);
  memwb_out_alu_result: out std_logic_vector(31 downto 0);

  memwb_in_dest_register: in std_logic_vector(31 downto 0);
  memwb_out_dest_register: out std_logic_vector(31 downto 0)
 );
end component;

----------------------------- MISC -------------------------------------

component mux2to1 is
    port ( sel : in  STD_LOGIC;
           input_0  : in  STD_LOGIC_VECTOR (31 downto 0);
           input_1   : in  STD_LOGIC_VECTOR (31 downto 0);
           X   : out STD_LOGIC_VECTOR (31 downto 0));
end component;

----------------------------- END MISC ---------------------------------


begin
----------------------------- IF STAGE ---------------------------------

  pc: program_counter PORT MAP(
    clock => clock,
    reset => reset,
    input_address => pc_input_address,
    output_address => pc_output_address
  );

  pc_input_mux : mux2to1 PORT MAP(
    sel => pc_sel,
    input_0 => incremented_pc_address,
    input_1 => branch_target_address,
    X => pc_input_address
  );

  pc_incrementer: byte_adder PORT MAP(
    input_address => pc_output_address,
    output_address => incremented_pc_address
  );
----------------------------- END IF STAGE -----------------------------


----------------------------- ID STAGE ---------------------------------

----------------------------- END ID STAGE -----------------------------

----------------------------- EX STAGE ---------------------------------

----------------------------- END EX STAGE -----------------------------

----------------------------- MEM STAGE ---------------------------------

----------------------------- END MEM STAGE -----------------------------

----------------------------- WB STAGE ---------------------------------

----------------------------- END WB STAGE -----------------------------

end arch;
