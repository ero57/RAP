library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_fetch is port (
  jumpdest : in std_logic_vector(31 downto 0);
  do_jump : in std_logic;
  cpuclk : in std_logic;
  pc, ir : out std_logic_vector(31 downto 0)
); end entity;


architecture behav of instruction_fetch is

  component d_reg is generic(
    width : natural := 32
  ); port(
    d_in : in std_logic_vector((width-1) downto 0);
    clk : in std_logic;
    d_out : out std_logic_vector((width-1) downto 0)
  ); end component;

  signal real_pc, pc_plus_4, pc_plus_4_or_0, pc_in, ir_in : std_logic_vector(31 downto 0);
  signal use_nop : std_logic := '1';
  signal count : std_logic_vector(2 downto 0) := "001";

  type rom_type is array (0 to 255) of std_logic_vector(31 downto 0);
  signal rom : rom_type := (
                   -- main:
    x"12300093",   --   addi	x1,zero,0x123   ; 0x123
    x"0ff00113",   --   addi	x2,zero,0xff    ; 0xff
    x"002081b3",   --   add	x3,x1,x2        ; 0x222
                   -- 
    x"00800fef",   --   jal	x31,skip
    x"32100093",   --   addi	x1,zero,0x321   ; never expect: 0x321
                   -- skip:
                   -- 
                   -- ; test all arith/log reg-reg instructions, results should be:
    x"55506213",   --   ori	x4,zero,0x555 ; 0x555
    x"33304293",   --   xori	x5,zero,0x333 ; 0x333
    x"00520333",   --   add	x6,x4,x5     ; 0x888
    x"405203b3",   --   sub	x7,x4,x5     ; 0x222
    x"00521433",   --   sll	x8,x4,x5     ; ...
    x"005224b3",   --   slt	x9,x4,x5     ; 0
    x"00523533",   --   sltu	x10,x4,x5    ; 0
    x"005245b3",   --   xor	x11,x4,x5    ; 0x666
    x"00525633",   --   srl	x12,x4,x5    ; 0
    x"405256b3",   --   sra	x13,x4,x5    ; 0
    x"00526733",   --   or	x14,x4,x5    ; 0x777
    x"005277b3",   --   and	x15,x4,x5    ; 0x111
                   -- 
                   -- ; test all arith/log literal instructions, results should be:
    x"55506213",   --   ori	x4,zero,0x555     ; 0x555
    x"fff20813",   --   addi	x16,x4,0xffffffff ; 0x554
    x"12322893",   --   slti	x17,x4,0x123      ; 0
    x"80023913",   --   sltiu	x18,x4,0xfffff800 ; 1
    x"12324993",   --   xori	x19,x4,0x123      ; 0x476
    x"80226a13",   --   ori	x20,x4,0xfffff802 ; 0xfffffd57
    x"81f27a93",   --   andi	x21,x4,0xfffff81f ; 0x15
    x"00421b13",   --   slli	x22,x4,4          ; 0x5550
    x"00425b93",   --   srli	x23,x4,4          ; 0x55
    x"40825c13",   --   srai	x24,x4,8          ; 5
                   -- 
                   -- ; test all branches, some shall be taken, some not
    x"55506213",   --   ori	x4,zero,0x555     ; 0x555
    x"33304293",   --   xori	x5,zero,0x333     ; 0x333
    x"00420463",   --   beq	x4,x4,take_it_1
    x"32100093",   --   addi	x1,zero,0x321   ; never expect: 0x321
                   -- take_it_1:
    x"00421463",   --   bne	x4,x4,do_not_take_it_1
    x"44500093",   --   addi	x1,zero,0x445   ; 0x445
                   -- do_not_take_it_1:
    x"00525463",   --   bge	x4,x5,take_it_2
    x"32100093",   --   addi	x1,zero,0x321   ; never expect: 0x321
                   -- take_it_2:
    x"00524463",   --   blt	x4,x5,do_not_take_it_2
    x"44600093",   --   addi	x1,zero,0x446   ; 0x446
                   -- do_not_take_it_2:
    x"00527463",   --   bgeu	x4,x5,take_it_3
    x"32100093",   --   addi	x1,zero,0x321   ; never expect: 0x321
                   -- take_it_3:
    x"00526463",   --   bltu	x4,x5,do_not_take_it_3
    x"4c600093",   --   addi	x1,zero,0x4c6   ; 0x4c6
                   -- do_not_take_it_3:
                   -- 
                   -- ; test remaining instructions
    x"12345cb7",   --   lui	x25,0x12345	; 0x12345000
    x"00000d17",   --   auipc   x26,0           ; 0xa8
    x"0b800f13",   --   addi	x30,zero,hier_gehts_weiter-main
    x"000f0fe7",   --   jalr	x30,x31,0
    x"32300093",   --   addi	x1,zero,0x323   ; never expect: 0x323
                   -- hier_gehts_weiter:
                   -- 
    x"04200093",   --   addi	x1,zero,0x42    ; 0x42 special value: stop simulation
  others=>x"00000000");

begin
  pc_plus_4 <= std_logic_vector(unsigned(real_pc) + 4);
  pc_plus_4_or_0 <= real_pc when use_nop='1' else pc_plus_4;
  pc_in <= jumpdest when do_jump='1' else pc_plus_4_or_0;
  the_pc: d_reg generic map(32) port map(pc_in, cpuclk, real_pc);
  pc_12: d_reg generic map(32) port map(real_pc, cpuclk, pc);

  ir_in <= x"00000013" when use_nop='1'
      else rom(to_integer(unsigned(real_pc(10 downto 2))));
  ir_12: d_reg generic map(32) port map(ir_in, cpuclk, ir);

  process (cpuclk)
  begin
    if falling_edge(cpuclk) then
      use_nop <= '1';
      case count is
        when "000" => count <= "001";
        when "001" => count <= "010";
        when "010" => count <= "011";
        when "011" => count <= "100";
        when "100" => count <= "101";
        when "101" => count <= "110"; use_nop <= '0';
        when "110" => count <= "111";
        when "111" => count <= "000";
        when others =>
      end case;
    end if;
  end process;
end architecture;
