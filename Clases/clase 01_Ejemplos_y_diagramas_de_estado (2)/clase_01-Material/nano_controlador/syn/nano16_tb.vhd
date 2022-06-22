LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY nano16_tb IS
END nano16_tb;
 
ARCHITECTURE behavior OF nano16_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT nano16
    PORT(
         clk   : IN  std_logic;
         rst   : IN  std_logic;
         din   : IN  std_logic_vector(15 downto 0);
         dout  : OUT  std_logic_vector(15 downto 0);
         addr  : OUT  std_logic_vector(15 downto 0);
         wr    : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal din : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal dout : std_logic_vector(15 downto 0);
   signal addr : std_logic_vector(15 downto 0);
   signal wr : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: nano16 PORT MAP (
          clk => clk,
          rst => rst,
          din => din,
          dout => dout,
          addr => addr,
          wr => wr
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;
 
   process(clk)
   begin
      if(rising_edge(clk)) then
         case addr is
            when x"0000"=> din <= "0010"&"0001"&x"55";         --LDL R1,0x55
            when x"0001"=> din <= "1101"&"0000"&"0001"&"0000"; --DEC R0,R1
            when x"0002"=> din <= "0010"&"0001"&x"AA";         --LDL 0xAA
            when x"0003"=> din <= "0000"&"0000"&"0000"&"0001"; --STR [R0],R1 (0x55AA)
            when x"0004"=> din <= "0101"&"0010"&"0001"&"0000"; --JMP R2,R1,R0 (CALL R1) RET <- R2+1 
            when x"55AA"=> din <= "0101"&"0000"&"0010"&"0000"; --JMP R0,R2,R0 (RET R2)
            when x"0005"=> din <= "0011"&"0011"&"0001"&"0000"; --LDR R3,R1
            when x"0006"=> din <= "0100"&"0010"&"0000"&"0000"; --JREL +0x20,R0
            when x"0007"=> din <= "0010"&"0101"&x"FF";         --LDL 0xFF;
            when x"0008"=> din <= "0110"&"0101"&"0101"&"0001"; --AND  R5,R5,R1
            when x"0009"=> din <= "0111"&"0110"&"0101"&"0001"; --OR R6,R5,R1
            when x"000A"=> din <= "1000"&"0111"&"0101"&"0001"; --XOR R7,R5,R1
            when x"000B"=> din <= "1001"&"1000"&"0110"&"0111"; --ADD R8, R7, R6
            when x"000C"=> din <= "1010"&"1001"&"1000"&"1000"; --ROL R9,R8,R8
            when x"000D"=> din <= "1100"&"1010"&"1001"&"0000"; --INC R10,R9
            when x"000E"=> din <= "1110"&"1100"&"1010"&"1010"; --NEQ R12,R10,R10
            when x"000F"=> din <= "1110"&"1101"&"1010"&"1001"; --NEQ R13,R10,R9
            when x"0010"=> din <= "1111"&"1110"&"1010"&"1001"; --GE  R14,R10,R9
            when x"0011"=> din <= "1111"&"1111"&"1001"&"1010"; --GE  R15,R9,R10
            when x"0012"=> din <= "0001"&"11111111"&"1111";    --LREL -1,R15 (R15 <= 0xFF9A)
            when x"0026"=> din <= "0100"&"1110"&"0001"&"0000"; --JREL -0x1F,R0 
            when others => din <= "0100"&"0000"&"0000"&"0000"; --JREL 0x00,R0
         end case;
      end if;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      rst <= '1';
      wait for clk_period*1;
      rst <= '0';

      -- insert stimulus here 

      wait;
   end process;

END;
