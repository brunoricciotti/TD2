library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity nano_cisc_top is
    Port ( clk    : in  STD_LOGIC;
           rst    : in  STD_LOGIC;
           din    : in  STD_LOGIC_VECTOR ( 7 downto 0);
           dout   : out STD_LOGIC_VECTOR ( 7 downto 0);
           address: out STD_LOGIC_VECTOR (15 downto 0);
           wr     : out STD_LOGIC);
end nano_cisc_top;

architecture Behavioral of nano_cisc_top is
   --Voy a usar registros PC, SP, A, X, CC.
   --Visibles.
   constant DATA_LEN    : natural := 8;
   constant ADDR_LEN    : natural := 16;
   signal pcout         :  std_logic_vector(ADDR_LEN-1 downto 0);
   signal spout         :  std_logic_vector(DATA_LEN-1 downto 0);
   signal aout          :  std_logic_vector(DATA_LEN-1 downto 0);
   signal xout          :  std_logic_vector(DATA_LEN-1 downto 0);
   signal ccout         :  std_logic_vector(DATA_LEN-1 downto 0);
   signal pcen, spen    :  std_logic;
   signal aen, xen      :  std_logic;
   signal ccen          :  std_logic;
   
   --Voy a generar los registros R0, R1, ADOUT y DTOUT, 
   --invisibles para operar internamente.
   signal r0out         :  std_logic_vector(ADDR_LEN-1 downto 0);
   signal r1out         :  std_logic_vector(ADDR_LEN-1 downto 0);
   signal r2out         :  std_logic_vector(ADDR_LEN-1 downto 0);
   signal adout         :  std_logic_vector(ADDR_LEN-1 downto 0);
   signal dtout         :  std_logic_vector(DATA_LEN-1 downto 0);
   signal r0en,r1en,r2en:  std_logic;
   signal dten, aden    :  std_logic;
   
   --genero valores para la ALU.
   signal op0, op1      :  std_logic_vector(ADDR_LEN-1 downto 0);
   signal aluout        :  std_logic_vector(ADDR_LEN-1 downto 0);
   signal adder         :  std_logic_vector(ADDR_LEN-1 downto 0);
   signal carry         :  std_logic_vector(ADDR_LEN   downto 0);
   signal stat          :  std_logic_vector(3 downto 0);
   signal stat_reg      :  std_logic_vector(3 downto 0);
   
   --señales para microcodigo.
   signal sel_r0        :  std_logic_vector(3 downto 0);
   signal sel_r1        :  std_logic_vector(3 downto 0);
   signal sel_out       :  std_logic_vector(3 downto 0);
   signal sel_alu       :  std_logic_vector(2 downto 0);
   signal write_reg     :  std_logic;
   signal write_stat    :  std_logic;
   signal inmediato     :  std_logic_vector(15 downto 0);
   signal ucode_data    :  std_logic_vector(31 downto 0);
   
