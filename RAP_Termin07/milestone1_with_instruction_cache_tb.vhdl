library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity milestone1_with_instruction_cache_tb is end entity;

architecture behav of milestone1_with_instruction_cache_tb is

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
    x"00000123",
    x"00108093",
    x"ffdfffef",
  others=>x"00000000");

begin
  my_cpu: milestone1  port map(cpuclk, debug_rd, debug_addr_of_rd, debug_mem_ready);

  process
    variable totalTestCycles : integer := 1000;
    variable synchronizationCounter : integer := -1;
    variable expectedRegisterValue : integer := 256+32+3;
    variable programCounterValue : integer := 0;
    variable cacheMissCounter : integer := 0;
  begin
    cpuclk <= '0'; wait for 1 fs;

    while true loop
      totalTestCycles := totalTestCycles - 1;
      if totalTestCycles=0 then
	report "Test end forced after 100 cpu clks";
        report "cache misses for address 4: " & integer'image(cacheMissCounter);
        if cacheMissCounter > 7 then
          report "That's too much. Test failed." severity failure;
        end if;
	report "That's ok --- Test success";
	wait;
      end if;
      cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs; 

      if debug_mem_ready='0' then
        if programCounterValue=4 then
          cacheMissCounter := cacheMissCounter + 1;
        end if;
      end if;

      if synchronizationCounter<0  and debug_addr_of_rd/="00000" then
        report "sync!";
        synchronizationCounter:=8;
      elsif synchronizationCounter>=0 then
        synchronizationCounter:=synchronizationCounter-1;
        if synchronizationCounter=0 then
          synchronizationCounter:=8;
        end if;
      end if;
      if synchronizationCounter=8 then
        if programCounterValue=0  or  programCounterValue=4  then
	  if debug_addr_of_rd/="00001"   or  to_integer(unsigned(debug_rd))/=expectedRegisterValue then
	    report "expected: addr_of_rd=00001 rd=" & integer'image(expectedRegisterValue) severity failure;
	  end if;
	  expectedRegisterValue := expectedRegisterValue + 1;
          programCounterValue := programCounterValue + 4;
        elsif programCounterValue=8 then
	  if debug_addr_of_rd/="11111"   or  debug_rd/=x"0000000c" then
	    report "expected: addr_of_rd=00001 rd=" & integer'image(expectedRegisterValue) severity failure;
	  end if;
          programCounterValue := 4;
        else
          report "programCounterValue ran away ..." severity failure;
        end if;
      elsif synchronizationCounter>=0 then
        if debug_rd/=x"00000000"  or  debug_addr_of_rd/="00000" then
          report "expected nop" severity failure;
        end if;
      end if;
    end loop;
  end process;
end architecture;
