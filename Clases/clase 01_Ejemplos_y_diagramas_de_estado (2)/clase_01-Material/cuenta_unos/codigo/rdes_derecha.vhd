library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rdes_derecha is
    Generic(N     : natural := 8);
    Port ( clk    : in  STD_LOGIC;
           load   : in  STD_LOGIC;
           en     : in  STD_LOGIC;
           sin    : in  STD_LOGIC;
           din    : in  STD_LOGIC_VECTOR (N-1 downto 0);
           dout   : out STD_LOGIC_VECTOR (N-1 downto 0));
end rdes_derecha;

architecture Behavioral of rdes_derecha is
   signal r       :  std_logic_vector(N-1 downto 0);   
begin
   process(clk)
   begin
      if(rising_edge(clk)) then
         if(load = '1') then
            r <= din;
         elsif(en = '1') then
            r(N-2 downto 0) <= r(N-1 downto 1);
            r(N-1) <= sin;
         end if;
      end if;
   end process;
   dout <= r;
end Behavioral;   
