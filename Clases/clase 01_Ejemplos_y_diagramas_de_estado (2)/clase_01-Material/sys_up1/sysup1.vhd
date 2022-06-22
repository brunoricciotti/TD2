library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity sysup1 is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           pines_in : in  STD_LOGIC_VECTOR (7 downto 0);
           pines_out : out  STD_LOGIC_VECTOR (7 downto 0));
end sysup1;

architecture Behavioral of sysup1 is
	constant	ADDR_OP	:	std_logic_vector(7 downto 0) := x"30";
	constant	ADDR_IP	:	std_logic_vector(7 downto 0) := x"20";
	constant ADDR_TIM	:	std_logic_vector(7 downto 0) := x"10";
	constant ADDR_MEM :	std_logic_vector(7 downto 0) := x"00";
	
   signal pdb 			: std_logic_vector(11 downto 0) := (others => '0');
   signal ddib 		: std_logic_vector(7 downto 0) := (others => '0');
   signal pab 			: std_logic_vector(7 downto 0);
   signal ddob 		: std_logic_vector(7 downto 0);
   signal dab 			: std_logic_vector(7 downto 0);
   signal wr 			: std_logic;
	signal cs_po 		: std_logic;
	signal cs_tim		: std_logic;
	signal cs_mem		: std_logic;
	signal dbi_pi		: std_logic_vector(7 downto 0);
	signal dbi_tim		: std_logic_vector(7 downto 0);
	signal dbi_mem		: std_logic_vector(7 downto 0);
begin

-- Instantiate the Unit Under Test (UUT)
   up:	entity work.up1(Behavioral) 
			port map (	clk 	=> clk,
							rst 	=> rst,
							pdb 	=> pdb,
							pab 	=> pab,
							ddib 	=> ddib,
							ddob 	=> ddob,
							dab 	=> dab,
							wr 	=> wr);
	
	po:	entity work.PuertaSalida(Behavioral)
			port map(	clk 		=> clk,
							rst 		=> '0',
							en 		=> cs_po,
							datos 	=> ddob,
							pines		=> pines_out);
							
	pi:	entity work.PuertoEntrada(Behavioral)
			port map( 	clk		=> clk,
							pines		=> pines_in,
							salida_datos => dbi_pi);

	ti:	entity work.Temporizador(Behavioral)
			generic map(FCLK		=> 100_000_000,
							FBASE		=> 1_000)
			port map( 	clk		=> clk,
							rst 		=> rst,
							wr 		=>	cs_tim,	
							data_in 	=>	ddob,
							data_out => dbi_tim);

	mem: 		entity work.cnt(Behavioral)
				generic map(LEN	=> 8,
								DES	=> false)
				port map( 	clk	=> clk,
								rst 	=> rst,
								load	=> cs_mem,
								en		=> '0',
								din	=> ddob,
								dout	=> dbi_mem);


	cs_po 	<= wr when dab = ADDR_OP 	else '0';
	cs_tim	<= wr when dab = ADDR_TIM  else '0';
	cs_mem	<= wr when dab = ADDR_MEM  else '0';
	
	with dab select
		ddib	<= dbi_pi				when ADDR_IP,
					dbi_tim				when ADDR_TIM,
					dbi_mem				when ADDR_MEM,
					(others => '0')	when others;

	with pab select
		pdb <=	"110000000000" when "00000000",	--NOP
					"110000000000" when "00000001",  --NOP
					"000010101010" when "00000010",	--A=0xAA
					"100100110000" when "00000011",  --[0x30]=A
					"100100000000" when "00000100",  --[0x00]=A
					"000000000011" when "00000101",	--A=0x03
					"100100010000" when "00000110",  --[0x10]=A
					"100000010000" when "00000111",  --A = [0x10]
					"101100000111" when "00001000",  --JZ $-1
					"100000100000" when "00001001",  --A=[0x20]
					"000100000001" when "00001010",  --A=A&1
					"101100000101"	when "00001011",  --JZ 0x05 
					"100000000000" when "00001100",  --A=[0x00]
					"001111111111" when "00001101",  --A= A xor 0xFF
					"100100110000" when "00001110",  --[0x30]=A
					"100100000000" when "00001111",  --[0x00]=A
					"101000000101" when "00010000",  --JUMP 0x5
					"111100000000" when others;		--HALT
end Behavioral;
