library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cunos_dp is
    Generic(N     : natural := 16);
    Port ( clk    : in  STD_LOGIC;
           load   : in  STD_LOGIC;
           e_s    : in  STD_LOGIC;
           data   : in  STD_LOGIC_VECTOR (N-1 downto 0);
           z      : out STD_LOGIC;
           unos   : out STD_LOGIC_VECTOR (7 downto 0));
end cunos_dp;

architecture Behavioral of cunos_dp is
   signal en_cnt  :  std_logic;
   signal rdes    :  std_logic_vector(N-1 downto 0);
begin

   en_cnt   <= rdes(0) and e_s;
   z        <= '1' when unsigned(rdes) = to_unsigned(0,N) else '0'; 

   cnt:  entity work.contador(Behavioral)
         generic map(N     => unos'length)
         port map(   clk   => clk,
                     rst   => load,
                     en    => en_cnt,
                     dout  => unos);

   rdd:  entity work.rdes_derecha(Behavioral)
         generic map(N     => N)
         port map(   clk   => clk,
                     load  => load,
                     en    => e_s,
                     sin   => '0',
                     din   => data,
                     dout  => rdes);
end Behavioral;
