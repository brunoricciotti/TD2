library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity suma_registrada is
    Port ( clk : in  STD_LOGIC;
           A   : in  STD_LOGIC_VECTOR (7 downto 0);
           B   : in  STD_LOGIC_VECTOR (7 downto 0);
           C   : in  STD_LOGIC_VECTOR (7 downto 0);
           D   : in  STD_LOGIC_VECTOR (7 downto 0);
           S   : out STD_LOGIC_VECTOR (9 downto 0));
end suma_registrada;

architecture Behavioral of suma_registrada is
   signal ab, cd  :  unsigned(8 downto 0);
   signal abcd    :  unsigned(9 downto 0);
   
begin
   process(clk)
   begin
      if(rising_edge(clk)) then
         ab    <= unsigned("0"&A)  + unsigned("0"&B);
         cd    <= unsigned("0"&C)  + unsigned("0"&D);
         abcd  <= unsigned("0"&ab) + unsigned("0"&cd);
      end if;
   end process;
   S <= std_logic_vector(abcd);
end Behavioral;

