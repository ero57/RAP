library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MUX is
  Port ( SEL : in  STD_LOGIC;
         in1   : in  STD_LOGIC_VECTOR (31 downto 0);
         in2   : in  STD_LOGIC_VECTOR (31 downto 0);
         outline   : out STD_LOGIC_VECTOR (31 downto 0)
        );
end MUX;

architecture Behavioral of MUX is
begin
 outline <= in1 when (SEL = '1') else in2;
end Behavioral;

