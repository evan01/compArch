
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline is
 port (
   clock : in std_logic;
   reset : in std_logic;
   write_data_to_file : in std_logic;
   write_registers_to_file : in std_logic
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
	port(
		clock: in std_logic;
		pc : in std_logic_vector (31 downto 0);
		instruction_out: out std_logic_vector (31 downto 0)
	);
end component;

-- All the signals/wires for the if stage
signal if_pc_output_address: std_logic_vector(31 downto 0);
signal if_pc_input_address: std_logic_vector(31 downto 0);
signal if_incremented_pc_address: std_logic_vector(31 downto 0);
signal if_branch_target_address: std_logic_vector(31 downto 0);
signal if_instruction: std_logic_vector(31 downto 0);
signal if_pc_sel: std_logic;
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
   write_registers_to_file: in std_logic;
   read_register_1 : in std_logic_vector (4 downto 0);
   read_register_2 : in std_logic_vector (4 downto 0);
   write_register : in std_logic_vector (4 downto 0);
   write_data : in std_logic_vector (31 downto 0);
   read_data_1 : out std_logic_vector (31 downto 0);
   read_data_2 : out std_logic_vector (31 downto 0);
   regwrite : in std_logic := '0'
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
   shift_instr : out std_logic;
   alu_opcode : out std_logic_vector (4 downto 0)
 );
end component;

