library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity nano16_fsm is
    Port ( clk       : in  STD_LOGIC;
           rst       : in  STD_LOGIC;
           opcode    : in  STD_LOGIC_VECTOR (3 downto 0);
           alu_z     : in  STD_LOGIC;
           sel_xad   : out STD_LOGIC;
           sel_yad   : out STD_LOGIC;
           sel_addr  : out STD_LOGIC_VECTOR(1 downto 0);
           sel_xin   : out STD_LOGIC;
           sel_aop1  : out STD_LOGIC;
           sel_rel   : out STD_LOGIC;
           en_ir     : out STD_LOGIC;
           en_jmp    : out STD_LOGIC;
           inc_pc    : out STD_LOGIC;
           wr_reg    : out STD_LOGIC;
           wr        : out STD_LOGIC);
end nano16_fsm;

architecture Behavioral of nano16_fsm is
   type nano16_estado is (S0, S1, S2, S3, S4);
   signal actual, futuro : nano16_estado;
   signal wr_i    :  std_logic;
   signal yad     :  std_logic;
   signal addr    :  std_logic_vector(1 downto 0);
   signal jmp     :  std_logic;
   signal xin     :  std_logic;
   signal aop1    :  std_logic;
   signal rel     :  std_logic;
   signal lrel    :  std_logic;
   signal deco_op :  std_logic_vector(7 downto 0);
begin 

   with opcode select
    deco_op <= "00010100" when "0000",
               "11000000" when "0001",
               "01001000" when "0010",
               "01010000" when "0011",
               "00000010" when "0100",
               "00100001" when "0101",
               "00000000" when others;
   
   jmp      <= alu_z and deco_op(0);
   rel      <= alu_z and deco_op(1);
   wr_i     <= deco_op(2);
   yad      <= deco_op(3);
   addr(0)  <= deco_op(4);
   xin      <= deco_op(5);
   aop1     <= deco_op(6);
   addr(1)  <= deco_op(7);
   lrel     <= deco_op(7);
   
   process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            actual <= S4;
         else
            actual <= futuro;
         end if;
      end if;
   end process;

   process(actual)
   begin
      case actual is
         when S0 =>  --FETCH
                     futuro <= S1;
         when S1 =>
                     --EXECUTE
                     futuro <= S2;
         when S2 =>
                     --WRITE.
                     futuro <= S3;
         when S3 =>
                     --PC UPDATE
                     futuro <= S4;
         when S4 =>
                     --WAIT.
                     futuro <= S0;
      end case;
   end process;

   process(actual,yad,addr,xin, wr_i, jmp, aop1, rel, lrel)
   begin
      case actual is
         when S0 =>
                     sel_xad   <= '0';
                     sel_yad   <= '0';
                     sel_addr  <= "00";
                     sel_xin   <= '0';
                     sel_aop1  <= '0';
                     sel_rel   <= '0';
                     en_ir     <= '1';
                     en_jmp    <= '0';
                     inc_pc    <= '0';
                     wr_reg    <= '0';
                     wr        <= '0';
         when S1 =>
                     sel_xad   <= lrel;
                     sel_yad   <= yad;
                     sel_addr  <= addr; 
                     sel_xin   <= xin;
                     sel_aop1  <= aop1;
                     sel_rel   <= rel;
                     en_ir     <= '0';
                     en_jmp    <= '0';
                     inc_pc    <= '0';
                     wr_reg    <= '0';
                     wr        <= '0';         
         when S2 =>
                     sel_xad   <= lrel;
                     sel_yad   <= yad;
                     sel_addr  <= addr;
                     sel_xin   <= xin;
                     sel_aop1  <= aop1;
                     sel_rel   <= rel;
                     en_ir     <= '0';
                     en_jmp    <= jmp or rel;
                     inc_pc    <= '0';
                     wr_reg    <= jmp;
                     wr        <= '0';
         when S3 =>
                     sel_xad   <= lrel;
                     sel_yad   <= yad;
                     sel_addr  <= addr;
                     sel_xin   <= xin;
                     sel_aop1  <= aop1;
                     sel_rel   <= rel;
                     en_ir     <= '0';
                     en_jmp    <= '0';
                     inc_pc    <= not (jmp or rel);
                     wr_reg    <= (wr_i nor jmp) and (not rel);
                     wr        <= wr_i;
         when S4 =>
                     sel_xad   <= '0';
                     sel_yad   <= '0';
                     sel_addr  <= "00";
                     sel_xin   <= '0';
                     sel_aop1  <= '0';
                     sel_rel   <= '0';
                     en_ir     <= '0';
                     en_jmp    <= '0';
                     inc_pc    <= '0';
                     wr_reg    <= '0';
                     wr        <= '0';
      end case;
   end process;
end Behavioral;
