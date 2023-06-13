library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_decode is port (
  instruction, pc_in : in std_logic_vector(31 downto 0);
  pc, lit, jumplit : out std_logic_vector(31 downto 0);
  addr_of_rs1, addr_of_rs2, addr_of_rd : out std_logic_vector(4 downto 0);
  aluop : out std_logic_vector(4 downto 0);
  sel_pc_not_rs1, sel_lit_not_rs2, is_jalr : out std_logic;
  cpuclk : in std_logic
); end entity;

architecture a of instruction_decode is
  component d_reg is generic(
    width : natural
  ); port(
    d_in : in std_logic_vector((width-1) downto 0);
    clk : in std_logic;
    d_out : out std_logic_vector((width-1) downto 0)
  ); end component;

  signal fan31, hilit, jallit, lit11_0, lit11_5_4_0, brlit : std_logic_vector(31 downto 0);

  signal my_lit, my_jumplit : std_logic_vector(31 downto 0);
  signal my_addr_of_rs1, my_addr_of_rs2, my_addr_of_rd : std_logic_vector(4 downto 0);
  signal my_aluop : std_logic_vector(4 downto 0);
  signal my_sel_pc_not_rs1, my_sel_lit_not_rs2, my_is_jalr : std_logic;

  signal triple_in, triple_out : std_logic_vector(2 downto 0);
begin
  fan31 <= (others => instruction(31));

  hilit(31 downto 12) <= instruction(31 downto 12);
  hilit(11 downto 0) <= x"000";

  jallit(31 downto 20) <= fan31(31 downto 20);
  jallit(19 downto 12) <= instruction(19 downto 12);
  jallit(          11) <= instruction(20);
  jallit(10 downto  1) <= instruction(30 downto 21);
  jallit(           0) <= '0';

  lit11_0(31 downto 12) <= fan31(31 downto 12);
  lit11_0(11 downto 0) <= instruction(31 downto 20);

  lit11_5_4_0(31 downto 12) <= fan31(31 downto 12);
  lit11_5_4_0(11 downto 5) <= instruction(31 downto 25);
  lit11_5_4_0(4 downto 0) <= instruction(11 downto 7);

  brlit(31 downto 12) <= fan31(31 downto 12);
  brlit(          11) <= instruction(7);
  brlit(10 downto  5) <= instruction(30 downto 25);
  brlit( 4 downto  1) <= instruction(11 downto  8);
  brlit(           0) <= '0';

  process (instruction, fan31, hilit, jallit, lit11_0, lit11_5_4_0, brlit) begin
    my_sel_pc_not_rs1 <= '0';
    my_addr_of_rs1 <= instruction(19 downto 15);
    my_sel_lit_not_rs2 <= '1';
    my_lit     <= "--------------------------------";
    my_addr_of_rs2 <= instruction(24 downto 20);
    my_aluop <= "00000";
    my_addr_of_rd  <= instruction(11 downto  7);
    my_is_jalr <= '0';
    my_jumplit <= "--------------------------------";
    case instruction(6 downto 2) is
      when "01101" => my_addr_of_rs1 <= "00000";                   my_lit <= hilit;                          -- lui
      when "00101" => my_sel_pc_not_rs1  <= '1';                      my_lit <= hilit;                          -- auipc
      when "11011" => my_sel_pc_not_rs1  <= '1'; my_aluop <= "10011"; my_jumplit <= jallit;                     -- jal
      when "11001" => my_sel_pc_not_rs1  <= '1'; my_aluop <= "10011"; my_jumplit <= lit11_0; my_is_jalr <= '1'; -- jalr
      when "11000" => my_aluop(4)<='1'; my_aluop(3)<='-'; my_aluop(2 downto 0)<=instruction(14 downto 12);   -- beq .. bgeu
                      my_sel_lit_not_rs2 <= '0'; my_addr_of_rd <= "00000"; my_jumplit <= brlit;
      --when "00000" => memop(4) <= '1'; memop(3) <= '0';                           my_lit <= lit11_0;       -- lbu .. lw
      --when "01000" => memop(4) <= '1'; memop(3) <= '1'; my_addr_of_rd <= "00000"; my_lit <= lit11_5_4_0;   -- sb .. sw
      when "00100" =>                                                               my_lit <= lit11_0;       -- addi .. srai
                      my_aluop(4)<='0'; my_aluop(3)<=instruction(30); my_aluop(2 downto 0)<=instruction(14 downto 12);
                      if instruction(14 downto 12)/="101" then my_aluop(3)<='0'; end if;
                      --if instruction(14 downto 12)="101" then  my_lit(10) <= '0'; end if;
      when "01100" => my_sel_lit_not_rs2 <= '0';                                                             -- add .. and
                      my_aluop(4)<='0'; my_aluop(3)<=instruction(30); my_aluop(2 downto 0)<=instruction(14 downto 12);
      when others =>
    end case;
  end process;

  pc_23:              d_reg generic map (32) port map(pc_in,              cpuclk, pc);
  lit_23:             d_reg generic map (32) port map(my_lit,             cpuclk, lit);
  jumplit_23:         d_reg generic map (32) port map(my_jumplit,         cpuclk, jumplit);
  addr_of_rs1_23:     d_reg generic map (5)  port map(my_addr_of_rs1,     cpuclk, addr_of_rs1);
  addr_of_rs2_23:     d_reg generic map (5)  port map(my_addr_of_rs2,     cpuclk, addr_of_rs2);
  addr_of_rd_23:      d_reg generic map (5)  port map(my_addr_of_rd,      cpuclk, addr_of_rd);
  aluop_23:           d_reg generic map (5)  port map(my_aluop,           cpuclk, aluop);
  --sel_pc_not_rs1_23:  d_reg generic map (1)  port map(my_sel_pc_not_rs1,  cpuclk, sel_pc_not_rs1);
  --sel_lit_not_rs2_23: d_reg generic map (1)  port map(my_sel_lit_not_rs2, cpuclk, sel_lit_not_rs2);
  --is_jalr_23:         d_reg generic map (1)  port map(my_is_jalr,         cpuclk, is_jalr);
  triple_in(2) <= my_sel_pc_not_rs1;
  triple_in(1) <= my_sel_lit_not_rs2;
  triple_in(0) <= my_is_jalr;
  triple_23:          d_reg generic map (3)  port map(triple_in,  cpuclk, triple_out);
  sel_pc_not_rs1  <= triple_out(2);
  sel_lit_not_rs2 <= triple_out(1);
  is_jalr         <= triple_out(0);

end architecture;