component sign_extender is
port (
  input_16  : in  STD_LOGIC_VECTOR (15 downto 0);
  output_32   : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component branch_comparator is
port (
  branch: in std_logic;
  operand_a : in std_logic_vector(31 downto 0);
  operand_b : in std_logic_vector(31 downto 0);
  alu_opcode : in std_logic_vector (4 downto 0);
  branch_taken : out std_logic := '0'
);
end component;

component hazard_detection is
	port (
		ifid_out_instruction : IN  std_logic_vector(31 DOWNTO 0); -- instruction in if-id stage
		idex_out_rt_register : IN  std_logic_vector(4 DOWNTO 0); -- rt register in the id-ex stage
		idex_out_mem_read    : IN  std_logic; -- if memory is being read
		branch_taken         : IN  std_logic; -- input from the branch_comparator
		mux_flush            : OUT std_logic; -- To add bubble
		pc_write             : OUT std_logic; -- used to stall current instruction
		fflush               : OUT std_logic -- Flush instructions if j type
	);
end component;

component hazard_detection_mux IS
	port (
		mux_flush : IN std_logic;
		reg_dst_in : IN std_logic;
		alu_src_in : IN std_logic;
		branch_in : IN std_logic := '0';
		mem_read_in : IN std_logic;
		mem_write_in : IN std_logic;
		reg_write_in : IN std_logic;
		mem_to_reg_in : IN std_logic;
		alu_opcode_in : IN std_logic_vector (4 DOWNTO 0);
		reg_dst_out : OUT std_logic;
		alu_src_out : OUT std_logic;
		branch_out : OUT std_logic := '0';
		mem_read_out : OUT std_logic;
		mem_write_out : OUT std_logic;
		reg_write_out : OUT std_logic;
		mem_to_reg_out : OUT std_logic;
		alu_opcode_out : OUT std_logic_vector (4 DOWNTO 0)
	);
END component;

-- All the signals/wires for the id stage
signal id_instruction: std_logic_vector(31 downto 0);
signal id_write_register: std_logic_vector(4 downto 0);
signal id_incremented_pc_address: std_logic_vector(31 downto 0);
signal id_write_data: std_logic_vector(31 downto 0);
signal id_reg_read_data_1: std_logic_vector(31 downto 0);
signal id_reg_read_data_2: std_logic_vector(31 downto 0);
signal id_reg_read: std_logic;
signal id_reg_dst: std_logic;
signal id_alu_src: std_logic;
signal id_branch: std_logic;
signal id_mem_read: std_logic;
signal id_mem_write: std_logic;
signal id_reg_write: std_logic;
signal id_mem_to_reg: std_logic;
signal id_pc_src: std_logic;
signal id_alu_opcode: std_logic_vector (4 downto 0);
signal id_sign_extend_imm: std_logic_vector(31 downto 0);
signal id_branch_target_address: std_logic_vector(31 downto 0);
signal id_pc_write : std_logic;
signal id_fflush : std_logic;
signal id_mux_flush : std_logic;
signal	id_reg_dst_out : std_logic;
signal	id_alu_src_out : std_logic;
signal	id_branch_out : std_logic;
signal	id_mem_read_out : std_logic;
signal	id_mem_write_out : std_logic;
signal	id_reg_write_out : std_logic;
signal	id_mem_to_reg_out : std_logic;
signal	id_alu_opcode_out : std_logic_vector (4 DOWNTO 0);
signal  id_shift_instr: std_logic;

------------------------------ END ID STAGE ------------------------------

component idex_register is
port (
  clock: in std_logic;

  idex_in_RegDst: in std_logic;
  idex_out_RegDst: out std_logic;
  idex_in_alu_opcode: in std_logic_vector (4 downto 0);
  idex_out_alu_opcode: out std_logic_vector (4 downto 0);
  idex_in_ALUSrc: in std_logic;
  idex_out_ALUSrc: out std_logic;
  idex_in_shift_instr: in std_logic;
  idex_out_shift_instr: in std_logic;

  idex_in_mem_read: in std_logic;
  idex_out_mem_read: out std_logic;
  idex_in_mem_write: in std_logic;
  idex_out_mem_write: out std_logic;

  idex_in_reg_write: in std_logic;
  idex_out_reg_write: out std_logic;
  idex_in_mem_to_reg: in std_logic;
  idex_out_mem_to_reg: out std_logic;

  idex_in_read_data_1: in std_logic_vector(31 downto 0);
  idex_out_read_data_1: out std_logic_vector(31 downto 0);

  idex_in_read_data_2: in std_logic_vector(31 downto 0);
  idex_out_read_data_2: out std_logic_vector(31 downto 0);

  idex_in_sign_extend_imm: in std_logic_vector(31 downto 0);
  idex_out_sign_extend_imm: out std_logic_vector(31 downto 0);

  idex_in_rt_register: in std_logic_vector(4 downto 0);
  idex_out_rt_register: out std_logic_vector(4 downto 0);

  idex_in_rd_register: in std_logic_vector(4 downto 0);
  idex_out_rd_register: out std_logic_vector(4 downto 0)
 );
end component;

----------------------------- EX STAGE ---------------------------------

component alu is
 port (
   operand_a : in std_logic_vector (31 downto 0);
   operand_b : in std_logic_vector (31 downto 0);
   alu_opcode : in std_logic_vector (4 downto 0);
   result : out std_logic_vector(31 downto 0)
 );
end component;

-- All the signals/wires for the ex stage
signal ex_reg_read: std_logic;
signal ex_reg_dst: std_logic;
signal ex_alu_src: std_logic;
signal ex_mem_read: std_logic;
signal ex_mem_write: std_logic;
signal ex_reg_write: std_logic;
signal ex_mem_to_reg: std_logic;
signal ex_alu_opcode: std_logic_vector(4 downto 0);
signal ex_reg_read_data_1: std_logic_vector(31 downto 0);
signal ex_reg_read_data_2: std_logic_vector(31 downto 0);
signal ex_sign_extend_imm: std_logic_vector(31 downto 0);
signal ex_rt_register: std_logic_vector(4 downto 0);
signal ex_rd_register: std_logic_vector(4 downto 0);
signal ex_dst_register: std_logic_vector(4 downto 0);
signal ex_alu_result: std_logic_vector(31 downto 0);
signal ex_alu_operand_b: std_logic_vector(31 downto 0);
signal ex_alu_operand_a: std_logic_vector(31 downto 0);
signal ex_shift_instr: std_logic;

------------------------------ END EX STAGE ------------------------------


component exmem_register is
port (
  clock: in std_logic;

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

  exmem_in_dest_register: in std_logic_vector(4 downto 0);
  exmem_out_dest_register: out std_logic_vector(4 downto 0)
 );
end component;

----------------------------- MEM STAGE ---------------------------------

component data_memory is
	port(
		clock: in std_logic;
		memwrite: in std_logic;
    memread: in std_logic;
    write_data_to_file: in std_logic;
		address : in std_logic_vector(31 downto 0);
		writedata: in std_logic_vector (31 downto 0);
		readdata: out std_logic_vector (31 downto 0)
	);
end component;

-- All the signals/wires for the ex stage
signal mem_mem_read: std_logic;
signal mem_mem_write: std_logic;
signal mem_reg_write: std_logic;
signal mem_mem_to_reg: std_logic;
signal mem_alu_result: std_logic_vector(31 downto 0);
signal mem_datamem_write_data: std_logic_vector(31 downto 0);
signal mem_datamem_read_data: std_logic_vector(31 downto 0);
signal mem_dst_register: std_logic_vector(4 downto 0);

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

  memwb_in_dest_register: in std_logic_vector(4 downto 0);
  memwb_out_dest_register: out std_logic_vector(4 downto 0)
 );
end component;


----------------------------- WB STAGE ---------------------------------

