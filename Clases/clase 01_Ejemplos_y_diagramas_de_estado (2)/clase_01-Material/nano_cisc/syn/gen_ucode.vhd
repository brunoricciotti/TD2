library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gen_ucode is
    Port ( clk          : in  STD_LOGIC;
           rst          : in  STD_LOGIC;
           zero         : in  STD_LOGIC;
           ucode_parm   : in  STD_LOGIC_VECTOR (15 downto 0);
           ucode_data   : out STD_LOGIC_VECTOR (31 downto 0);
           reg_stat     : out STD_LOGIC);
end gen_ucode;

architecture Behavioral of gen_ucode is
   constant ADDR_LEN    : natural := 12;
   constant STACK_LEN   : natural := 4;
   type tstack is array (natural range <>) of std_logic_vector(ADDR_LEN-1 downto 0);
   type estado is (S0, S1, S2);
   signal actual        : estado;
   signal execute       :  std_logic;
   signal load_pc       :  std_logic;
   signal push, pop     :  std_logic;
   signal ucode_val     :  std_logic_vector(33 downto 0);
   signal micro_pc      :  std_logic_vector(ADDR_LEN-1 downto 0);
   signal micro_stack   :  tstack(STACK_LEN-1 downto 0);
   signal sp            :  unsigned(1 downto 0);
   signal spi           :  natural range 0 to 3;
   signal spo           :  natural range 0 to 3;
begin
   uc:   entity work.ucode_rom(Behavioral)
         port map(   clk      => clk,
                     addrin   => micro_pc,
                     dout     => ucode_val);
   
   
   --Instrucciones (todos los saltos ucode_parm):
      --saltar             001
      --salta si zero      010
      --salta si no zero   011
      --call               100
      --ret                101
      --ejecutar           110
      
   load_pc     <= '1'         when ucode_val(33 downto 31)="001" else
                  '1'         when ucode_val(33 downto 31)="100" else
                  '1'         when ucode_val(33 downto 31)="101" else 
                  zero        when ucode_val(33 downto 31)="010" else
                  (not zero)  when ucode_val(33 downto 31)="011" else
                  '0';
               
   pop                     <= '1' when ucode_val(33 downto 31)="101" else '0';
   push                    <= '1' when ucode_val(33 downto 31)="100" else '0';
   spi                     <= to_integer(sp);
   spo                     <= to_integer(sp)-1;
   ucode_data(30 downto 0) <= ucode_val(30 downto 0);
   ucode_data(31)          <= execute;
   reg_stat                <= execute when ucode_val(33 downto 31)="111" else '0';
   
   process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            actual   <= S0;
            sp       <= (others => '0');
            micro_pc <= x"100";
            execute  <= '0';

         else
            case actual is
               when S0 =>  --Leo la memoria;                           
                           actual   <= S1;
                           execute  <= '0';
               when S1 =>  --Ejecuto.
                           actual <= S2;
                           if load_pc = '0' then
                              execute <= '1';
                           else
                              execute <= '0';
                           end if;
               
               when S2 =>  --Actualizo.   
                           actual   <= S0;
                           execute  <= '0'; 
                           if load_pc = '1' then
                              if push = '1' then
                                 micro_stack(spi)  <= micro_pc;
                                 micro_pc          <= ucode_parm(ADDR_LEN-1 downto 0);
                                 sp <= sp + 1;
                              elsif pop = '1'  then
                                 micro_pc <= std_logic_vector(unsigned(micro_stack(spo))+1);
                                 sp       <= sp - 1;
                           else
                              micro_pc <= ucode_parm(ADDR_LEN-1 downto 0);
                           end if;
                        else
                           micro_pc    <= std_logic_vector(unsigned(micro_pc)+1);
                        end if;
            end case;
         end if;
      end if;
   end process;
end Behavioral;
