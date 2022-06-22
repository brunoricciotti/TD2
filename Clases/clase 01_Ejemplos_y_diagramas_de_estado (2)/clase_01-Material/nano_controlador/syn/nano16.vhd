library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity nano16 is
    Port ( clk    : in     STD_LOGIC;
           rst    : in     STD_LOGIC;
           din    : in     STD_LOGIC_VECTOR (15 downto 0);
           dout   : out    STD_LOGIC_VECTOR (15 downto 0);
           addr   : out    STD_LOGIC_VECTOR (15 downto 0);
           wr     : out    STD_LOGIC);
end nano16;

architecture Behavioral of nano16 is
   --Seales de muxes.
   signal xin     :  std_logic_vector(15 downto 0);
   signal zad     :  std_logic_vector(3 downto 0);
   signal yad     :  std_logic_vector(3 downto 0);
   signal xad     :  std_logic_vector(3 downto 0);
   
   --Seales de control de muxes.
   signal sel_yad :  std_logic;
   signal sel_xad :  std_logic;
   signal sel_xin :  std_logic;
   signal sel_aop1:  std_logic;
   signal sel_rel :  std_logic;
   signal sel_addr:  std_logic_vector(1 downto 0);
   
   --Otras seales de control.
   signal en_ir   :  std_logic;
   signal en_jmp  :  std_logic;
   signal inc_pc  :  std_logic;
   signal alu_z   :  std_logic;
   signal wr_reg  :  std_logic;

   --Seales que mueven datos.
   signal pcout   :  std_logic_vector(15 downto 0);
   signal pcin    :  std_logic_vector(15 downto 0);
   signal pcoutp1 :  std_logic_vector(15 downto 0);
   signal pcoffset:  std_logic_vector(15 downto 0);
   signal ir      :  std_logic_vector(15 downto 0);
   signal alu_op1 :  std_logic_vector(15 downto 0);
   signal alu_op2 :  std_logic_vector(15 downto 0);
   signal alu_ret :  std_logic_vector(15 downto 0);
   signal y_out   :  std_logic_vector(15 downto 0);
begin
   
   --Salida
   dout     <= alu_op2;
   
   --Muxes.
   with sel_addr select
      addr  <= pcout    when "00",
               y_out    when "01",
               pcoffset when others;
   
   zad      <= ir(3 downto 0)  when sel_yad   = '0'  else ir(11 downto 8);
   yad      <= ir(7 downto 4)  when sel_yad   = '0'  else ir(11 downto 8);
   xad      <= ir(11 downto 8) when sel_xad   = '0'  else ir(3 downto 0); 
   xin      <= alu_ret         when sel_xin   = '0'  else pcoutp1;
   alu_op1  <= y_out           when sel_aop1  = '0'  else din; 
   pcin     <= y_out           when sel_rel   = '0'  else pcoffset; 
               
   --Direcciones relativas a PC.
   pcoffset <= std_logic_vector(signed(pcout)+resize(signed(ir(11 downto 4)),16));
   pcoutp1  <= std_logic_vector(unsigned(pcout)+1);
   
   --FSM de control
   cmp_fsm:  entity work.nano16_fsm(Behavioral)
            port map(      clk      => clk,
                           rst      => rst,
                           opcode   => ir(15 downto 12),
                           alu_z    => alu_z,
                           sel_xad  => sel_xad,
                           sel_yad  => sel_yad,
                           sel_addr => sel_addr,
                           sel_xin  => sel_xin,
                           sel_aop1 => sel_aop1,
                           sel_rel  => sel_rel,
                           en_ir    => en_ir,
                           en_jmp   => en_jmp,
                           inc_pc   => inc_pc,
                           wr_reg   => wr_reg,
                           wr       => wr);
   
   --Camino de datos. Registros, contadores y ALU.
   cmp_ir:     entity work.nano16_cnt(Behavioral)
               port map(   clk      => clk,
                           rst      => rst,
                           din      => din,
                           load     => en_ir,
                           en       => '0',
                           dout     => ir);

   cmp_pc:     entity work.nano16_cnt(Behavioral)
               port map(   clk      => clk,
                           rst      => rst,
                           din      => pcin,
                           load     => en_jmp,
                           en       => inc_pc,
                           dout     => pcout);
                           
   cmp_regs:   entity work.nano16_regs(Behavioral)
               port map(   clk      => clk,
                           xdin     => xin,
                           xaddr    => xad,
                           yaddr    => yad,
                           ydout    => y_out,
                           zaddr    => zad,
                           zdout    => alu_op2,
                           wr       => wr_reg);
                           
   cmp_alu:    entity work.nano16_alu(Behavioral)
               port map(   cmd      => ir(15 downto 12),
                           op1      => alu_op1,
                           op2      => alu_op2,
                           ret      => alu_ret,
                           z        => alu_z);
end Behavioral;
