library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity milestone1_tb is end entity;

architecture behav of milestone1_tb is

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

  component milestone1 is port (
    cpuclk : in std_logic;

    debug_rd : out std_logic_vector(31 downto 0);
    debug_addr_of_rd : out std_logic_vector(4 downto 0)
  ); end component;

  signal cpuclk : std_logic;
  signal debug_rd : std_logic_vector(31 downto 0);
  signal debug_addr_of_rd : std_logic_vector(4 downto 0);

  type exrd is array (0 to 255) of std_logic_vector(31 downto 0);
  signal expectrd : exrd := (
    x"00000123",
    x"000000ff",
    x"00000222",
    x"00000010",

    x"00000555",
    x"00000333",
    x"00000888", -- add
    x"00000222",
    x"2aa80000", -- sll
    x"00000000",
    x"00000000",
    x"00000666", -- xor
    x"00000000",
    x"00000000",
    x"00000777",
    x"00000111", -- and

    x"00000555",
    x"00000554", -- addi
    x"00000000", -- slti
    x"00000001",
    x"00000476",
    x"fffffd57", -- ori
    x"00000015",
    x"00005550",
    x"00000055",
    x"00000005", -- srai

    x"00000555",
    x"00000333",
    "--------------------------------", -- beq
    "--------------------------------", -- bne
    x"00000445",
    "--------------------------------", -- bge
    "--------------------------------", -- blt
    x"00000446",
    "--------------------------------", -- bgeu
    "--------------------------------", -- bltu
    x"000004c6",

    x"12345000", -- lui
    x"000000a8", -- auipc
    x"000000b8",
    x"000000b4", -- jalr
    x"00000042",

    x"82934450", -- strange random value to stop test
  others=>x"00000000");

  type exard is array (0 to 255) of std_logic_vector(4 downto 0);
  signal expectard : exard := (
    "00001",
    "00010",
    "00011",
    "11111",

    "00100",
    "00101",
    "00110",
    "00111",
    "01000",
    "01001",
    "01010",
    "01011",
    "01100",
    "01101",
    "01110",
    "01111",

    "00100",
    "10000",
    "10001",
    "10010",
    "10011",
    "10100",
    "10101",
    "10110",
    "10111",
    "11000",

    "00100",
    "00101",
    "00000",  -- beq
    "00000",  -- bne
    "00001",
    "00000",  -- bge
    "00000",  -- blt
    "00001",
    "00000",  -- bgeu
    "00000",  -- bltu
    "00001",

    "11001",  -- lui
    "11010",  -- auipc
    "11110",
    "11111",  -- jalr
    "00001",

  others=>"00000");


begin
  my_cpu: milestone1  port map(cpuclk, debug_rd, debug_addr_of_rd);

  process
    variable count : integer := 1000;
    variable cnt8 : integer := -1;
    variable excnt : integer := 0;
  begin
    cpuclk <= '0'; wait for 1 fs;

    while expectrd(excnt)/=x"82934450" loop
      count := count - 1;
      if count=0 then
	report "Test end forced after 100 cpu clks";
	wait;
      end if;
      cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs; 

      if cnt8<0  and debug_addr_of_rd/="00000" then
        report "sync!";
        cnt8:=8;
      elsif cnt8>=0 then
        cnt8:=cnt8-1;
        if cnt8=0 then
          cnt8:=8;
        end if;
      end if;
      if cnt8=8 then
        report "addr_of_rd=" & to_string(debug_addr_of_rd) & " rd=" & to_string(debug_rd);
        if debug_addr_of_rd/=expectard(excnt) then
          report "expected: addr_of_rd=" & to_string(expectard(excnt)) & " rd=" & to_string(expectrd(excnt)) severity failure;
        end if;
        if expectrd(excnt)/="--------------------------------"  and  expectrd(excnt)/=debug_rd then
          report "expected: addr_of_rd=" & to_string(expectard(excnt)) & " rd=" & to_string(expectrd(excnt)) severity failure;
        end if;
        excnt := excnt + 1;
      elsif cnt8>=0 then
        if debug_rd/=x"00000000"  or  debug_addr_of_rd/="00000" then
          report "expected nop" severity failure;
        end if;
      end if;

    end loop;
    report "end of test milestone1 - test ok";
    wait;

  end process;
end architecture;
