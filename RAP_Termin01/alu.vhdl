library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is port (
  op1, op2 : in std_logic_vector(31 downto 0);
  aluout : out std_logic_vector(31 downto 0);
  aluop : in std_logic_vector(4 downto 0);
  do_jump : out std_logic
); end entity;

architecture a of alu is
begin
  process (op1, op2, aluop)
  variable result : std_logic_vector(31 downto 0);
  variable jump : std_logic;
  begin
    case aluop is
      when "00000" => result := std_logic_vector(signed(op1) + signed(op2)); -- add
                      jump := '0'; 
      when "00001" => result := std_logic_vector(shift_left(signed(op1), to_integer(unsigned(op2(4 downto 0))))); --sll
                      jump := '0'; 
      when "00010" => result := (others => '0'); --slt
                      if signed(op1) < signed(op2) then
                        result(0) := '1';
                      end if;
                      jump := '0';
      when "00011" => result := (others => '0');
      		      if unsigned(op1) < unsigned(op2) then
                        result(0) := '1';
                      end if;  -- sltu
                      jump := '0';                              
      when "00100" => result := op1 xor op2; --xor
                      jump := '0';
      when "00101" => result := std_logic_vector(shift_right(unsigned(op1), to_integer(unsigned(op2(4 downto 0))))); -- srl
                      jump := '0'; 
      when "00110" => result := op1 or op2; -- or
                      jump := '0';
      when "00111" => result := op1 and op2; -- and
                      jump := '0';         
      when "01000" => result := std_logic_vector(signed(op1) - signed(op2)); -- sub
                      jump := '0'; 
      when "01001" => result := (others => '0'); -- do not care 
                      jump := '0';
      when "01010" => result := (others => '0'); -- do not care 
                      jump := '0';
      when "01011" => result := (others => '0'); -- do not care 
                      jump := '0';
      when "01100" => result := (others => '0'); -- do not care 
                      jump := '0';                      
      when "01101" => result := std_logic_vector(shift_right(signed(op1), to_integer(unsigned(op2(4 downto 0)))));
      		      jump := '0';
      when "01110" => result := (others => '0'); -- do not care 
                      jump := '0';
      when "01111" => result := (others => '0'); -- do not care 
                      jump := '0';                		                      
      when "10000" | "11000" => result := (others => '0'); -- do not care
                      if op1 = op2 then -- beq
                      		jump := '1';
                      else
                      		jump := '0';
                      end if;
      when "10001" | "11001" => result := (others => '0'); -- do not care
                      if op1 /= op2 then -- bne
                      		jump := '1';
                      else
                      		jump := '0';
                      end if;
      when "10010" | "11010" => result := (others => '0'); -- do not care 
                      jump := '0';
      when "10011" | "11011" => result := std_logic_vector(signed(op1) + 4);
      		      jump := '1';
      when "10100" | "11100" => result := (others => '0'); -- do not care
                      if (signed(op1) < signed(op2)) then -- blt
                      		jump := '1';
                      else
                      		jump := '0';
                      end if;
      when "10101" | "11101" => result := (others => '0'); -- do not care
                      if (signed(op1) >= signed(op2)) then -- bge
                      		jump := '1';
                      else
                      		jump := '0';
                      end if;
      when "10110" | "11110" => result := (others => '0'); -- do not care
                      if (unsigned(op1) < unsigned(op2)) then -- bltu
                      		jump := '1';
                      else
                      		jump := '0';
                      end if;
      when "10111" | "11111"=> result := (others => '0'); -- do not care
                      if (unsigned(op1) >= unsigned(op2)) then -- bgeu
                      		jump := '1';
                      else
                      		jump := '0';
                      end if;                                                 		      		                                  
      when others => result := (others => '0');
	  			jump := '0';
	  end case;
	  aluout <= result;
	  do_jump <= jump;
	end process;
end architecture;
    
