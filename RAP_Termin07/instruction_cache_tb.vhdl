library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_cache_tb is end entity;

architecture behav of instruction_cache_tb is

  component instruction_cache is port(
    pc_value : in std_logic_vector(31 downto 0);
    ir_2_cpu : out std_logic_vector(31 downto 0);
    cpuclk : in std_logic;
    cachehit : out std_logic
  ); end component;
  signal pc_value : std_logic_vector(31 downto 0) := x"00000000";
  signal ir_2_cpu : std_logic_vector(31 downto 0);
  signal cpuclk : std_logic := '0';
  signal cachehit : std_logic;

  type rom_type is array (0 to 255) of std_logic_vector(31 downto 0);
  signal rom : rom_type := (
                   -- main:
    x"12300093",   --   addi	x1,zero,0x123
                   -- loop:
    x"00108093",   --   addi	x1,x1,1
    x"ffdfffef",   --   jal	x31,loop
  others=>x"00000000");

begin
  my_cache: instruction_cache port map(pc_value, ir_2_cpu, cpuclk, cachehit);

  process
  begin
  -- Addresse an x"00000000" lesen, befehl  addi	x1,zero,0x123)
  pc_value <= x"00000000";
  wait for 1 fs;
  for i in 0 to 4 loop
  	if cachehit = '1' then report "Cache reagiert zu früh" severity failure;
  	end if;
  	cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs; cpuclk <= '1'; wait for 1 fs;
  end loop; 
  if cachehit /= '1' then report "Cache reagiert zu spät" severity failure;
  end if;
  if ir_2_cpu /= x"12300093" then report "Falsche Daten";
  end if;
  
    -- Addresse an x"00000004" lesen, befehl addi	x1,x1,1)
  pc_value <= x"00000004";
  wait for 1 fs;
  for i in 0 to 4 loop
  	if cachehit = '1' then report "Cache reagiert zu früh" severity failure;
  	end if;
  	cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs; cpuclk <= '1'; wait for 1 fs;
  end loop; 
  if cachehit /= '1' then report "Cache reagiert zu spät" severity failure;
  end if;
  if ir_2_cpu /= x"00108093" then report "Falsche Daten";
  end if;
  
  -- Addresse an x"00000008" lesen, befehl jal	x31,loop)
  pc_value <= x"00000008";
  wait for 1 fs;
  for i in 0 to 4 loop
  	if cachehit = '1' then report "Cache reagiert zu früh" severity failure;
  	end if;
  	cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs; cpuclk <= '1'; wait for 1 fs;
  end loop; 
  if cachehit /= '1' then report "Cache reagiert zu spät" severity failure;
  end if;
  if ir_2_cpu /= x"ffdfffef" then report "Falsche Daten";
  end if;
    -- report "cache test has no tests yet --- failure" severity failure;

    report "cache test end --- looks ok";
    wait;
  end process;
end architecture;
