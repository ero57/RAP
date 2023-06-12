library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity d_reg_tb is 
end d_reg_tb;

architecture behav of d_reg_tb is

  component d_reg is 
    generic(
      width : natural := 32
    ); 
    port(
      d_in  : in  std_logic_vector((width-1) downto 0);
      clk   : in  std_logic;
      d_out : out std_logic_vector((width-1) downto 0)
    );
  end component;
  signal clk : std_logic := '0';
  signal d_in : std_logic_vector(3 downto 0);
  signal d_out : std_logic_vector(3 downto 0);
  
begin
  DUT : d_reg generic map (width => 4) port map (d_in => d_in, clk => clk, d_out => d_out);
  process
  begin
    
    d_in <= "0000";
    wait for 1 fs;
    clk <= '1'; wait for 1 fs; clk <= '0'; wait for 1 fs;
    assert d_out = "0000" report "Error: d_out value is incorrect" severity failure;
        
    d_in <= "1111";
    wait for 1 fs;
    clk <= '1'; wait for 1 fs;
    assert d_out = "0000" report "Error: d_out value is incorrect" severity failure;

    d_in <= "1100";
    wait for 1 fs;
    clk <= '0'; wait for 1 fs;
    assert d_out = "1100" report " Error: d_out value is incorrect" severity failure;
    
    wait;
  end process;
end behav;
