library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity adder32 is
  port (
    a     : in std_logic_vector(31 downto 0);
    b     : in std_logic_vector(31 downto 0);
    sum   : out std_logic_vector(31 downto 0)
   -- carry : out std_logic
  );
end entity adder32;

architecture behavioural of adder32 is

begin
	sum <= std_logic_vector(signed(a) + signed(b));
end behavioural;
