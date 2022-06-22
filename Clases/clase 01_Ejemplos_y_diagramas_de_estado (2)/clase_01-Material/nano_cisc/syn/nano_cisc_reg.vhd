library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity nano_cisc_reg is
    Generic(N     : natural := 8);
    Port ( clk    : in  STD_LOGIC;
           rst    : in  STD_LOGIC;
           load   : in  STD_LOGIC;
           din    : in  STD_LOGIC_VECTOR (N-1 downto 0);
           dout   : out STD_LOGIC_VECTOR (N-1 downto 0));
end nano_cisc_reg;

architecture Behavioral of nano_cisc_reg is
begin
   process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            dout <= (others => '0');
         elsif(load = '1') then
            dout <= din;
         end if;
      end if;
   end process;
end Behavioral;
