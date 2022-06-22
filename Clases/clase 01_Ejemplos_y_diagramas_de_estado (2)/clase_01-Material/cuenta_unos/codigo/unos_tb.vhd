LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY unos_tb IS
END unos_tb;
 
ARCHITECTURE behavior OF unos_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cuenta_unos
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         start : IN  std_logic;
         datos : IN  std_logic_vector(9 downto 0);
         unos : OUT  std_logic_vector(7 downto 0);
         rdy : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal start : std_logic := '0';
   signal datos : std_logic_vector(9 downto 0) := (others => '0');

 	--Outputs
   signal unos : std_logic_vector(7 downto 0);
   signal rdy : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cuenta_unos PORT MAP (
          clk => clk,
          rst => rst,
          start => start,
          datos => datos,
          unos => unos,
          rdy => rdy
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
      datos <= "1010101010";
      rst   <= '1';
      wait for clk_period*2;
      rst   <= '0';
      wait for clk_period*2;
      start <= '1';
      wait for clk_period;
      start <= '0';

      wait;
   end process;

END;
