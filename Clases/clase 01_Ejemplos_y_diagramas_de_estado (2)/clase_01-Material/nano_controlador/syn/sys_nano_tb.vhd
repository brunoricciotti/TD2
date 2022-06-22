LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY sys_nano_tb IS
END sys_nano_tb;
 
ARCHITECTURE behavior OF sys_nano_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT sys_nano16
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         leds : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';

 	--Outputs
   signal leds : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: sys_nano16 PORT MAP (
          clk => clk,
          rst => rst,
          leds => leds
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
