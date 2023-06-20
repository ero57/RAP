library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_fetch_without_rom is port (
  jumpdest : in std_logic_vector(31 downto 0);
  do_jump : in std_logic;
  cpuclk : in std_logic;
  pc, ir : out std_logic_vector(31 downto 0);

  pc_to_memory : out std_logic_vector(31 downto 0);
  ir_from_memory : in std_logic_vector(31 downto 0);
  mem_ready : in std_logic
); end entity;


architecture behav of instruction_fetch_without_rom is

  component d_reg is generic(
    width : natural := 32
  ); port(
    d_in : in std_logic_vector((width-1) downto 0);
    clk : in std_logic;
    d_out : out std_logic_vector((width-1) downto 0)
  ); end component;

  signal real_pc, pc_plus_4, pc_plus_4_or_0, pc_in, ir_in : std_logic_vector(31 downto 0);
  signal use_nop : std_logic := '1';
  signal count : std_logic_vector(2 downto 0) := "001";

begin
  pc_plus_4 <= std_logic_vector(unsigned(real_pc) + 4);
  pc_plus_4_or_0 <= real_pc when use_nop='1' else pc_plus_4;
  pc_in <= jumpdest when do_jump='1' else pc_plus_4_or_0;
  the_pc: d_reg generic map(32) port map(pc_in, cpuclk, real_pc);
  pc_12: d_reg generic map(32) port map(real_pc, cpuclk, pc);

  ir_in <= x"00000013" when use_nop='1'
      else ir_from_memory;
  ir_12: d_reg generic map(32) port map(ir_in, cpuclk, ir);

  pc_to_memory <= real_pc;

  process (cpuclk)
  begin
    if falling_edge(cpuclk) then
      use_nop <= '1';
      case count is
        when "000" => count <= "001";
        when "001" => count <= "010";
        when "010" => count <= "011";
        when "011" => count <= "100";
        when "100" => count <= "101";
        when "101" => count <= "110"; use_nop <= '0';
        when "110" => count <= "111";
        when "111" => count <= "000";
        when others =>
      end case;
    end if;
  end process;
end architecture;