begin
   --Genero salidas.
   address  <= adout;
   dout     <= dtout;
   wr       <= write_reg when sel_alu = "111" else '0';
   
   --Instancio el generador de microcódigo.
   ucgen:   entity work.gen_ucode(Behavioral)
            port map(clk         => clk,
                     rst         => rst,
                     zero        => stat(3),
                     ucode_parm  => op0,
                     ucode_data  => ucode_data,
                     reg_stat    => write_stat);
   
   --Conecto generador de microcódigo.
   inmediato   <= ucode_data(15 downto 0);
   sel_r0      <= ucode_data(19 downto 16);
   sel_r1      <= ucode_data(23 downto 20);
   sel_out     <= ucode_data(27 downto 24);
   sel_alu     <= ucode_data(30 downto 28);
   write_reg   <= ucode_data(31);
   
   
   carry(0)<='0';
   add:  for i in 0 to ADDR_LEN-1 generate
         adder(i)    <= op0(i) xor op1(i) xor carry(i);
         carry(i+1)  <= (op0(i) and op1(i))   or
                        (op0(i) and carry(i)) or
                        (op1(i) and carry(i));
   end generate;
   
   stat(0) <= carry(8);                                                       --C
   stat(1) <= carry(8) xor carry(7);                                          --O
   stat(2) <= aluout(7);                                                      --S
   stat(3) <= '1' when unsigned(aluout) = to_unsigned(0,ADDR_LEN) else '0';   --Z
   
   --Alu.
   with sel_alu select
      aluout   <=    adder                when "000",
                     op0 or  op1          when "001",
                     op0 and op1          when "010",
                     op0 xor op1          when "011",
                     "0"&op0(15 downto 1) when "100",
                     op1                  when "101",
                     op0                  when "110",
                     (others => '0')      when others;
                  
   --Elijo que entra por R0.
   with sel_r0 select
      op0   <=    r0out                                  when "0000",
                  r1out                                  when "0001",
                  r2out                                  when "0010",
                  r2out(7 downto 0)&r2out(15 downto 8)   when "0011",
                  pcout                                  when "0100",
                  x"01"&spout                            when "0101",
                  x"00"&xout                             when "0110",
                  x"00"&ccout                            when "0111",
                  x"00"&aout                             when "1000",
                  din&din                                when "1001",
                  pcout(7 downto 0)&pcout(15 downto 8)   when "1010",
                  adout                                  when "1011",
                  x"00"&dtout                            when "1100",
                  x"000"&stat_reg                        when "1101",
                  inmediato                              when "1111",
                  x"0000"                                when others;
                  
   --Elijo que entra por R1.
   with sel_r1 select
      op1   <=    r0out                                  when "0000",
                  r1out                                  when "0001",
                  r2out                                  when "0010",
                  r2out(7 downto 0)&r2out(15 downto 8)   when "0011",
                  pcout                                  when "0100",
                  x"01"&spout                            when "0101",
                  x"00"&xout                             when "0110",
                  x"00"&ccout                            when "0111",
                  x"00"&aout                             when "1000",
                  din&din                                when "1001",
                  pcout(7 downto 0)&pcout(15 downto 8)   when "1010",
                  adout                                  when "1011",
                  x"00"&dtout                            when "1100",
                  x"000"&stat_reg                        when "1101",
                  inmediato                              when "1111",
                  x"0000"                                when others;
   
   --Genero las escrituras de los registros.
   r0en  <= write_reg   when sel_out = "0000" else '0'; 
   r1en  <= write_reg   when sel_out = "0001" else '0';
   r2en  <= write_reg   when sel_out = "0010" else '0';
   pcen  <= write_reg   when sel_out = "0100" else '0';
   spen  <= write_reg   when sel_out = "0101" else '0';    
   xen   <= write_reg   when sel_out = "0110" else '0';
   ccen  <= write_reg   when sel_out = "0111" else '0';
   aen   <= write_reg   when sel_out = "1000" else '0';
   aden  <= write_reg   when sel_out = "1011" else '0';
   dten  <= write_reg   when sel_out = "1110" else '0';   
             
   --Genero todos los registros.
   --Visibles primero.
   pc:   entity work.nano_cisc_reg(Behavioral)
         generic map(N=>ADDR_LEN)
         port map(clk=>clk, rst=>rst, load=>pcen, din=>aluout,dout=>pcout);
         
   sp:   entity work.nano_cisc_reg(Behavioral)
         generic map(N=>DATA_LEN)
         port map(clk=>clk, rst=>rst, load=>spen, din=>aluout(7 downto 0),dout=>spout);

   a:    entity work.nano_cisc_reg(Behavioral)
         generic map(N=>DATA_LEN)
         port map(clk=>clk, rst=>rst, load=>aen, din=>aluout(7 downto 0),dout=>aout);

   x:    entity work.nano_cisc_reg(Behavioral)
         generic map(N=>DATA_LEN)
         port map(clk=>clk, rst=>rst, load=>xen, din=>aluout(7 downto 0),dout=>xout);

   cc:   entity work.nano_cisc_reg(Behavioral)
         generic map(N=>DATA_LEN)
         port map(clk=>clk, rst=>rst, load=>ccen, din=>aluout(7 downto 0),dout=>ccout);

   --Invisibles.
   r0:   entity work.nano_cisc_reg(Behavioral)
         generic map(N=>ADDR_LEN)
         port map(clk=>clk, rst=>rst, load=>r0en, din=>aluout,dout=>r0out);   

   r1:   entity work.nano_cisc_reg(Behavioral)
         generic map(N=>ADDR_LEN)
         port map(clk=>clk, rst=>rst, load=>r1en, din=>aluout,dout=>r1out);   

   r2:   entity work.nano_cisc_reg(Behavioral)
         generic map(N=>ADDR_LEN)
         port map(clk=>clk, rst=>rst, load=>r2en, din=>aluout,dout=>r2out);   

   ad:   entity work.nano_cisc_reg(Behavioral)
         generic map(N=>ADDR_LEN)
         port map(clk=>clk, rst=>rst, load=>aden, din=>aluout,dout=>adout);   
 
   dt:   entity work.nano_cisc_reg(Behavioral)
         generic map(N=>DATA_LEN)
         port map(clk=>clk, rst=>rst, load=>dten, din=>aluout(7 downto 0),dout=>dtout);  

   sr:   entity work.nano_cisc_reg(Behavioral)
         generic map(N=>4)
         port map(clk=>clk, rst=>rst, load=>write_stat, din=>stat,dout=>stat_reg);  
         
end Behavioral;
