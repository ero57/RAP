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
  signal pc, lit, jumplit : std_logic_vector(31 downto 0) := x"00000000";
  signal addr_of_rs1, addr_of_rs2, addr_of_rd : std_logic_vector(4 downto 0) := "00000";
  signal aluop : std_logic_vector(4 downto 0) := "00000";
  signal sel_pc_not_rs1, sel_lit_not_rs2, is_jalr : std_logic := '0';
  signal cpuclk : std_logic := '0';

  signal jumpdest : std_logic_vector(31 downto 0) := x"ffffffff";
  signal do_jump : std_logic := '1';

  signal debug_rd : std_logic_vector(31 downto 0) := x"ffffffff";
  signal debug_addr_of_rd : std_logic_vector(4 downto 0) := "11111";

begin
  rewe: rechenwerk port map(pc, lit, jumplit,
			    addr_of_rs1, addr_of_rs2, addr_of_rd,
			    aluop,
			    sel_pc_not_rs1, sel_lit_not_rs2, is_jalr,
			    cpuclk,

			    jumpdest,
			    do_jump,

			    debug_rd,
			    debug_addr_of_rd);

  process begin
    -- schreibe 12345678 in register 14
    addr_of_rs1 <= "00000"; sel_pc_not_rs1 <= '0';   -- reg zero
    lit <= x"12345678"; sel_lit_not_rs2 <= '1';      -- literal
    aluop <= "00110";                                -- or
    addr_of_rd <= "01110";                           -- store in x14
    cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
    lit <= x"00000000"; sel_lit_not_rs2 <= '0';
    aluop <= "00000";
    addr_of_rd <= "00000";
    cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
    --report to_string(debug_addr_of_rd) & " " & integer'image(to_integer(unsigned(debug_rd)));
    if debug_addr_of_rd /= "01110" then
      report "debug_addr_of_rd is " & to_string(debug_addr_of_rd) & ", should be 01110" severity failure; 
    end if;
    if debug_rd /= x"12345678" then
      report "debug_rd is " & to_string(debug_addr_of_rd) & ", should be 12345678" severity failure;
    end if;
    cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs; -- really store the value

    -- addiere pc=b und lit=1 nach register 9
    pc <= x"0000000b"; sel_pc_not_rs1 <= '1';   -- pc
    lit <= x"00000001"; sel_lit_not_rs2 <= '1'; -- literal
    aluop <= "00000";                           -- add
    addr_of_rd <= "01001";                      -- store in x9
    cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
    pc <= x"00000000"; sel_pc_not_rs1<='0';
    lit <= x"00000000"; sel_lit_not_rs2 <= '0';
    aluop <= "00000";
    addr_of_rd <= "00000";
    cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
    --report to_string(debug_addr_of_rd) & " " & to_string(debug_rd);
    if debug_addr_of_rd /= "01001" then
      report "debug_addr_of_rd is " & to_string(debug_addr_of_rd) & ", should be 01001" severity failure; 
    end if;
    if debug_rd /= x"0000000c" then
      report "debug_rd is " & to_string(debug_addr_of_rd) & ", should be 0000000c" severity failure;
    end if;
    cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs; -- really store the value

    -- addiere reg 9 und reg 14 nach reg 30
    addr_of_rs1 <= "01001"; sel_pc_not_rs1 <= '0';   -- reg 9
    addr_of_rs2 <= "01110"; sel_lit_not_rs2 <= '0';  -- reg 14
    aluop <= "00000";                                -- add
    addr_of_rd <= "11110";                           -- store in x30
    cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
    addr_of_rs1 <= "00000"; sel_pc_not_rs1 <= '0';
    addr_of_rs2 <= "00000"; sel_lit_not_rs2 <= '0';
    aluop <= "00000";
    addr_of_rd <= "00000";
    cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
    --report integer'image(to_integer(unsigned(debug_addr_of_rd))) & " " & integer'image(to_integer(unsigned(debug_rd)));
    if debug_addr_of_rd /= "11110" then
      report "debug_addr_of_rd is " & to_string(debug_addr_of_rd) & ", should be 11110" severity failure; 
    end if;
    if debug_rd /= x"12345684" then
      report "debug_rd is " & to_string(debug_addr_of_rd) & ", should be 12345684" severity failure;
    end if;
    cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs; -- really store the value

    -- addiere jumplit plus pc
    jumplit <= x"0ffedead";
    is_jalr <= '0';
    pc <= x"00003000";
    cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
    --report to_string(jumpdest);
    cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
    jumplit <= x"00000000";
    is_jalr <= '0';
    pc <= x"00000000";
    if jumpdest /= x"0fff0ead" then
      report "jumpdest is " & to_string(jumpdest) & ", should be 0fff0ead" severity failure;
    end if;

    -- addiere jumplit plus reg 9 (has value 0x0c)
    jumplit <= x"0ffedead";
    is_jalr <= '1';
    addr_of_rs1 <= "01001";
    cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
    --report integer'image(to_integer(unsigned(jumpdest)));
    jumplit <= x"00000000";
    is_jalr <= '0';
    addr_of_rs1 <= "00000";
    if jumpdest /= x"0ffedeb9" then
      report "jumpdest is " & to_string(jumpdest) & ", should be 0ffedeb9" severity failure;
    end if;

    report "rechenwerk_tb ended - reaching here means TEST OK";
    wait;
  end process;
end architecture;
