library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_cache is port(
  pc_value : in std_logic_vector(31 downto 0);
  ir_2_cpu : out std_logic_vector(31 downto 0);
  cpuclk : in std_logic;
  cachehit : out std_logic
); end entity;


architecture behav of instruction_cache is
  type rom_type is array (0 to 255) of std_logic_vector(31 downto 0);
  signal rom : rom_type := (
                   -- main:
    x"12300093",   --   addi	x1,zero,0x123
                   -- loop:
    x"00108093",   --   addi	x1,x1,1
    x"ffdfffef",   --   jal	x31,loop
  others=>x"00000000");
  signal from_rom : std_logic_vector(31 downto 0);

  type i_cache_type is array (0 to 1023) of std_logic_vector(52 downto 0);
  signal i_cache : i_cache_type := (others=>"00000000000000000000000000000000000000000000000000000");

  signal cache_line : natural;
  signal pc_hi : std_logic_vector(31 downto 12);
  signal tag : std_logic_vector(52 downto 33);
  signal valid : std_logic;
  signal my_cachehit : std_logic;
  signal write_cache : std_logic := '0';
  signal delay : std_logic_vector(3 downto 0) := "0000";

begin
  pc_hi <= pc_value(31 downto 12);
  cache_line <= to_integer(unsigned(pc_value(11 downto 2)));

  tag      <= i_cache(cache_line)(52 downto 33);
  valid    <= i_cache(cache_line)(32);
  ir_2_cpu <= i_cache(cache_line)(31 downto 0);

  my_cachehit <= '1' when pc_hi=tag and valid='1'  else  '0';
  cachehit <= my_cachehit;

  process (cpuclk) begin
    if falling_edge(cpuclk) then
      if write_cache='1' then
        i_cache(cache_line)(52 downto 33) <= pc_hi;
        i_cache(cache_line)(32) <= '1';
        i_cache(cache_line)(31 downto 0) <= from_rom;
      end if;
    end if;
  end process;

  process (cpuclk) begin
    if falling_edge(cpuclk) then
      write_cache <= '0';
      case delay is
        when "0000" => if my_cachehit='0' then delay <= "0100"; end if;
        when "0100" => delay <= "0011";
        when "0011" => delay <= "0010";
        when "0010" => delay <= "0001"; write_cache <= '1';
        when "0001" => delay <= "0000";
        when others => delay <= "0000";
      end case;
    end if;
  end process;

  from_rom <= rom(to_integer(unsigned(pc_value(9 downto 2))));

end architecture;
