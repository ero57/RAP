library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity milestone1_with_instruction_cache_tb is end entity;

architecture behav of milestone1_with_instruction_cache_tb is

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
    debug_addr_of_rd : out std_logic_vector(4 downto 0);
    debug_mem_ready : out std_logic
  ); end component;

  signal cpuclk : std_logic;
  signal debug_rd : std_logic_vector(31 downto 0);
  signal debug_addr_of_rd : std_logic_vector(4 downto 0);
  signal debug_mem_ready : std_logic;

  type exrd is array (0 to 255) of std_logic_vector(31 downto 0);
  signal expectrd : exrd := (
                   -- main:
    x"00000123",   --   addi    x1,zero,0x123
                   -- loop:
    x"00108093",   --   addi    x1,x1,1
    x"ffdfffef",   --   jal     x31,loop

  others=>x"00000000");

begin
  my_cpu: milestone1  port map(cpuclk, debug_rd, debug_addr_of_rd, debug_mem_ready);

  process
    variable count : integer := 1000;
    variable cnt8 : integer := -1;
    variable x1val : integer := 256+32+3;
    variable pcval : integer := 0;
    variable miss4 : integer := 0;
  begin
    cpuclk <= '0'; wait for 1 fs;

    while true loop
      count := count - 1;
      if count=0 then
	report "Test end forced after 100 cpu clks";
        report "cache misses for address 4: " & integer'image(miss4);
        if miss4 > 7 then
          report "That's too much. Test failed." severity failure;
        end if;
	report "That's ok --- Test success";
	wait;
      end if;
      cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs; 

      if debug_mem_ready='0' then
        if pcval=4 then
          miss4 := miss4 + 1;
        end if;
        --report "cache miss " & integer'image(pcval);
      --else
        --report "            hit" & integer'image(pcval);
      end if;

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
        --report "addr_of_rd=" & to_string(debug_addr_of_rd) & " rd=" & to_string(debug_rd);
        if pcval=0  or  pcval=4  then
	  if debug_addr_of_rd/="00001"   or  to_integer(unsigned(debug_rd))/=x1val then
	    report "expected: addr_of_rd=00001 rd=" & integer'image(x1val) severity failure;
	  end if;
	  x1val := x1val + 1;
          pcval := pcval + 4;
        elsif pcval=8 then
	  if debug_addr_of_rd/="11111"   or  debug_rd/=x"0000000c" then
	    report "expected: addr_of_rd=00001 rd=" & integer'image(x1val) severity failure;
	  end if;
          pcval := 4;
        else
          report "pcval ist weggelaufen ..." severity failure;
        end if;
      elsif cnt8>=0 then
        if debug_rd/=x"00000000"  or  debug_addr_of_rd/="00000" then
          report "expected nop" severity failure;
        end if;
      end if;
    end loop;
  end process;
end architecture;
