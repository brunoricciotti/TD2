library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PuertoEntrada is
    Port ( clk 			: in  	STD_LOGIC;
			  pines 			: in  	STD_LOGIC_VECTOR (7 downto 0);
           salida_datos : out  	STD_LOGIC_VECTOR (7 downto 0));
end PuertoEntrada;

architecture Behavioral of PuertoEntrada is
	signal q1,q2			: std_logic_vector(7 downto 0);
begin
	process(clk)
	begin
		if(rising_edge(clk)) then
				q1 				<= pines;
				q2					<= q1;
		end if;
	end process;
	salida_datos 	<= q2;
end Behavioral;
