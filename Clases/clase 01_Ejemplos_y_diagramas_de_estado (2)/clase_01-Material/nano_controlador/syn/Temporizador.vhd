library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Temporizador is
	 Generic(FCLK		: natural := 100_000_000;
				FBASE		: natural := 25_000_000);
    Port ( clk 		: in  STD_LOGIC;
           rst 		: in  STD_LOGIC;
           wr 			: in  STD_LOGIC;
           data_in 	: in  STD_LOGIC_VECTOR (7 downto 0);
           data_out 	: out STD_LOGIC_VECTOR (7 downto 0));
end Temporizador;

architecture Behavioral of Temporizador is
	signal z			:	std_logic;
	signal en		:	std_logic;
	signal cnt		:	unsigned(7 downto 0);
begin

	tick:	entity work.engen(Behavioral)
			generic map(FCLK	=> FCLK,
							FGEN	=> FBASE)
			port map( 	clk	=> clk,
							rst 	=> rst,
							q		=> en);

	data_out	<= "0000000"&z;
	z 		 	<= '1' when cnt = to_unsigned(0,8) else '0'; 
	
	process(clk)
	begin
			if(rising_edge(clk)) then
				if(rst = '1') then
					cnt <= (others => '0');
				elsif(wr = '1') then
					cnt <= unsigned(data_in);
				elsif(z = '0' and en = '1') then
					cnt <= cnt - 1;
				end if;
			end if;
	end process;
end Behavioral;
