library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity nano16_cnt is
    Port ( clk    : in  STD_LOGIC;
           rst    : in  STD_LOGIC;
           din    : in  STD_LOGIC_VECTOR (15 downto 0);
           load   : in  STD_LOGIC;
           en     : in  STD_LOGIC;
           dout   : out  STD_LOGIC_VECTOR (15 downto 0));
end nano16_cnt;

architecture Behavioral of nano16_cnt is
   signal cnt     :  unsigned(dout'range);
begin
   process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            cnt <= (others => '0');
         elsif(load = '1') then
            cnt <= unsigned(din);
         elsif(en = '1') then
            cnt <= cnt + 1;
         end if;
      end if;
   end process;
   dout <= std_logic_vector(cnt);
end Behavioral;

