library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity secuenciador is
    Port ( clk          : in  STD_LOGIC;
           rst          : in  STD_LOGIC;
           prog_data    : in  STD_LOGIC_VECTOR (5 downto 0);
           prog_addr    : out STD_LOGIC_VECTOR (7 downto 0);
           data_in      : in  STD_LOGIC_VECTOR (7 downto 0);
           data_out     : out STD_LOGIC_VECTOR (7 downto 0);
           wr           : out STD_LOGIC);
end secuenciador;

architecture Behavioral of secuenciador is
   signal acc     :  std_logic_vector(7 downto 0);
   signal pc      :  std_logic_vector(7 downto 0);
   signal alu_out :  std_logic_vector(7 downto 0);
   signal alu_op1 :  std_logic_vector(7 downto 0);
   signal alu_op2 :  std_logic_vector(7 downto 0);
begin

   data_out    <= acc;
   prog_addr   <= pc;
   alu_op1     <= data_in;
   alu_op2     <= acc;
   data_out    <= acc;
   wr          <= prog_data(4);
   
   --Registro "Acumulador"
   process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            acc <= (others => '0');
         elsif(prog_data(3) = '1') then
            acc <= alu_out;
         end if;
      end if;
   end process;
   

   --Registro "Contador de Programa"
   process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            pc <= (others => '0');
         elsif(prog_data(5) = '1') then
            pc <= data_in;
         else
            pc <= std_logic_vector(unsigned(pc)+1);
         end if;
      end if;
   end process;
   
   
   --Unidad Aritmético - lógica.
   with prog_data(2 downto 0) select
      alu_out <= alu_op1                                                when "000",
                 std_logic_vector(unsigned(alu_op1)+ unsigned(alu_op2)) when "001",
                 alu_op1 and alu_op2                                    when "010",
                 alu_op1 or  alu_op2                                    when "011",
                 alu_op1 xor alu_op2                                    when "100",
                 not alu_op2                                            when "101",
                 alu_op2(6 downto 0)&alu_op2(7)                         when "110",
                 (others => '0')                                        when others;

end Behavioral;

