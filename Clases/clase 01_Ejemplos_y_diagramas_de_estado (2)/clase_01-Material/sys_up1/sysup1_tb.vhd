LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY sysup1_tb IS
END sysup1_tb;
 
ARCHITECTURE behavior OF sysup1_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT sysup1
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         pines_in : IN  std_logic_vector(7 downto 0);
         pines_out : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal pines_in : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal pines_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: sysup1 PORT MAP (
          clk => clk,
          rst => rst,
          pines_in => pines_in,
          pines_out => pines_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
	pines_in <= not pines_in after 10ms;

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
