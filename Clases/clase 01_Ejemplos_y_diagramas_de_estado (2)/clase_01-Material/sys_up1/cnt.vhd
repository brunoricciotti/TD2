library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity cnt is
	 Generic(LEN	: natural := 8;
				DES	: boolean := false);
    Port ( clk 	: in  STD_LOGIC;
			  rst		: in 	STD_LOGIC;
           load 	: in  STD_LOGIC;
           en 		: in  STD_LOGIC;
           din 	: in  STD_LOGIC_VECTOR (LEN-1 downto 0);
           dout 	: out STD_LOGIC_VECTOR (LEN-1 downto 0));
end cnt;

architecture Behavioral of cnt is
	signal cnt 		: unsigned(LEN-1 downto 0);
	signal op		: unsigned(LEN-1 downto 0);
begin
	gdown:	
	if DES generate
		op <= cnt-1;
	end generate;
	
	gup:
	if not DES generate
		op <= cnt + 1;
	end generate;
	
	process(clk)
	begin
		if(rising_edge(clk)) then
			if(rst = '1') then
				cnt <= (others => '0');
			elsif(load = '1') then
				cnt <= unsigned(din);
			elsif(en = '1') then
				cnt <= op;
			end if;
		end if;
	end process;
	dout <= std_logic_vector(cnt);
end Behavioral;
