library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity up1 is
    Port ( clk : in  	STD_LOGIC;
			  rst	: in		STD_LOGIC;
           pdb : in  	STD_LOGIC_VECTOR (11 downto 0);
           pab : out  	STD_LOGIC_VECTOR (7  downto 0);
           ddib: in  	STD_LOGIC_VECTOR (7  downto 0);
           ddob: out  	STD_LOGIC_VECTOR (7  downto 0);
			  dab	: out		STD_LOGIC_VECTOR (7  downto 0);
			  wr	: out		STD_LOGIC);
end up1;

architecture Behavioral of up1 is
		signal ain, aout				:	std_logic_vector(7 downto 0);
		signal loada, loadpc, incpc:	std_logic;
		signal mux_alu_in,z 			:	std_logic;
		signal alu_op1					:	std_logic_vector(7 downto 0);
		signal rom_cmd					:	std_logic_vector(5 downto 0);
begin
	ddob 		<= aout;
	dab		<= pdb(7 downto 0);
	alu_op1	<= pdb(7 downto 0) when mux_alu_in = '0' else ddib;
	
	incpc			<= rom_cmd(0);
	loadpc		<= (rom_cmd(2) and z) or (rom_cmd(1));		
	loada			<= rom_cmd(3);
	mux_alu_in	<= rom_cmd(4);
	wr				<= rom_cmd(5);
	
	with pdb(11 downto 8) select
		rom_cmd	<=		"001001"			when "0000",	--A <= K
							"001001"			when "0001",   --A <= A AND K
							"001001"			when "0010",	--A <= A OR K
							"001001"			when "0011",	--A <= A XOR K
							"001001"			when "0100", 	--A <= NOT A
							"001001"			when "0101",   --INC A
							"001001"			when "0111",   --A <= A + K
							"011001"			when "1000",	--A <= ddib[K]
							"001001"			when "0110",   --DEC A
							"100001"			when "1001",   --ddob[K] <= A
							"000010"			when "1010",	--JUMP K
							"000101"			when "1011",	--JZ K
							"000001"			when "1100",	--NOP
							"000001"			when "1101",	--NOP
							"000001"			when "1110",	--NOP
							"000000"			when "1111",	--HALT
						(others => '0')	when others;
	
	regA: 	entity work.cnt(Behavioral)
				generic map(LEN	=> 8,
								DES	=> false)
				port map( 	clk	=> clk,
								rst 	=> rst,
								load	=> loada,
								en		=> '0',
								din	=> ain,
								dout	=> aout);

	regPC: 	entity work.cnt(Behavioral)
				generic map(LEN	=> 8,
								DES	=> false)
				port map( 	clk	=> clk,
								rst 	=> rst,
								load	=> loadpc,
								en		=> incpc,
								din	=> pdb(7 downto 0),
								dout	=> pab);

	malu:		entity work.uALU(Behavioral)
				generic map(LEN	=> 8)
				port map( 	cmd	=> pdb(10 downto 8),
								op1	=> alu_op1,
								op2	=> aout,
								res	=> ain,
								z 	 	=> z);
end Behavioral;
