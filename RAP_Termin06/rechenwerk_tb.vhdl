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
  
  -- Store 57400000 in Reg 31
  addr_of_rs1 <= "00000";
  sel_pc_not_rs1 <= '0'; -- Reg 0
  lit <= x"57400000";
  sel_lit_not_rs2 <= '1'; -- Lit
  aluop <= "00000"; -- add mit reg 0 ist wie schreiben
  addr_of_rd <= "11111"; -- Reg 31
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  lit <= x"00000000";
  sel_lit_not_rs2 <= '0';
  addr_of_rd <= "00000";
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  if debug_addr_of_rd /= "11111" then report "debug_addr_of_rd ist falsch es sollte 11111 sein" severity failure;
  end if;
  if debug_rd /= x"57400000" then report "debug_rd ist falsch es sollte 57400000 sein" severity failure;
    end if;
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs; 
    
  -- Pc=a + lit=2 in reg 20
  pc <= x"0000000a";
  sel_pc_not_rs1 <= '1'; -- PC
  lit <= x"00000002";
  sel_lit_not_rs2 <= '1'; -- Lit
  aluop <= "00000"; -- add
  addr_of_rd <= "10100"; -- Reg 20
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  pc <= x"00000000";
  sel_pc_not_rs1 <= '0';
  sel_lit_not_rs2 <= '0';
  lit <= x"00000000";
  addr_of_rd <= "00000";
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  if debug_addr_of_rd /= "10100" then report "debug_addr_of_rd ist falsch es sollte 10100 sein" severity failure;
  end if;
  if debug_rd /= x"0000000c" then report "debug_rd ist falsch es sollte 0000000c sein" severity failure;
    end if;
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;   
  
  -- add reg 20 und reg 31 in reg 23
  addr_of_rs1 <= "10100";
  sel_pc_not_rs1 <= '0'; -- reg 20
  addr_of_rs2 <= "11111";
  sel_lit_not_rs2 <= '0'; -- reg 31
  aluop <= "00000"; -- add
  addr_of_rd <= "10111"; -- Reg 23
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
	addr_of_rs1 <= "00000";
	addr_of_rs2 <= "00000";
	aluop <= "00000";
  addr_of_rd <= "00000";
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  if debug_addr_of_rd /= "10111" then report "debug_addr_of_rd ist falsch es sollte 10111 sein" severity failure;
  end if;
  if debug_rd /= x"5740000c" then report "debug_rd ist falsch es sollte 5740000c sein" severity failure;
    end if;
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  
    -- add jumplit und pc
  jumplit <= x"00000FF0";
  is_jalr <= '0'; 
  pc <= x"0000000a";
  sel_pc_not_rs1 <= '0'; -- pc
  aluop <= "00000"; -- add
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
	jumplit <= x"00000000";
	pc <= x"00000000";
  if jumpdest /= x"00000FFa" then report "jumpdest ist falsch es sollte 00000FFa sein" severity failure;
  end if;    
  
  -- add jumplit und reg20
  jumplit <= x"00000FF0";
  is_jalr <= '1'; 
  addr_of_rs1 <= "10100";
  sel_pc_not_rs1 <= '1'; -- reg20
  aluop <= "00000"; -- add
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
	jumplit <= x"00000000";
	is_jalr <= '0';
	addr_of_rs1 <= "00000";
  if jumpdest /= x"00000FFc" then report "jumpdest ist falsch es sollte 00000FFc sein" severity failure;
  end if;
  
  report "rechenwerk_tb ended - reaching here means TEST OK";
    wait;
  end process;
end architecture;