-- All the signals/wires for the wb stage
signal wb_reg_write: std_logic;
signal wb_mem_to_reg: std_logic;
signal wb_datamem_read_data: std_logic_vector(31 downto 0);
signal wb_alu_result: std_logic_vector(31 downto 0);
signal wb_dst_register: std_logic_vector(4 downto 0);
signal wb_reg_write_data: std_logic_vector(31 downto 0);

----------------------------- END WB STAGE -----------------------------

----------------------------- MISC -------------------------------------

component mux2to1 is
    port ( sel : in  STD_LOGIC;
           input_0  : in  STD_LOGIC_VECTOR (31 downto 0);
           input_1   : in  STD_LOGIC_VECTOR (31 downto 0);
           X   : out STD_LOGIC_VECTOR (31 downto 0));
end component;

signal true : std_logic := '1';
----------------------------- END MISC ---------------------------------

begin

----------------------------- IF STAGE ---------------------------------

  pc: program_counter PORT MAP(
    clock => clock,
    reset => reset,
    input_address => if_pc_input_address,
    output_address => if_pc_output_address
  );

  mux_pc_input : mux2to1 PORT MAP(
    sel => id_pc_src,
    input_0 => if_incremented_pc_address,
    input_1 => id_branch_target_address,
    X => if_pc_input_address
  );

  pc_incrementer: byte_adder PORT MAP(
    input_address => if_pc_output_address,
    output_address => if_incremented_pc_address
  );

  instruction_mem: instruction_memory PORT MAP (
  		clock => clock,
  		pc => if_pc_output_address,
  		instruction_out => if_instruction
  	);
----------------------------- END IF STAGE -----------------------------

  ifid_reg: ifid_register PORT MAP(
    clock => clock,
    ifid_in_incremented_pc_address => if_incremented_pc_address,
    ifid_out_incremented_pc_address => id_incremented_pc_address,
    ifid_in_instruction => if_instruction,
    ifid_out_instruction => id_instruction
  );

----------------------------- ID STAGE ---------------------------------

  cpu_reg: cpu_registers PORT MAP(
    clock => clock,
    reset => reset,
    write_registers_to_file => write_registers_to_file,
    read_register_1 => id_instruction(25 downto 21),
    read_register_2 => id_instruction(20 downto 16),
    write_register => wb_dst_register,
    write_data => wb_reg_write_data,
    read_data_1 => id_reg_read_data_1,
    read_data_2 => id_reg_read_data_2,
    regwrite => wb_reg_write
  );

  pipeline_ctlr: pipeline_controller PORT MAP(
    instruction => id_instruction,
    reg_dst => id_reg_dst,
    alu_src => id_alu_src,
    branch => id_branch,
    mem_read => id_mem_read,
    mem_write=> id_mem_write,
    reg_write=> id_reg_write,
    mem_to_reg => id_mem_to_reg,
    shift_instr => id_shift_instr,
    alu_opcode => id_alu_opcode
  );

  sign_extend: sign_extender PORT MAP(
    input_16  => id_instruction(15 downto 0),
    output_32 => id_sign_extend_imm
  );

  branch_comp: branch_comparator PORT MAP(
    branch => id_branch,
    operand_a => id_reg_read_data_1,
    operand_b => id_reg_read_data_2,
    alu_opcode => id_alu_opcode,
    branch_taken => id_pc_src
  );
  
  hazard_detect: hazard_detection PORT MAP (
		ifid_out_instruction => id_instruction,
		idex_out_rt_register  => ex_rt_register,
		idex_out_mem_read => ex_mem_read, 
		branch_taken => id_pc_src,    
		mux_flush => id_mux_flush,      
		pc_write => id_pc_write,       
		fflush => id_fflush      
	);

hazard_detect_mux: hazard_detection_mux PORT MAP (
		mux_flush => id_mux_flush,
		reg_dst_in => id_reg_dst,
		alu_src_in => id_alu_src,
		branch_in => id_branch,
		mem_read_in => id_mem_read,
		mem_write_in => id_mem_write,
		reg_write_in => id_reg_write,
		mem_to_reg_in => id_mem_to_reg,
		alu_opcode_in => id_alu_opcode,
		reg_dst_out => id_reg_dst_out,
		alu_src_out => id_alu_src_out,
		branch_out => id_branch_out,
		mem_read_out => id_mem_read_out, 
		mem_write_out => id_mem_write_out,
		reg_write_out => id_reg_write_out,
		mem_to_reg_out => id_mem_to_reg_out, 
		alu_opcode_out => id_alu_opcode_out
	);

  --Calculate the branch target address for an instruction in the ID stage
  id_branch_target_address <= std_logic_vector((unsigned(id_sign_extend_imm) sll 2) + unsigned(id_incremented_pc_address));

----------------------------- END ID STAGE -----------------------------

