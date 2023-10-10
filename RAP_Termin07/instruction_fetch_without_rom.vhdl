library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_fetch is port (
  jumpdest : in std_logic_vector(31 downto 0);
  do_jump : in std_logic;
  cpuclk : in std_logic;
  pc, ir : out std_logic_vector(31 downto 0);
  -- Ohne Rom
  pc_to_memory : out std_logic_vector(31 downto 0);
  ir_from_memory : in std_logic_vector(31 downto 0);
  mem_ready : in std_logic
); end entity;


architecture behav of instruction_fetch is

  component d_reg is generic(
    width : natural := 32
  ); port(
    d_in : in std_logic_vector((width-1) downto 0);
    clk : in std_logic;
    d_out : out std_logic_vector((width-1) downto 0)
  ); end component;

 -- kein Rom mehr  type rom_type is array (0 to 255) of std_logic_vector(31 downto 0);

signal r_pc, pc_4, pc_4_0, pc_in, ir_in : std_logic_vector (31 downto 0);
signal nop : std_logic := '1';
signal zaehler : std_logic_vector(2 downto 0) := "001";

begin
pc_4 <= std_logic_vector(unsigned(r_pc) + 4);
pc_4_0 <= r_pc when nop = '1' else pc_4;
pc_in <= jumpdest when do_jump = '1' else pc_4_0;
der_pc: d_reg generic map(32) port map(pc_in, cpuclk, r_pc);
der_pc2: d_reg generic map(32) port map(r_pc, cpuclk, pc);

-- NOP add x0, x0, x0
--ir(31 downto 25) <= "0000000" when nop = '1'; -- Hardcode
--ir(24 downto 20) <= "00000" when nop = '1'; -- x0 rs2
--ir(19 downto 15) <= "00000" when nop = '1'; -- x0 rs1
--ir(14 downto 12) <= "000" when nop = '1'; -- Hardcore
--ir(11 downto 7) <= "00000" when nop = '1'; -- x0 rd
--ir(6 downto 0) <= "0110011" when nop = '1'; -- Opcode add

-- Mit Rom
-- ir_in <= x"00000013" when nop = '1' else rom(to_integer(unsigned(r_pc))/4); 

-- Ohne Rom
ir_in <= x"00000013" when nop = '1' else ir_from_memory; 
ir2: d_reg generic map(32) port map(ir_in, cpuclk, ir);
pc_to_memory <= r_pc;
	process (cpuclk)
	begin
		if falling_edge(cpuclk) then
			nop <= '1';
			case zaehler is
				when "000" => zaehler <= "001";
				when "001" => zaehler <= "010"; 
				when "010" => zaehler <= "011";  
				when "011" => zaehler <= "100"; nop <= '0';
				when "100" => zaehler <= "101";
				when "101" => zaehler <= "110";
				when "110" => zaehler <= "111";
				when "111" => zaehler <= "000";
				when others =>
			end case;			
		end if;
	end process;
end architecture;
