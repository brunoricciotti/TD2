LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY ncisc_tb IS
END ncisc_tb;
 
ARCHITECTURE behavior OF ncisc_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT nano_cisc_top
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         din : IN  std_logic_vector(7 downto 0);
         dout : OUT  std_logic_vector(7 downto 0);
         address : OUT  std_logic_vector(15 downto 0);
         wr : OUT  std_logic
        );
    END COMPONENT;
    
   --Types
   type tram is array (natural range <>) of std_logic_vector(7 downto 0);
   
   --Inputs
   signal clk     : std_logic := '0';
   signal rst     : std_logic := '0';
   signal din     : std_logic_vector(7 downto 0) := (others => '0');
   signal din_rom : std_logic_vector(7 downto 0) := (others => '0');
   signal din_ram : std_logic_vector(7 downto 0) := (others => '0');
   
 	--Outputs
   signal dout : std_logic_vector(7 downto 0);
   signal address : std_logic_vector(15 downto 0);
   signal wr : std_logic;

   --memoria.
   signal ram  :  tram(255 downto 0) := (others => (others => '0'));

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
   din <= din_ram when address(15 downto 8) = x"01" else din_rom;
   
   process(clk)
      variable ix : natural range 0 to 255;
   begin
      if(rising_edge(clk)) then
         ix := to_integer(unsigned(address(7 downto 0)));
         if(wr = '1') then
            ram(ix) <= dout;
         end if;
         din_ram <= ram(ix);
      end if;
   end process;
 
   process(clk)
   begin
      if(rising_edge(clk)) then
         case address is
            when x"0000"   => din_rom <= x"01"; --INC A
            
            when x"0001"   => din_rom <= x"02"; --DEC A
            
            when x"0002"   => din_rom <= x"03"; --JMP 0xAA55
            when x"0003"   => din_rom <= x"55";
            when x"0004"   => din_rom <= x"AA";
            
            when x"aa55"   => din_rom <= x"04"; --SP = 0xF0
            when x"aa56"   => din_rom <= x"F0";
            
            when x"aa57"   => din_rom <= x"05"; --CALL 0x1234
            when x"aa58"   => din_rom <= x"34";
            when x"aa59"   => din_rom <= x"12";
            
            when x"aa5a"   => din_rom <= x"07"; -- X = 0x10
            when x"aa5b"   => din_rom <= x"10";
            
            when x"aa5c"   => din_rom <= x"08"; -- MOV A,[inm16 + X]
            when x"aa5d"   => din_rom <= x"46";
            when x"aa5e"   => din_rom <= x"aa";
            
            when x"aa5f"   => din_rom <= x"0A"; -- CLR A
          --when x"aa5f"   => din_rom <= x"00"; -- NOP  
            when x"aa60"   => din_rom <= x"09"; -- JNZ $-2 
            when x"aa61"   => din_rom <= x"FE"; 
          --when x"aa60"   => din_rom <= x"09"; -- JNZ $+40 
          --when x"aa61"   => din_rom <= x"40"; 
            
            
            
            when x"1235"   => din_rom <= x"06"; --RET
            when others    => din_rom <= x"00"; 
         end case;
      end if;
   end process;
 
   
 
   -- Instantiate the Unit Under Test (UUT)
   uut: nano_cisc_top PORT MAP (
          clk => clk,
          rst => rst,
          din => din,
          dout => dout,
          address => address,
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
 

   -- Stimulus process
   stim_proc: process
   begin		
      rst <= '1';
      wait for clk_period*2;
      rst <= '0';

      -- insert stimulus here 

      wait;
   end process;

END;
