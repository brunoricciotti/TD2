library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity contador is
    Generic(N  : natural := 8);
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           en  : in  STD_LOGIC;
           dout: out STD_LOGIC_VECTOR (N-1 downto 0));
end contador;

architecture Behavioral of contador is
   signal cnt  :  unsigned(N-1 downto 0);
begin   
   process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            cnt <= (others => '0');
         elsif(en = '1') then
            cnt <= cnt + 1;
         end if;
      end if;
   end process;
   dout <= std_logic_vector(cnt);
end Behavioral;
