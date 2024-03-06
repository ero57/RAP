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
  signal dont_count : std_logic := '0';
  
  
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
  variable misses : integer := 0;
  variable x1sum : integer := 291;
  
  begin
  	-- Hauptschleife
    cpuclk <= '0'; wait for 1 fs;
    for i in 0 to 1000 loop
    	if i = 1000 then
    		if misses > 20 then
    			report "to many misses" severity failure;
    		end if;
    		report "Test ok";
    		wait;
    	end if;
    	
     if debug_addr_of_rd = "11111" then
     	dont_count <= '1';
     else 
     	dont_count <= '0';
     end if;
    	
     cpuclk <= '0'; wait for 1 fs;
     
    	-- Ueberpruefen auf Misses
    	if debug_mem_ready = '0' and dont_count = '0' then
    			misses := misses + 1;
    		end if;
    	
			if debug_addr_of_rd /= x"00000001" or to_integer(unsigned(debug_rd)) /= x1sum then
				report "Wrong x1 value" severity failure;
			end if; 

    	x1sum := x1sum +1;
    end loop;
    
    
	--for counter in 1000 to 0 loop
	-- if debug_mem_ready = 0 then miss + 1
	-- if debug_rd 
    report "Oh, oh, nothing done ..." severity failure;
    wait;
  end process;
end architecture;
