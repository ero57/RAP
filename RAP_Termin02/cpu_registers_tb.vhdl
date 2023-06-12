library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_registers_tb is end cpu_registers_tb;

architecture behav of cpu_registers_tb is

  component cpu_registers is port(
    addr_of_rs1, addr_of_rs2 : in std_logic_vector(4 downto 0);
    rs1, rs2 : out std_logic_vector(31 downto 0);
    addr_of_rd : in std_logic_vector(4 downto 0);
    rd : in std_logic_vector(31 downto 0);
    clk : in std_logic
  ); end component;
  signal addr_of_rs1, addr_of_rs2 : std_logic_vector(4 downto 0) := "00000"; -- discard warnings by presetting
  signal rs1, rs2 : std_logic_vector(31 downto 0);
  signal addr_of_rd : std_logic_vector(4 downto 0) := "00000";
  signal rd : std_logic_vector(31 downto 0);
  signal clk : std_logic := '0';

begin
  my_cpu_registers : cpu_registers port map (addr_of_rs1, addr_of_rs2, rs1, rs2, addr_of_rd, rd, clk);

  process begin
    -- Write to register 5
    addr_of_rd <= "00101";
    rd <= x"00000001";
    wait for 1 fs;
    clk <= '1';
    assert rs1 /= x"00000001" report "Error: rs1 value is incorrect" severity failure;
    wait for 1 fs;
    clk <= '0';
    
    -- Read from register 5
    addr_of_rs1 <= "00101";
    wait for 1 fs;
    assert rs1 = x"00000001" report "Error: rs1 value is incorrect" severity failure;
    
    addr_of_rd <= "00111";
    rd <= x"00000001";
    
    addr_of_rs1 <= "00111";
    wait for 1 fs;
    assert rs1 /= x"00000001" report "Error: rs1 value is incorrect" severity failure;
    
    -- Write to register 8
    addr_of_rd <= "01000";
    rd <= x"00000011";
    wait for 1 fs;
    clk <= '1';
    assert rs2 /= x"00000011" report "Error: rs2 value is incorrect" severity failure;
    wait for 1 fs;
    clk <= '0';
    
    -- Read from register 8
    addr_of_rs2 <= "01000";
    wait for 1 fs;
    assert rs2 = x"00000011" report "Error: rs2 value is incorrect" severity failure;
	
	-- Test simulteanous read and write	
	addr_of_rd <= "00001";
	rd <= x"00000001";
	addr_of_rs1 <= "00001";	
	clk <= '1';
	wait for 1 fs;
	assert (rs1 /= x"00000001") report "Write test failed!" severity failure;
	clk <= '0';
	wait for 1 fs;
	assert (rs1 = x"00000001") report "Simulteanous read and write test failed!" severity failure;
     


    -- Write to register 0
    addr_of_rd <= "00000";
    rd <= x"00000001"; 
    wait for 1 fs;
    clk <= '1';
    wait for 1 fs;
    clk <= '0';
    
    -- Read from register 0
    addr_of_rs2 <= "00000";
    wait for 1 fs;
    assert rs2 = x"00000000" report "Error: rs2 value is incorrect" severity failure;
	 report "cpu_registers_tb finished - test OK";  

    wait;
  end process;
end architecture;
