library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_cache is port(
  pc_value : in std_logic_vector(31 downto 0);
  ir_2_cpu : out std_logic_vector(31 downto 0);
  cpuclk : in std_logic;
  cachehit : out std_logic  -- heisst in der cpu dann "mem_ready"
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

	type cache is array(0 to 1023) of std_logic_vector(52 downto 0);
	signal ic_cache : cache := (others => "00000000000000000000000000000000000000000000000000000");
	signal cache_index : natural;
	signal tag : std_logic_vector(52 downto 33);
	signal valid : std_logic;
	signal pc_in_cache : std_logic_vector(31 downto 12);
	signal write : std_logic := '0';
	signal ic_cachehit : std_logic;
	signal counter : std_logic_vector(2 downto 0) := "000";
begin
	ic_cachehit <= '1' when (pc_in_cache = tag) and valid = '1' else '0';
	cachehit <= ic_cachehit;

	cache_index <= to_integer(unsigned(pc_value(11 downto 2)));
	pc_in_cache <= pc_value(31 downto 12);
	tag <= ic_cache(cache_index)(52 downto 33);
	valid <= ic_cache(cache_index)(32);
	ir_2_cpu <= ic_cache(cache_index)(31 downto 0);

	
	process(cpuclk)
	begin
		if (falling_edge(cpuclk)) then
			if (write = '1') then
				ic_cache(cache_index)(52 downto 33) <= pc_in_cache;
				ic_cache(cache_index)(32) <= '1';
				ic_cache(cache_index)(31 downto 0) <= rom(to_integer(unsigned(pc_value(9 downto 2)))); 
			end if;
		write <= '0';
				case counter is
					when "000" => if ic_cachehit = '0' then counter <= "001"; end if;
					when "001" => counter <= "010";
					when "010" => counter <= "011";
					when "011" => counter <= "100";
								  write <= '1';
					when "100" => counter <= "000";
					when others => counter <= "000";
				end case;
		end if;
	end process;

	
	
end architecture;
