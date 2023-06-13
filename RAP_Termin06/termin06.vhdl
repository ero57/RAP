library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- version with data forwarding to eliminate data hazards
-- NOT TO BE USED YET, only for demonstration

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
    width : natural
  ); port(
    d_in : in std_logic_vector((width-1) downto 0);
    clk : in std_logic;
    d_out : out std_logic_vector((width-1) downto 0)
  ); end component;

  signal pre_jump, pre_op1, pre_op2, pre_jump_delayed, jumplit_delayed : std_logic_vector(31 downto 0) := x"ffffffff";
  signal a_o_rd_delayed, a_o_rd_delayed_twice, aluop_delayed : std_logic_vector(4 downto 0) := "11111";

  signal rs1_to_mpx, rs2_to_mpx : std_logic_vector(31 downto 0);

begin
  -- debug
  debug_rd <= rd;
  debug_addr_of_rd <= a_o_rd_delayed_twice;

  -- cpu registers
  the_regs: cpu_registers port map(addr_of_rs1, addr_of_rs2, rs1, rs2, a_o_rd_delayed_twice, rd, cpuclk);

  -- no data forwarding:
  --rs1_to_mpx <= rs1; rs2_to_mpx <= rs2;

  -- with data forwarding
  rs1_to_mpx <= rs1    when addr_of_rs1="00000"
           else aluout when a_o_rd_delayed=addr_of_rs1
           else rd     when a_o_rd_delayed_twice=addr_of_rs1
           else rs1;
  rs2_to_mpx <= rs2    when addr_of_rs2="00000"
           else aluout when a_o_rd_delayed=addr_of_rs2
           else rd     when a_o_rd_delayed_twice=addr_of_rs2
           else rs2;

  -- operand fetch
  pre_op1 <= pc  when sel_pc_not_rs1 ='1' else rs1_to_mpx;
  pre_op2 <= lit when sel_lit_not_rs2='1' else rs2_to_mpx;
  pre_jump <= pc when is_jalr='0' else rs1_to_mpx;

  -- execute
  the_alu: alu port map(op1, op2, aluout, aluop_delayed, do_jump);
  jumpdest <= std_logic_vector(unsigned(pre_jump_delayed) + unsigned(jumplit_delayed));

  -- pipeline registers
  op1_23: d_reg generic map(32) port map(pre_op1, cpuclk, op1);
  op2_23: d_reg generic map(32) port map(pre_op2, cpuclk, op2);
  aluop_23: d_reg generic map(5) port map(aluop, cpuclk, aluop_delayed);
  pre_jump_23: d_reg generic map(32) port map(pre_jump, cpuclk, pre_jump_delayed);       -- needs init with 0
  a_o_rd_23: d_reg generic map(5) port map(addr_of_rd, cpuclk, a_o_rd_delayed);          -- needs init with 0
  jumplit_23: d_reg generic map(32) port map(jumplit, cpuclk, jumplit_delayed);

  -- more pipeline registers
  a_o_rd_34: d_reg generic map(5) port map(a_o_rd_delayed, cpuclk, a_o_rd_delayed_twice); -- needs init with 0
  aluout_34: d_reg generic map(32) port map(aluout, cpuclk, rd);
end architecture;
