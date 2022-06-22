library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity engen is
	 Generic(FCLK	: natural := 100_000_000;
				FGEN	: natural := 115_200);
    Port ( clk 	: in  	STD_LOGIC;
			  rst 	: in		STD_LOGIC;
           q 		: out  	STD_LOGIC);
end engen;

architecture Behavioral of engen is
	constant LEN	: natural := integer(ceil(log2(real(FCLK)/real(FGEN))));
	constant VAL	: natural := integer(round(real(FCLK)/real(FGEN)));
	signal cnt		: unsigned(LEN-1 downto 0);
	signal z			: std_logic;
begin
	process(clk)
	begin
		if(rising_edge(clk)) then
			if(rst = '1' or z = '1') then
				cnt <= to_unsigned(VAL-1,LEN);
			else
				cnt <= cnt - 1;
			end if;
		end if;
	end process;
	z	<= '1' when cnt = to_unsigned(0,LEN) else '0';
	q  <= z;
end Behavioral;