idex_reg: idex_register PORT MAP(
  clock => clock,

  idex_in_RegDst => id_reg_dst,
  idex_out_RegDst => ex_reg_dst,
  idex_in_alu_opcode => id_alu_opcode,
  idex_out_alu_opcode => ex_alu_opcode,
  idex_in_ALUSrc => id_alu_src,
  idex_out_ALUSrc => ex_alu_src,
  idex_in_shift_instr => id_shift_instr;
  idex_out_shift_instr => ex_shift_instr;

  idex_in_mem_read => id_mem_read,
  idex_out_mem_read => ex_mem_read,
  idex_in_mem_write => id_mem_write,
  idex_out_mem_write => ex_mem_write,

  idex_in_reg_write => id_reg_write,
  idex_out_reg_write => ex_reg_write,
  idex_in_mem_to_reg => id_mem_to_reg,
  idex_out_mem_to_reg => ex_mem_to_reg,

  idex_in_read_data_1 => id_reg_read_data_1,
  idex_out_read_data_1 => ex_reg_read_data_1,

  idex_in_read_data_2 => id_reg_read_data_2,
  idex_out_read_data_2 => ex_reg_read_data_2,

  idex_in_sign_extend_imm =>id_sign_extend_imm,
  idex_out_sign_extend_imm => ex_sign_extend_imm,

  idex_in_rt_register => id_instruction(20 downto 16),
  idex_out_rt_register => ex_rt_register,

  idex_in_rd_register => id_instruction(15 downto 11),
  idex_out_rd_register => ex_rd_register
 );

----------------------------- EX STAGE ---------------------------------

alu_component: alu PORT MAP(
   operand_a => ex_alu_operand_a,
   operand_b => ex_alu_operand_b,
   alu_opcode => ex_alu_opcode,
   result => ex_alu_result
 );

 mux_alu_b: mux2to1 PORT MAP(
   sel => ex_alu_src,
   input_0 => ex_reg_read_data_2,
   input_1 => ex_sign_extend_imm,
   X => ex_alu_operand_b
 );

 mux_alu_a: mux2to1 PORT MAP(
   sel => ex_shift_instr,
   input_0 => ex_reg_read_data_1,
   input_1 => (31 downto 6 => '0') & ex_sign_extend_imm(11 downto 6),
   X => ex_alu_operand_a
 );

 -- Destination register mux
 ex_dst_register <= ex_rt_register when (ex_reg_dst = '0') else ex_rd_register;

----------------------------- END EX STAGE -----------------------------

  exmem_reg: exmem_register PORT MAP(
    clock => clock,

    exmem_in_mem_read => ex_mem_read,
    exmem_out_mem_read => mem_mem_read,
    exmem_in_mem_write => ex_mem_write,
    exmem_out_mem_write => mem_mem_write,

    exmem_in_reg_write => ex_reg_write,
    exmem_out_reg_write => mem_reg_write,
    exmem_in_mem_to_reg => ex_mem_to_reg,
    exmem_out_mem_to_reg => mem_mem_to_reg,
    exmem_in_alu_result => ex_alu_result,
    exmem_out_alu_result => mem_alu_result,

    exmem_in_mem_write_data => ex_reg_read_data_2,
    exmem_out_mem_write_data => mem_datamem_write_data,

    exmem_in_dest_register => ex_dst_register,
    exmem_out_dest_register => mem_dst_register
   );

----------------------------- MEM STAGE ---------------------------------

  data_mem: data_memory PORT MAP(
  		clock => clock,
  		memwrite => mem_mem_write,
      memread => mem_mem_read,
      write_data_to_file => write_data_to_file,
  		address => mem_alu_result,
  		writedata => mem_datamem_write_data,
  		readdata => mem_datamem_read_data
  	);

----------------------------- END MEM STAGE -----------------------------

  memwb_reg: memwb_register PORT MAP(
    clock => clock,

    memwb_in_reg_write => mem_reg_write,
    memwb_out_reg_write => wb_reg_write,
    memwb_in_mem_to_reg => mem_mem_to_reg,
    memwb_out_mem_to_reg => wb_mem_to_reg,

    memwb_in_memory_data => mem_datamem_read_data,
    memwb_out_memory_data => wb_datamem_read_data,

    memwb_in_alu_result => mem_alu_result,
    memwb_out_alu_result => wb_alu_result,

    memwb_in_dest_register => mem_dst_register,
    memwb_out_dest_register => wb_dst_register
 );

----------------------------- WB STAGE ---------------------------------

 mux_wb_memtoreg : mux2to1 PORT MAP(
   sel => wb_mem_to_reg,
   input_1 => wb_datamem_read_data,
   input_0 => wb_alu_result,
   X => wb_reg_write_data
 );

----------------------------- END WB STAGE -----------------------------

end arch;