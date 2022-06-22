library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cuenta_unos is
    Port ( clk    : in  STD_LOGIC;
           rst    : in  STD_LOGIC;
           start  : in  STD_LOGIC;
           datos  : in  STD_LOGIC_VECTOR (9 downto 0);
           unos   : out STD_LOGIC_VECTOR (7 downto 0);
           rdy    : out STD_LOGIC);
end cuenta_unos;

architecture Behavioral of cuenta_unos is
   signal load, e_s, z  :  std_logic;
begin

   dpa:  entity work.cunos_dp(Behavioral)
         generic map(N     => 10)
         port map(   clk   => clk,
                     load  => load,
                     e_s   => e_s,
                     data  => datos,
                     z     => z,
                     unos  => unos);

   fsm:  entity work.cunos_fsm(Behavioral)
         port map(   clk   => clk,
                     rst   => rst,
                     start => start,
                     z     => z,
                     load  => load,
                     e_s   => e_s,
                     rdy   => rdy);


end Behavioral;

