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
  signal from_rom : std_logic_vector(31 downto 0);

begin
  my_cache: instruction_cache port map(pc_value, ir_2_cpu, cpuclk, cachehit);

  -- from_rom <= rom(to_integer(unsigned(pc_value(9 downto 2))));

  process
    variable temp : integer;
  begin
    report "---- reading address 0x00000004";
    pc_value <= x"00000004"; wait for 1 fs;
    for i in 1 to 5 loop
      if cachehit='1' then
        report "Cache responds with cachehit too fast, after " & integer'image(i) & " clocks" severity failure;
      end if;
      cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
    end loop;
    if cachehit/='1'  or  ir_2_cpu/=x"00108093" then
      temp := 0; if cachehit='1' then temp := 1; end if;
      report "cachehit=" & integer'image(temp) & ", ir_2_cpu=" & integer'image(to_integer(unsigned(ir_2_cpu)));
      report "Cache responds with cachehit too late and/or wrong data" severity failure;
    end if;

    report "---- reading address 0x00000014";
    pc_value <= x"00000014"; wait for 1 fs;
    for i in 1 to 5 loop
      if cachehit='1' then
        report "Cache responds with cachehit too fast, after " & integer'image(i) & " clocks" severity failure;
      end if;
      cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
    end loop;
    if cachehit/='1'  or  ir_2_cpu/=x"00000000" then
      temp := 0; if cachehit='1' then temp := 1; end if;
      report "cachehit=" & integer'image(temp) & ", ir_2_cpu=" & integer'image(to_integer(unsigned(ir_2_cpu)));
      report "Cache responds with cachehit too late and/or wrong data" severity failure;
    end if;

    report "---- reading address 0x00000004 again";
    pc_value <= x"00000004"; wait for 1 fs;
    if cachehit/='1'  or  ir_2_cpu/=x"00108093" then
      report "Cache responds with cachehit too late and/or wrong data for address 4" severity failure;
    end if;

    report "---- reading address 0x00000008";
    pc_value <= x"00000008"; wait for 1 fs;
    for i in 1 to 5 loop
      if cachehit='1' then
        report "Cache responds with cachehit too fast, after " & integer'image(i) & " clocks" severity failure;
      end if;
      cpuclk <= '1'; wait for 1 fs; cpuclk <= '0'; wait for 1 fs;
    end loop;
    if cachehit/='1'  or  ir_2_cpu/=x"ffdfffef" then
      temp := 0; if cachehit='1' then temp := 1; end if;
      report "cachehit=" & integer'image(temp) & ", ir_2_cpu=" & integer'image(to_integer(unsigned(ir_2_cpu)));
      report "Cache responds with cachehit too late and/or wrong data" severity failure;
    end if;

    report "---- reading address 0x00000004 again";
    pc_value <= x"00000004"; wait for 1 fs;
    if cachehit/='1'  or  ir_2_cpu/=x"00108093" then
      report "Cache responds with cachehit too late and/or wrong data for address 4" severity failure;
    end if;

    report "cache test end --- looks ok";
    wait;
  end process;
end architecture;
