library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_decode_tb is end entity;

architecture a of instruction_decode_tb is

  -- die folgende funktion mag nuetzlich sein; wenn man sie
  -- nicht braucht: loeschen oder auskommentieren
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
  end;

  component instruction_decode is port (
    instruction, pc_in : in std_logic_vector(31 downto 0);
    pc, lit, jumplit : out std_logic_vector(31 downto 0);
    addr_of_rs1, addr_of_rs2, addr_of_rd : out std_logic_vector(4 downto 0);
    aluop : out std_logic_vector(4 downto 0);
    sel_pc_not_rs1, sel_lit_not_rs2, is_jalr : out std_logic;
    cpuclk : in std_logic
  ); end component;
  signal instruction, pc_in : std_logic_vector(31 downto 0);
  signal pc, lit, jumplit : std_logic_vector(31 downto 0);
  signal addr_of_rs1, addr_of_rs2, addr_of_rd : std_logic_vector(4 downto 0);
  signal aluop : std_logic_vector(4 downto 0);
  signal sel_pc_not_rs1, sel_lit_not_rs2, is_jalr : std_logic;
  signal cpuclk : std_logic;

begin
  my_decode : instruction_decode port map(instruction, pc_in,
					  pc, lit, jumplit,
					  addr_of_rs1, addr_of_rs2, addr_of_rd,
					  aluop,
					  sel_pc_not_rs1, sel_lit_not_rs2, is_jalr,
					  cpuclk);

  process begin

  -- ADD x7, x3, x2
  instruction(31 downto 25) <= "0000000"; --hardcode
  instruction(24 downto 20) <= "00010"; -- x3 rs2
  instruction(19 downto 15) <= "00011"; -- x2 rs1
  instruction(14 downto 12) <= "000"; -- func
  instruction(11 downto 7) <= "00111"; -- x7 rd
  instruction(6 downto 0) <= "0110011"; -- opcode
  
  pc_in<=x"00000000";
  
  cpuclk <= '0'; wait for 1 fs; cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  
  if pc/=x"00000000" then
  report "pc is wrong" severity failure;
  end if;
  
  if addr_of_rs1/="00011" then
  report "rs1 is wrong" severity failure;
  end if;

	 if addr_of_rs2/="00010" then
  report "rs2 is wrong" severity failure;
  end if;
  
   if addr_of_rs2/="00010" then
  report "rs2 is wrong" severity failure;
  end if;
  
   if addr_of_rd/="00111" then
  report "rd is wrong" severity failure;
  end if;
  
   if aluop/="00000" then
  report "aluop is wrong" severity failure;
  end if;
  
  if sel_pc_not_rs1/='0' then
  report "pc selected instead of rs1" severity failure;
  end if;
  
  if sel_lit_not_rs2/='0' then
  report "lit selected instead of rs2" severity failure;
  end if;
  
  
	  -- BEQ 0, x4, x5
  instruction(31) <= '0'; --imm
  instruction(30 downto 25) <= "000000"; -- imm
  instruction(24 downto 20) <= "00100"; -- x4 rs2
  instruction(19 downto 15) <= "00101"; -- x5 rs1
  instruction(14 downto 12) <= "000"; -- func
  instruction(11 downto 8) <= "0000"; -- imm
  instruction(7) <= '0'; --imm
  instruction(6 downto 0) <= "1100011"; --opcode
  
  pc_in<=x"00000000";
  
  cpuclk <= '0'; wait for 1 fs; cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
  
  if pc/=x"00000000" then
  report "pc is wrong" severity failure;
  end if;
  
  if jumplit/="00000000000000000000000000000000" then
  report "jumplit is wrong" severity failure;
  end if;
    
  if addr_of_rs1/="00101" then
  report "rs1 is wrong" severity failure;
  end if;

	 if addr_of_rs2/="00100" then
  report "rs2 is wrong" severity failure;
  end if;
  
   if addr_of_rd/="00000" then
  report "rd is wrong" severity failure;
  end if;
  
   if aluop/="1-000" then
  report "aluop is wrong" severity failure;
  end if;
  
  if sel_pc_not_rs1/='0' then
  report "pc selected instead of rs1" severity failure;
  end if;
  
  if sel_lit_not_rs2/='0' then
  report "lit selected instead of rs2" severity failure;
  end if; 
   
    
    report "end of instruction_decode_tb -- reaching here is: test OK";
    wait;
  end process;
end architecture;
