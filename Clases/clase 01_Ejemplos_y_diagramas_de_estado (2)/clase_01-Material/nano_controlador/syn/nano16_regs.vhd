library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity nano16_regs is
    Port ( clk    : in  STD_LOGIC;
           xdin   : in  STD_LOGIC_VECTOR (15 downto 0);
           xaddr  : in  STD_LOGIC_VECTOR (3 downto 0);
           yaddr  : in  STD_LOGIC_VECTOR (3 downto 0);
           ydout  : out STD_LOGIC_VECTOR (15 downto 0);
           zaddr  : in  STD_LOGIC_VECTOR (3 downto 0);
           zdout  : out STD_LOGIC_VECTOR (15 downto 0);
           wr     : in  STD_LOGIC);
end nano16_regs;

architecture Behavioral of nano16_regs is
   type t_ram is array (natural range <>) of std_logic_vector(15 downto 0);
   signal ram : t_ram(0 to 15) := (others => (others => '0'));
   signal x_i  :  natural  range 0 to 15;
   signal y_i  :  natural  range 0 to 15;
   signal z_i  :  natural  range 0 to 15;
begin
   x_i <= to_integer(unsigned(xaddr));
   y_i <= to_integer(unsigned(yaddr));
   z_i <= to_integer(unsigned(zaddr));
   
   process(clk)
   begin
      if(rising_edge(clk)) then
         if(wr = '1' and x_i /= 0) then         
            ram(x_i) <= xdin;
         end if;
         ydout <= ram(y_i);
         zdout <= ram(z_i);
      end if;
   end process;
end Behavioral;
