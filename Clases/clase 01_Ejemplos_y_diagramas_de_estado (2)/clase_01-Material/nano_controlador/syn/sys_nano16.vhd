library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sys_nano16 is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           leds: out STD_LOGIC_VECTOR (15 downto 0));
end sys_nano16;

architecture Behavioral of sys_nano16 is
   constant FCLK              : natural := 100_000_000;
   constant FDIV              : natural :=  10_000_000;
   constant ADDRESS_TIM       :  std_logic_vector(15 downto 0) := x"1000";
   constant ADDRESS_PO        :  std_logic_vector(15 downto 0) := x"2000";
   signal din_nano, dout_nano :  std_logic_vector(15 downto 0);
   signal addr                :  std_logic_vector(15 downto 0);
   signal wr, wr_tim, wr_po   :  std_logic;
   signal data_tim,data_rom   :  std_logic_vector(15 downto 0);
begin

   din_nano <= data_rom when addr(15 downto 12) = "0000" else data_tim;
   wr_tim   <= wr       when addr(15 downto 12) = "0001" else '0';
   wr_po    <= wr       when addr(15 downto 12) = "0010" else '0';
   
   up:   entity work.nano16(Behavioral)
         port map(   clk   => clk,
                     rst   => rst,
                     din   => din_nano,
                     dout  => dout_nano,
                     addr  => addr,
                     wr    => wr);
                     
   data_tim(15 downto 8) <= (others => '0');
   tim:  entity work.Temporizador(Behavioral)
         generic map(FCLK     => FCLK,
                     FBASE    => FDIV)
         port map(   clk      => clk,
                     rst      => rst,
                     wr       => wr_tim,
                     data_in 	=> dout_nano(7 downto 0),
                     data_out => data_tim (7 downto 0));

   pot:  entity work.PuertaSalida(Behavioral)
         generic map(N        => 16)
         port map(   clk      => clk,
                     rst      => rst,
                     en       => wr_po,
                     datos    => dout_nano,
                     pines 	=> leds);

   process(clk)
   begin
      if(rising_edge(clk)) then
         case addr(4 downto 0) is
            when "00000" => data_rom   <= "0001"&"00011111"&"0001";    --LREL R1,+31 (address TIM)
            when "00001" => data_rom   <= "0001"&"00011101"&"0010";    --LREL R2,+29 (address PO)
            when "00010" => data_rom   <= "1001"&"0011"&"0000"&"0000"; --ADD  R3,R0,R0
            when "00011" => data_rom   <= "0010"&"0011"&"00000001";    --LDC  R3,0x01
            when "00100" => data_rom   <= "1001"&"0100"&"0000"&"0000"; --ADD  R4,R0,R0
            when "00101" => data_rom   <= "0010"&"0100"&"00001010";    --LDC  R4,0x0A
            when "00110" => data_rom   <= "0000"&"0000"&"0010"&"0011"; --STR  [R2],R3
            when "00111" => data_rom   <= "0000"&"0000"&"0001"&"0100"; --STR  [R1],R4
            when "01000" => data_rom   <= "0011"&"0101"&"0001"&"0000"; --LDR  R5,[R1]
            when "01001" => data_rom   <= "0100"&"11111111"&"0101";    --JREL -1,R5
            when "01010" => data_rom   <= "1010"&"0011"&"0011"&"0011"; --ROL  R3,R3,R3
            when "01011" => data_rom   <= "0000"&"0000"&"0010"&"0011"; --STR  [R2],R3
            when "01100" => data_rom   <= "0000"&"0000"&"0001"&"0100"; --STR  [R1],R4
            when "01101" => data_rom   <= "0100"&"11111011"&"0000";    --JREL -5,R0
            when "11110" => data_rom   <= x"2000";
            when "11111" => data_rom   <= x"1000";
            when others  => data_rom   <= "0100"&"0000"&"0000"&"0000"; --JREL 0x00,R0
         end case;
      end if;
   end process;
end Behavioral;
