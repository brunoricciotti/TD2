library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity nano16_alu is
    Port ( cmd : in  STD_LOGIC_VECTOR (3 downto 0);
           op1 : in  STD_LOGIC_VECTOR (15 downto 0);
           op2 : in  STD_LOGIC_VECTOR (15 downto 0);
           ret : out STD_LOGIC_VECTOR (15 downto 0);
           z   : out STD_LOGIC);
end nano16_alu;

architecture Behavioral of nano16_alu is
      signal neq     :  std_logic_vector(15 downto 0);
      signal ge      :  std_logic_vector(15 downto 0);
begin

   neq   <= (others => '1') when op1 /= op2 else (others => '0');
   ge    <= (others => '1') when unsigned(op1) >= unsigned(op2) else (others => '0');
   z     <= '1' when unsigned(op2) = to_unsigned(0,16) else '0';
   
   with cmd select
      ret <=   op1                                             when "0000",   --STR
               op1                                             when "0001",   --LREL
               op2(15 downto 8) & op1(7 downto 0)              when "0010",   --LDC
               op1                                             when "0011",   --LDR
               op1                                             when "0100",   --JREL
               op1                                             when "0101",   --JMP.
               op1 and op2                                     when "0110",   --AND
               op1 or  op2                                     when "0111",   --OR
               op1 xor op2                                     when "1000",   --XOR
               std_logic_vector(unsigned(op1)+ unsigned(op2))  when "1001",   --ADD
               op1(14 downto 0)&op2(15 downto 15)              when "1010",   --ROL
               not op1                                         when "1011",   --NOT
               std_logic_vector(unsigned(op1) + 1)             when "1100",   --INC
               std_logic_vector(unsigned(op1) - 1)             when "1101",   --DEC
               neq                                             when "1110",   --NEQ
               ge                                              when "1111",   --GE
               (others => '0')                                 when others;                                             
end Behavioral;
