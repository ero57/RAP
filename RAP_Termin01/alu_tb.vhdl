library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is end entity;

architecture a of alu_tb is
  component alu is port (
    op1, op2 : in std_logic_vector(31 downto 0);
    aluout : out std_logic_vector(31 downto 0);
    aluop : in std_logic_vector(4 downto 0);
    do_jump : out std_logic
  ); end component;
  signal op1, op2 : std_logic_vector(31 downto 0) := (others => '0');
  signal aluout : std_logic_vector(31 downto 0) := (others => '0'); 
  signal aluop : std_logic_vector(4 downto 0) := (others => '0');
  signal do_jump : std_logic := '0';


begin
  my_alu: alu port map(op1, op2, aluout, aluop, do_jump);
  process
  begin
  aluop <= "00000";
	for i in 0 to 31 loop
	 for j in 0 to 31 loop
	  op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
	  op2 <= std_logic_vector(shift_left(to_unsigned(1, 32),j));
	      wait for 1 fs;
	      if aluout /= std_logic_vector(signed(op1) + signed(op2)) then
		report "addition falsch" severity failure;
	      end if;
	      if do_jump /= '0' then
		report "do_jump bei addition falsch" severity failure;
	      end if;
	    end loop;
	end loop;
aluop <= "00001";
	for i in 0 to 31 loop
	 for j in 0 to 31 loop
	  op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
	  op2 <= std_logic_vector(shift_left(to_unsigned(1, 32),j));
	      wait for 1 fs;
	      if aluout /= std_logic_vector(shift_left(signed(op1), to_integer(unsigned(op2(4 downto 0))))) then
		report "sll falsch" severity failure;
	      end if;
	      if do_jump /= '0' then
		report "do_jump bei sll falsch" severity failure;
	      end if;
	    end loop;
	end loop;
--aluop <= "00010";
--	for i in 0 to 31 loop
--	 for j in 0 to 31 loop
--	  op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
--	  op2 <= std_logic_vector(shift_left(to_unsigned(1, 32),j));
--	      wait for 1 fs;;
--	      if aluout(0) /= '0' then
--		report "addition falsch" severity failure;
--	      end if;
--	      if do_jump /= '0'  then
--		report "do_jump bei addition falsch" severity failure;
--	      end if;
--	    end loop;
--	end loop;
  aluop <= "00100";
	for i in 0 to 31 loop
	 for j in 0 to 31 loop
	  op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
	  op2 <= std_logic_vector(shift_left(to_unsigned(1, 32),j));
	      wait for 1 fs;
	      if aluout /= (op1 xor op2) then
		report "xor falsch" severity failure;
	      end if;
	      if do_jump /= '0' then
		report "do_jump bei xor falsch" severity failure;
	      end if;
	    end loop;
	end loop;
 aluop <= "00101";
	for i in 0 to 31 loop
	 for j in 0 to 31 loop
	  op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
	  op2 <= std_logic_vector(shift_left(to_unsigned(1, 32),j));
	      wait for 1 fs;
	      if aluout /= std_logic_vector(shift_right(unsigned(op1),to_integer(unsigned(op2(4 downto 0)))))then
		report "srl falsch" severity failure;
	      end if;
	      if do_jump /= '0' then
		report "do_jump bei srl falsch" severity failure;
	      end if;
	    end loop;
	end loop;
 aluop <= "00110";
	for i in 0 to 31 loop
	 for j in 0 to 31 loop
	  op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
	  op2 <= std_logic_vector(shift_left(to_unsigned(1, 32),j));
	      wait for 1 fs;
	      if aluout /= (op1 or op2) then
		report "or falsch" severity failure;
	      end if;
	      if do_jump /= '0' then
		report "do_jump bei or falsch" severity failure;
	      end if;
	    end loop;
	end loop;
 aluop <= "00111";
	for i in 0 to 31 loop
	 for j in 0 to 31 loop
	  op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
	  op2 <= std_logic_vector(shift_left(to_unsigned(1, 32),j));
	      wait for 1 fs;
	      if aluout /= (op1 and op2) then
		report "and falsch" severity failure;
	      end if;
	      if do_jump /= '0' then
		report "do_jump bei and falsch" severity failure;
	      end if;
	    end loop;
	end loop;
 aluop <= "01000";
	for i in 0 to 31 loop
	 for j in 0 to 31 loop
	  op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
	  op2 <= std_logic_vector(shift_left(to_unsigned(1, 32),j));
	      wait for 1 fs;
	      if aluout /= std_logic_vector(signed(op1) - signed(op2)) then
		report "subtraktion falsch" severity failure;
	      end if;
	      if do_jump /= '0' then
		report "do_jump bei subtraktion falsch" severity failure;
	      end if;
	    end loop;
	end loop;
aluop <= "01101";
	for i in 0 to 31 loop
	 for j in 0 to 31 loop
	  op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
	  op2 <= std_logic_vector(shift_left(to_unsigned(1, 32),j));
	      wait for 1 fs;
	      if aluout /= std_logic_vector(shift_right(signed(op1),to_integer(unsigned(op2(4 downto 0)))))  then
		report "sra falsch" severity failure;
	      end if;
	      if do_jump /= '0' then
		report "do_jump bei sra falsch" severity failure;
	      end if;
	    end loop;
	end loop;
aluop <= "10000";
	for i in 0 to 31 loop
	 for j in 0 to 31 loop
	  op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
	  op2 <= std_logic_vector(shift_left(to_unsigned(1, 32),j));
	      wait for 1 fs;
	      if aluout /= '1' then
		report "sra falsch" severity failure;
	      end if;
	      if do_jump /= '0' then
		report "do_jump bei sra falsch" severity failure;
	      end if;
	    end loop;
	end loop;



    report "end of alu_tb -- reaching here is: test OK";
    wait; -- simulation beenden
  end process;
end architecture;
