LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY sec_tb IS
END sec_tb;
 
ARCHITECTURE behavior OF sec_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT secuenciador
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         prog_data : IN  std_logic_vector(5 downto 0);
         prog_addr : OUT  std_logic_vector(7 downto 0);
         data_in : IN  std_logic_vector(7 downto 0);
         data_out : OUT  std_logic_vector(7 downto 0);
         wr : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal prog_data : std_logic_vector(5 downto 0) := (others => '0');
   signal data_in : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal prog_addr : std_logic_vector(7 downto 0);
   signal data_out : std_logic_vector(7 downto 0);
   signal wr : std_logic;

   signal memout  : std_logic_vector(13 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;


 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: secuenciador PORT MAP (
          clk => clk,
          rst => rst,
          prog_data => prog_data,
          prog_addr => prog_addr,
          data_in => data_in,
          data_out => data_out,
          wr => wr
        );

   data_in     <= memout( 7 downto 0);
   prog_data   <= memout(13 downto 8);
   
   process(clk)
   begin
      if(rising_edge(clk)) then
         case prog_addr is
            when x"00"   => memout <= "001111" & x"00"; -- ACC = 0
            when x"01"   => memout <= "001000" & x"23"; -- ACC = 23 (35)
            when x"02"   => memout <= "001101" & x"00"; -- ACC = NOT ACC
            when x"03"   => memout <= "001001" & x"01"; -- ACC = ACC + 1
            when x"04"   => memout <= "010000" & x"00"; -- WR = 1;
            when x"05"   => memout <= "000000" & x"00"; -- WR = 0;
            when x"06"   => memout <= "100000" & x"02"; 

--            when x"00"   => memout <= "001000" & x"55";
--            when x"01"   => memout <= "001110" & x"00";
--            when x"02"   => memout <= "010000" & x"00"; -- WR = 1;
--            when x"03"   => memout <= "000000" & x"00"; -- WR = 0;
--            when x"04"   => memout <= "100000" & x"01"; 
            
            when others  => memout <= (others => '0'); 
         end case;
      end if;
   end process;

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
      wait;
   end process;

END;
