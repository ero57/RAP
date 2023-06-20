library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity milestone1_with_instruction_cache_tb is end entity;

architecture behav of milestone1_with_instruction_cache_tb is

  -- Konvertiert ein std_logic_vector zu einem String
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

  -- Deklaration der CPU Komponente
  component milestone1 is port (
    cpuclk : in std_logic;
    debug_rd : out std_logic_vector(31 downto 0);
    debug_addr_of_rd : out std_logic_vector(4 downto 0);
    debug_mem_ready : out std_logic
  ); end component;

  -- Signal Deklarationen
  signal cpuclk : std_logic;
  signal debug_rd : std_logic_vector(31 downto 0);
  signal debug_addr_of_rd : std_logic_vector(4 downto 0);
  signal debug_mem_ready : std_logic;

  -- Testdaten
  type exrd is array (0 to 255) of std_logic_vector(31 downto 0);
  signal expectrd : exrd := (
                   -- main:
    x"00000123",   --   addi    x1,zero,0x123
                   -- loop:
    x"00108093",   --   addi    x1,x1,1
    x"ffdfffef",   --   jal     x31,loop

  others=>x"00000000");

begin
  -- Instanziierung der CPU
  my_cpu: milestone1  port map(cpuclk, debug_rd, debug_addr_of_rd, debug_mem_ready);

  -- Haupttestprozess
  process
    variable count : integer := 10000; -- ändern Sie die Anzahl der Taktimpulse auf 10000
    variable miss4 : integer := 0;
  begin
    cpuclk <= '0'; wait for 1 fs;

    -- Haupttestschleife
    while count > 0 loop
      count := count - 1;
      
      cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs; 

      -- Wenn debug_mem_ready = '0' und debug_addr_of_rd = "00001" (Adresse x1), dann erhöhen Sie miss4
      if debug_mem_ready = '0' and debug_addr_of_rd = "00001" then
        miss4 := miss4 + 1;
      end if;
      
      -- Test beenden, wenn count = 0
      if count = 0 then
	report "Test end forced after 10000 cpu clks";
        report "cache misses for address 4: " & integer'image(miss4);
        -- Überprüfen, ob die Anzahl der Cache-Misses unter 20 liegt
        if miss4 > 20 then
          report "That's too much. Test failed." severity failure;
        else
	    report "That's ok --- Test success";
	    wait;
        end if;
      end if;
    end loop;
  end process;
end architecture;
