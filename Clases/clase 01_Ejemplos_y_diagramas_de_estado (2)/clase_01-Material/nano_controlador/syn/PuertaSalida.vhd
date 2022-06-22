library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PuertaSalida is
    Generic(N     : natural := 8);
    Port ( clk 	: in  STD_LOGIC;
           rst 	: in  STD_LOGIC;
           en 		: in  STD_LOGIC;
           datos 	: in  STD_LOGIC_VECTOR (N-1 downto 0);
           pines 	: out STD_LOGIC_VECTOR (N-1 downto 0));
end PuertaSalida;

architecture Behavioral of PuertaSalida is
begin
	process(clk,rst)
	begin
		if(rst = '1') then
			pines <= (others => '0');
		elsif(rising_edge(clk)) then
			if(en = '1') then
				pines <= datos;
			end if;
		end if;
	end process;
end Behavioral;
