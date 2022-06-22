LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY reg_tb IS
END reg_tb;
 
ARCHITECTURE behavior OF reg_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT nano16_regs
    PORT(
         clk : IN  std_logic;
         xdin : IN  std_logic_vector(15 downto 0);
         xaddr : IN  std_logic_vector(3 downto 0);
         yaddr : IN  std_logic_vector(3 downto 0);
         ydout : OUT  std_logic_vector(15 downto 0);
         zaddr : IN  std_logic_vector(3 downto 0);
         zdout : OUT  std_logic_vector(15 downto 0);
         wr : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal xdin : std_logic_vector(15 downto 0) := (others => '0');
   signal xaddr : std_logic_vector(3 downto 0) := (others => '0');
   signal yaddr : std_logic_vector(3 downto 0) := (others => '0');
   signal zaddr : std_logic_vector(3 downto 0) := (others => '0');
   signal wr : std_logic := '0';

 	--Outputs
   signal ydout : std_logic_vector(15 downto 0);
   signal zdout : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: nano16_regs PORT MAP (
          clk => clk,
          xdin => xdin,
          xaddr => xaddr,
          yaddr => yaddr,
          ydout => ydout,
          zaddr => zaddr,
          zdout => zdout,
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
      variable v :   std_logic_vector(3 downto 0);
   begin		
      
      for i in 0 to 15 loop
         v := std_logic_vector(to_unsigned(i,4));
         xdin  <= x"55A" & v;
         xaddr <= v;
         wait for clk_period;
         wr <= '1';
         wait for clk_period;
         wr <= '0';
         wait for clk_period;
         
      end loop;
      
      for i in 0 to 15 loop
         yaddr <= std_logic_vector(to_unsigned(i,4));
         zaddr <= std_logic_vector(to_unsigned(15-i,4));
         wait for clk_period;
      end loop;
      
      
      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
