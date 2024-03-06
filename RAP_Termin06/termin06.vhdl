library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rechenwerk is port (
  pc, lit, jumplit : in std_logic_vector(31 downto 0);
  addr_of_rs1, addr_of_rs2, addr_of_rd : in std_logic_vector(4 downto 0);
  aluop : in std_logic_vector(4 downto 0);
  sel_pc_not_rs1, sel_lit_not_rs2, is_jalr : in std_logic; -- ansteuersignale der MPX in Op-Fetch
  cpuclk : in std_logic;

  jumpdest : out std_logic_vector(31 downto 0); -- werden zurueckgefuehrt an Instruction fetch
  do_jump : out std_logic;

  debug_rd : out std_logic_vector(31 downto 0);  -- only for testbenches
  debug_addr_of_rd : out std_logic_vector(4 downto 0)
); end entity;

architecture behav of rechenwerk is

  component MUX is port (
    in1,in2: in std_logic_vector(31 downto 0);
    outline: out std_logic_vector(31 downto 0);
    SEL: in std_logic
  ); end component;


  component alu is port (
    op1, op2 : in std_logic_vector(31 downto 0);
    aluout : out std_logic_vector(31 downto 0);
    aluop : in std_logic_vector(4 downto 0);
    do_jump : out std_logic
  ); end component;
  signal op1, op2 : std_logic_vector(31 downto 0) := x"ffffffff";
  signal aluout : std_logic_vector(31 downto 0) := x"ffffffff";

  component cpu_registers is port(
    addr_of_rs1, addr_of_rs2 : in std_logic_vector(4 downto 0);
    rs1, rs2 : out std_logic_vector(31 downto 0);
    addr_of_rd : in std_logic_vector(4 downto 0);
    rd : in std_logic_vector(31 downto 0);
    clk : in std_logic
  ); end component;
  signal rs1, rs2 : std_logic_vector(31 downto 0) := x"ffffffff";
  signal rd : std_logic_vector(31 downto 0) := x"ffffffff";

  component d_reg is generic(
    width : natural := 32
  ); port(
    d_in : in std_logic_vector((width-1) downto 0);
    clk : in std_logic;
    d_out : out std_logic_vector((width-1) downto 0)
  ); end component;
  
  component adder32 is port(
    a     : in std_logic_vector(31 downto 0);
    b     : in std_logic_vector(31 downto 0);
    sum   : out std_logic_vector(31 downto 0)
   -- carry : out std_logic
  );
  end component;

  signal jumplit_out: std_logic_vector(31 downto 0) := x"ffffffff";
  signal MUX_Jump_out,MUX_Jump_out_reg: std_logic_vector(31 downto 0) := x"ffffffff";
  signal MUX_sel_pc_not_rs1_out,MUX_sel_pc_not_rs1_out_reg: std_logic_vector(31 downto 0) := x"ffffffff";
  signal MUX_sel_lit_not_rs2_out,MUX_sel_lit_not_rs2_out_reg: std_logic_vector(31 downto 0) := x"ffffffff";
  signal aluop_out_reg,addr_of_rd_reg_1,addr_of_rd_reg_2: std_logic_vector(4 downto 0) := "00000";
  signal aluout_reg: std_logic_vector(31 downto 0) := x"ffffffff";
--  signal carry: std_logic := '0';
  signal sum: std_logic_vector(31 downto 0) := x"00000000";
  signal rs1_MUX, rs2_MUX : std_logic_vector(31 downto 0);
  
begin
	registers_inst: cpu_registers
		port map (
		addr_of_rs1 => addr_of_rs1,
		addr_of_rs2 => addr_of_rs2,
		rs1 => rs1,
		rs2 => rs2,
		addr_of_rd => addr_of_rd_reg_2,
		rd => aluout_reg,
		clk => cpuclk
		);
	
	--Operand Fetch	
	
  rs1_MUX <= rs1  when addr_of_rs1="00000"
 									else aluout when addr_of_rd_reg_1 = addr_of_rs1
  								else rd when addr_of_rd_reg_2 = addr_of_rs1 else rs1;
  rs2_MUX <= rs2 when addr_of_rs2="00000" 
  								else aluout when addr_of_rd_reg_1 = addr_of_rs2
  								else rd when addr_of_rd_reg_2 = addr_of_rs2
  								else rs2;     
           
	--Multiplexer Jump	
	MUX_Jump: MUX port map(in1 => rs1, in2 => pc, outline => MUX_Jump_out, SEL => is_jalr); 
	--Multiplexer pc oder rs1
	MUX_sel_pc_not_rs1: MUX port map(in1 => pc, in2 => rs1_MUX, outline => MUX_sel_pc_not_rs1_out, SEL => sel_pc_not_rs1);
	--Multiplexer lit oder rs2
	MUX_sel_lit_not_rs2: MUX port map(in1 => lit, in2 => rs2_MUX, outline => MUX_sel_lit_not_rs2_out, SEL => sel_lit_not_rs2);
	
	--Execute
	
	--Pipelineregister 1 Takt addr_of_rd
  d_reg_1_takt_addr_rd: d_reg generic map (width => 5) port map (d_in => addr_of_rd, clk => cpuclk, d_out => addr_of_rd_reg_1);
  
  --Piplineregister Jumplitreal
	d_reg_jumplit: d_reg generic map (width => 32) port map (d_in => jumplit, clk => cpuclk, d_out => jumplit_out);    
	
	--Pipelineregister Multiplexer Jump
	d_reg_jump_MUX: d_reg generic map (width => 32) port map (d_in => MUX_Jump_out, clk => cpuclk, d_out => MUX_Jump_out_reg);
	
	--Pipelineregister Multiplexer pc oder rs1
	d_reg_sel_pc_not_rs1_MUX: d_reg generic map (width => 32) port map (d_in => MUX_sel_pc_not_rs1_out, clk => cpuclk, d_out => MUX_sel_pc_not_rs1_out_reg);
	
	--Pipelineregister Multiplexer lit oder rs2
	d_reg_sel_lit_not_rs2_MUX: d_reg generic map (width => 32) port map (d_in =>  MUX_sel_lit_not_rs2_out, clk => cpuclk, d_out => MUX_sel_lit_not_rs2_out_reg);
	
	--Pipelineregiste aluop
	d_reg_aluop: d_reg generic map (width => 5) port map (d_in => aluop, clk => cpuclk, d_out => aluop_out_reg);
	
	--ALU
	ALU_1: alu port map(op1 => MUX_sel_pc_not_rs1_out_reg, op2 => MUX_sel_lit_not_rs2_out_reg, aluop => aluop_out_reg, aluout =>  			 aluout , do_jump => do_jump);
	
	-- Jumpdest
	jumpdest1: adder32 port map (a => jumplit, b => MUX_Jump_out_reg,sum=>sum);
	
	--Store
	
  --Pipelineregister aluout
	d_reg_aluout: d_reg generic map (width => 32) port map (d_in => aluout, clk => cpuclk, d_out => aluout_reg);
	
	--Pipelineregister 2 Takt addr_of_rd
	d_reg_2_takt_addr_rd: d_reg generic map (width => 5) port map (d_in => addr_of_rd_reg_1, clk => cpuclk, d_out => addr_of_rd_reg_2);
	
	
	jumpdest <= sum;
	debug_rd <=  aluout_reg;
	debug_addr_of_rd <= addr_of_rd_reg_2;
end architecture;
