LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY suma_tb IS
END suma_tb;
 
ARCHITECTURE behavior OF suma_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT suma_registrada
    PORT(
         clk : IN  std_logic;
         A : IN  std_logic_vector(7 downto 0);
         B : IN  std_logic_vector(7 downto 0);
         C : IN  std_logic_vector(7 downto 0);
         D : IN  std_logic_vector(7 downto 0);
         S : OUT  std_logic_vector(9 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal A : std_logic_vector(7 downto 0) := (others => '0');
   signal B : std_logic_vector(7 downto 0) := (others => '0');
   signal C : std_logic_vector(7 downto 0) := (others => '0');
   signal D : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal S : std_logic_vector(9 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: suma_registrada PORT MAP (
          clk => clk,
          A => A,
          B => B,
          C => C,
          D => D,
          S => S
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      A <= std_logic_vector(to_unsigned(1,8));
      B <= std_logic_vector(to_unsigned(2,8));
      C <= std_logic_vector(to_unsigned(3,8));
      D <= std_logic_vector(to_unsigned(4,8));
      wait for clk_period;
      
      A <= std_logic_vector(to_unsigned(5,8));
      B <= std_logic_vector(to_unsigned(6,8));
      C <= std_logic_vector(to_unsigned(7,8));
      D <= std_logic_vector(to_unsigned(8,8));
      wait for clk_period;
      
      A <= std_logic_vector(to_unsigned(9,8));
      B <= std_logic_vector(to_unsigned(10,8));
      C <= std_logic_vector(to_unsigned(11,8));
      D <= std_logic_vector(to_unsigned(12,8));
      wait for clk_period;
      

      -- insert stimulus here 

      wait;
   end process;

END;
