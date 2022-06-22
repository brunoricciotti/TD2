library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cunos_fsm is
    Port ( clk    : in  STD_LOGIC;
           rst    : in  STD_LOGIC;
           start  : in  STD_LOGIC;
           z      : in  STD_LOGIC;
           load   : out STD_LOGIC;
           e_s    : out STD_LOGIC;
           rdy    : out STD_LOGIC);
end cunos_fsm;

architecture Behavioral of cunos_fsm is
   type estado is (ESPERA, RESETEA, CHEQUEA_CERO, CUENTA);
   signal actual,futuro : estado;
   
begin

   process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            actual <= ESPERA;
         else
            actual <= futuro;
         end if;
      end if;
   end process;

   process(actual, start, z)
   begin
      case actual is
         when ESPERA => 
                        --Reseteo todo mientras espero el inicio.
                        if(start = '1') then
                           futuro <= RESETEA;
                        else
                           futuro <= ESPERA;
                        end if;
         when RESETEA =>
                        --Reseteo y cargo.
                        futuro <= CHEQUEA_CERO;
         when CHEQUEA_CERO =>
                        --Reviso si terminé de contar.
                        if(z = '1') then
                           futuro <= ESPERA;
                        else
                           futuro <= CUENTA;
                        end if;
         when CUENTA =>
                        --Cuento unos.
                        futuro <= CHEQUEA_CERO;
      end case;
   end process;

   process(actual)
   begin
      case actual is
         when ESPERA => 
                              load  <= '0';
                              e_s   <= '0';
                              rdy   <= '1';
         when RESETEA =>
                              load  <= '1';
                              e_s   <= '0';
                              rdy   <= '0';
         when CHEQUEA_CERO =>
                              load  <= '0';
                              e_s   <= '0';
                              rdy   <= '0';         
         when CUENTA =>
                              load  <= '0';
                              e_s   <= '1';
                              rdy   <= '0';            
      end case;
   end process;
end Behavioral;
