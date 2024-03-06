library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_decode is port (
  instruction, pc_in : in std_logic_vector(31 downto 0);
  pc, lit, jumplit : out std_logic_vector(31 downto 0);
  addr_of_rs1, addr_of_rs2, addr_of_rd : out std_logic_vector(4 downto 0);
  aluop : out std_logic_vector(4 downto 0);
  sel_pc_not_rs1, sel_lit_not_rs2, is_jalr : out std_logic;
  cpuclk : in std_logic;
  annul : in std_logic := '0'
); end entity;

architecture a of instruction_decode is
  component d_reg is generic(
    width : natural
  ); port(
    d_in : in std_logic_vector((width-1) downto 0);
    clk : in std_logic;
    d_out : out std_logic_vector((width-1) downto 0)
  ); end component;

signal lui_lit, jal_jumplit, jalr_jumplit,beq_jumplit,lb_lit,sb_lit,id_lit,id_jumplit,j_lit,jarl_lit : std_logic_vector(31 downto 0);
signal id_addr_of_rs1, id_addr_of_rs2, id_addr_of_rd : std_logic_vector(4 downto 0);
signal id_aluop : std_logic_vector(4 downto 0);
signal id_sel_pc_not_rs1, id_sel_lit_not_rs2, id_is_jarl :std_logic;
signal annul_addr_of_rs1, annul_addr_of_rs2, annul_addr_of_rd : std_logic_vector(4 downto 0);
signal annul_aluop : std_logic_vector(4 downto 0);

begin
lui_lit(31 downto 12) <= instruction(31 downto 12);
lui_lit(11 downto 0) <= (others => '0');

j_lit(31 downto 21) <= (others => instruction(31));
j_lit(20) <= instruction(31);
j_lit(19 downto 12) <= instruction(19 downto 12);
j_lit(11) <= instruction(20);
j_lit(10 downto 1) <= instruction(30 downto 21);
j_lit(0) <= '0';

jarl_lit(31 downto 12) <= (others => instruction(31));
jarl_lit(11 downto 0) <= instruction(31 downto 20);

beq_jumplit(31 downto 13) <= (others => instruction(31));
beq_jumplit(12) <= instruction(31);
beq_jumplit(10 downto 5) <= instruction(30 downto 25);
beq_jumplit(11) <= instruction(7);
beq_jumplit(4 downto 1) <= instruction(11 downto 8);
beq_jumplit(0) <= '0';

lb_lit(31 downto 12) <= (others => instruction(31));
lb_lit(11 downto 0) <= instruction(31 downto 20);

sb_lit(31 downto 12) <= (others => '0');
sb_lit(11 downto 5) <= instruction(31 downto 25);
sb_lit(4 downto 0) <= instruction(11 downto 7);

process(instruction,lui_Lit,j_lit)
begin
	id_addr_of_rs1 <= instruction(19 downto 15);
	id_addr_of_rs2 <= instruction(24 downto 20);
	id_addr_of_rd <= instruction(11 downto 7);
	id_aluop <= "00000";
	id_sel_pc_not_rs1 <= '0';
	id_sel_lit_not_rs2 <= '0';
	id_is_jarl <= '0';
	id_lit <= (others => '0');
	id_jumplit <= (others => '0');
	case instruction(6 downto 2) is
	--LUI
		when "01101" => id_lit <= lui_lit; id_addr_of_rs1 <= "00000"; id_sel_lit_not_rs2 <= '1';
	--AUIPC
		when "00101" => id_lit <= lui_lit;  id_sel_lit_not_rs2 <= '1'; id_sel_pc_not_rs1 <= '1';
	--JAL
		when "11011" => id_jumplit <= j_lit; id_sel_lit_not_rs2 <= '1'; id_aluop <= "10011"; id_sel_pc_not_rs1 <= '1';
	--JALR
		when "11001" => id_jumplit <= jarl_lit; id_sel_pc_not_rs1 <= '1';id_sel_lit_not_rs2 <= '1'; id_aluop <= "10011"; id_is_jarl <= '1';
	--BEQ
		when "11000" => id_jumplit <= beq_jumplit;id_aluop(4) <= '1' ; id_aluop(3) <= '-'; id_aluop(2 downto 0) <= instruction(14 downto 12); id_addr_of_rd <= "00000"; id_is_jarl <= '1';
	--SRAI
		when "00100" => id_lit <= lb_lit; id_aluop <= "01101";
	--SUB
		when "01100" => id_aluop <= "01000";
		when others => 
	end case;
end process;

lit_d_reg: d_reg generic map(width => 32) port map(id_lit,cpuclk,lit);

rs2_d_reg:d_reg generic map(width => 5) port map(id_addr_of_rs2,cpuclk,addr_of_rs2);
addr_of_rs2 <= (id_addr_of_rs2 and "00000") when (annul = '1') else id_addr_of_rs2;

rs1_d_reg:d_reg generic map(width => 5) port map(id_addr_of_rs1,cpuclk,addr_of_rs1);
addr_of_rs1 <= (id_addr_of_rs1 and "00000") when (annul = '1') else id_addr_of_rs1;

rd_d_reg:d_reg generic map(width => 5) port map(id_addr_of_rd,cpuclk,addr_of_rd);
addr_of_rd <= (id_addr_of_rd and "00000") when (annul = '1') else id_addr_of_rd;

jumplit_d_reg:d_reg generic map(width => 32) port map(id_jumplit,cpuclk,jumplit);

aluop_d_reg :d_reg generic map(width => 5) port map(id_aluop,cpuclk,aluop);
aluop <= (id_aluop and "00000") when (annul = '1') else id_aluop;



aluop <= (id_aluop and "00000") when (annul = '1') else id_aluop;
addr_of_rs1 <= (id_addr_of_rs1 and "00000") when (annul = '1') else id_addr_of_rs1;

addr_of_rd <= (id_addr_of_rd and "00000") when (annul = '1') else id_addr_of_rd;


		
end architecture;
