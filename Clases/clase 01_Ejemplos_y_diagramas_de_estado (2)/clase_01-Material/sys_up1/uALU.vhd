library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uALU is
	 Generic(LEN: natural := 8);
    Port ( 	cmd : in  STD_LOGIC_VECTOR (2 downto 0);
				op1 : in  STD_LOGIC_VECTOR (LEN-1 downto 0);
				op2 : in  STD_LOGIC_VECTOR (LEN-1 downto 0);
				res : out STD_LOGIC_VECTOR (LEN-1 downto 0);
				z 	 : out STD_LOGIC);
end uALU;

architecture Behavioral of uALU is
	signal suma	:	unsigned(LEN-1 downto 0);
begin
	z 		<= '1' when unsigned(op2) = to_unsigned(0,LEN) else '0';
	suma	<= unsigned(op1) + unsigned(op2);
	with cmd select
		res <= op1											when "000",
				 op1 and op2								when "001",
				 op1 or op2									when "010",
				 op1 xor op2								when "011",
				 not op2										when "100",
				 std_logic_vector(unsigned(op2)+1)	when "101",
				 std_logic_vector(unsigned(op2)-1)	when "110",
				 std_logic_vector(suma)					when "111",
				(others => '0')	when others;
end Behavioral;
