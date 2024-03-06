library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rechenwerk_tb is end entity;
architecture behav of rechenwerk_tb is

function to_string(arg : std_logic_vector) return string is
  		variable result : string (1 to arg'length);
    	variable v : std_logic_vector (result'range) := arg;
  	begin
    	for i in result'range loop
      		case v(i) is
       			when 'U' => result(i) := 'U';
       		 	when 'X' => result(i) := 'X';
       		 	when '0' => result(i) := '0';
       		 	when '1' => result(i) := '1';
       		 	when 'Z' => result(i) := 'Z';
       		 	when 'W' => result(i) := 'W';
       		 	when 'L' => result(i) := 'L';
       		 	when 'H' => result(i) := 'H';
       		 	when '-' => result(i) := '-';
			end case;
		end loop;
		return result;
  	end function;
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
  
  -- Store 0 in Reg 4
  addr_of_rs1 <= "00000";
  sel_pc_not_rs1 <= '0'; -- Reg 0
  lit <= x"00000000";
  sel_lit_not_rs2 <= '1'; -- Lit
  aluop <= "00000"; -- add mit reg 0 ist wie schreiben
  addr_of_rd <= "00100"; -- Reg 4
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  lit <= x"00000000";
  sel_lit_not_rs2 <= '0';
  addr_of_rd <= "00000";
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  if debug_addr_of_rd /= "00100" then report "debug_addr_of_rd ist falsch es sollte 00100 sein" severity failure;
  end if;
  if debug_rd /= x"00000000" then report "debug_rd ist falsch es sollte 57400000 sein" severity failure;
    end if;
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs; 
  
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
 
   
  -- sub reg 23 and reg 31 in reg 21
  addr_of_rs1 <= "10111"; -- reg 23
  sel_pc_not_rs1 <= '0';
  addr_of_rs2 <= "11111"; -- reg 31
  sel_lit_not_rs2 <= '0'; 
  aluop <= "01000"; -- sub
  addr_of_rd <= "10101"; -- Reg 21
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  addr_of_rs1 <= "00000";
	addr_of_rs2 <= "00000";
	aluop <= "00000";
  addr_of_rd <= "00000";
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  if debug_addr_of_rd /= "10101" then report "debug_addr_of_rd ist falsch es sollte 10101 sein" severity failure;
  end if;
  if debug_rd /= x"0000000c" then report "debug_rd ist falsch es sollte 0000000c sein(hazard)" severity failure;
    end if;
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  
  
  --Data Hazard bsp:  
  -- addi x1, x0, 3
  addr_of_rs1 <= "00000";
  sel_pc_not_rs1 <= '0'; -- x0
  lit <= x"00000003";
  sel_lit_not_rs2 <= '1'; -- literal 3
  aluop <= "00000"; -- add
  addr_of_rd <= "00001"; -- x1
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
 			 -- addi x1, x0, 3 ist nun im exec
  -- add x4, x0, x1 kommt an
  addr_of_rs1 <= "00000";
  sel_pc_not_rs1 <= '0'; -- x0
  addr_of_rs2 <= "00001";
  sel_lit_not_rs2 <= '0'; -- x1
  aluop <= "00000"; -- add
  addr_of_rd <= "00100"; -- x4
  cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
 		 --addi x1, x0, 3 ist nun in store
  --add x4, x0, x1 ist nun in exec
  if debug_rd /= x"00000003" then report "debug_rd ist falsch es sollte x00000003 sein " & to_string(debug_rd) severity failure;
    end if;   	
   cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
     if debug_addr_of_rd /= "00100" then report "addr_of_rd ist falsch. Es sollte 00100" & to_string(debug_addr_of_rd) severity failure;
     end if;
     if debug_rd /= x"00000003" then report "debug_rd ist falsch. Es sollte x00000003 sein " & to_string(debug_rd) severity failure;
    end if;  
  report "rechenwerk_tb ended - reaching here means TEST OK";
    wait;
  end process;
end architecture;
