library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rechenwerk_tb is end entity;

architecture behav of rechenwerk_tb is
  component rechenwerk is port (
    pc, lit, jumplit : in std_logic_vector(31 downto 0);
    addr_of_rs1, addr_of_rs2, addr_of_rd : in std_logic_vector(4 downto 0);
    aluop : in std_logic_vector(4 downto 0);
    sel_pc_not_rs1, sel_lit_not_rs2, is_jalr : in std_logic;
    cpuclk : in std_logic;

    jumpdest : out std_logic_vector(31 downto 0);
    do_jump : out std_logic;

    debug_rd : out std_logic_vector(31 downto 0);
    debug_addr_of_rd : out std_logic_vector(4 downto 0)
  ); end component;
signal pc, lit, jumplit : std_logic_vector(31 downto 0);
signal addr_of_rs1, addr_of_rs2, addr_of_rd : std_logic_vector(4 downto 0);
signal aluop : std_logic_vector(4 downto 0);
signal sel_pc_not_rs1, sel_lit_not_rs2, is_jalr : std_logic;
signal cpuclk : std_logic;
signal jumpdest : std_logic_vector(31 downto 0);
signal do_jump : std_logic;
signal debug_rd : std_logic_vector(31 downto 0);
signal debug_addr_of_rd : std_logic_vector(4 downto 0);

begin
rechenwerk1 : rechenwerk port map (pc, lit, jumplit, addr_of_rs1, addr_of_rs2, addr_of_rd, aluop, sel_pc_not_rs1, sel_lit_not_rs2, is_jalr, cpuclk, jumpdest, do_jump, debug_rd, debug_addr_of_rd);
  process begin  
  
  -- Add
  sel_pc_not_rs1 <= '0';
  sel_lit_not_rs2 <= '0';
  aluop <= "00000";
  addr_of_rs1 <= "00000";
  addr_of_rs2 <= "00001";
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  -- assert debug_rd /= x"00000000" report "Add istn och nciht ndjsfhios" severity failure;
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  assert debug_rd = x"00000000" report "Add ist cool" severity failure;
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  
  -- Addi
  sel_pc_not_rs1 <= '0';
  sel_lit_not_rs2 <= '1';
  aluop <= "00000";
  addr_of_rs1 <= "00000";
  lit <= x"00000001";
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  -- cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  assert debug_rd = x"00000001" report "Addi ist cool" severity failure;
 
    report "rechenwerk_tb ended - reaching here means TEST OK";
    wait;
  end process;
end architecture;
