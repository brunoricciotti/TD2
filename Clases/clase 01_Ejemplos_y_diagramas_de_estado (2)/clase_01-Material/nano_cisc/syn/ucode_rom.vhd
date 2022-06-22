library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

   --Instrucciones  microcodigo (parametro por op0):
      --saltar             001
      --salta si zero      010
      --salta si no zero   011
      --call               100
      --ret                101
      --ejecutar           110
      --ejecutar y act ss  111
   
   -- CC(0) = CY
   -- CC(1) = OV
   -- CC(2) = S
   -- CC(3) = Z
   
   -- |-----------------|------------|--------|
   -- |    Registro     |  op1 -op2  |  dst   |
   -- |-----------------|------------|--------|
   -- |       r0        |    0000    |  0000  |
   -- |       r1        |    0001    |  0001  |
   -- |       r2        |    0010    |  0010  |
   -- |    r2(swapped)  |    0011    |  ----  |
   -- |       pc        |    0100    |  0100  |
   -- |       sp        |    0101    |  0101  |
   -- |        x        |    0110    |  0110  |
   -- |       cc        |    0111    |  0111  |
   -- |        a        |    1000    |  1000  |   
   -- |     din&din     |    1001    |  1001  |   
   -- |   pc (swapped)  |    1010    |  ----  |
   -- |   address out   |    1011    |  1011  |
   -- |     x"0000"     |    1100    |  1100  |
   -- |   stat_reg(3:0) |    1101    |  1101  |
   -- |     dtout       |    1110    |  1110  |
   -- |   ucode(15:0)   |    1111    |  1111  |
   -- |-----------------|------------|--------|
   
   --  inmediato   <= ucode_data(15 downto 0);
   --  sel_r0      <= ucode_data(19 downto 16);
   --  sel_r1      <= ucode_data(23 downto 20);
   --  sel_out     <= ucode_data(27 downto 24);
   --  sel_alu     <= ucode_data(30 downto 28);

   -- |-----------------|------------|
   -- |  Comando ALU    |  operacion |
   -- |-----------------|------------|
   -- |       000       |   op0+op1  |
   -- |       001       |   op0|op1  |
   -- |       010       |   op0&op1  |
   -- |       011       |   op0^op1  |
   -- |       100       |   op0>>1   |
   -- |-----------------|------------|      

   
entity ucode_rom is
    Port ( clk    : in  STD_LOGIC;
           addrin : in  STD_LOGIC_VECTOR (11 downto 0);
           dout   : out STD_LOGIC_VECTOR (33 downto 0));
end ucode_rom;

architecture Behavioral of ucode_rom is

begin
   process(clk)
   begin
      if(rising_edge(clk)) then
         case addrin is
            
            --Procedimiento de bÃºsqueda de opcode.
            when x"100" => dout <= "110"& "000"& x"B4F"& x"0000";  -- addr = PC + 0x0000;
            when x"101" => dout <= "110"& "010"& x"29F"& x"00FF";  -- R2 = DIN & 0x00FF;
            when x"102" => dout <= "001"& "000"& x"002"& x"0000";  -- jmp [R2]
            
            --Incremento PC y busco opcode nuevo.
            when x"103" => dout <= "110"& "000"& x"44F"& x"0001"; -- PC = PC + 1;
            when x"104" => dout <= "001"& "000"& x"00F"& x"0100"; -- jmp 0x100;
            
            --Incremento ACC
            when x"105" => dout <= "111"& "000"& x"88F"& x"0001"; -- A = A + 1
            when x"106" => dout <= "100"& "000"& x"00F"& x"030A"; -- setZC()
            when x"107" => dout <= "001"& "000"& x"00F"& x"0103"; -- jmp Inc_PC
            
            --Decremento ACC.
            when x"108" => dout <= "111"& "000"& x"88F"& x"FFFF"; -- A = A - 1
            when x"109" => dout <= "100"& "000"& x"00F"& x"030A"; -- setZC()
            when x"10A" => dout <= "001"& "000"& x"00F"& x"0103"; -- jmp Inc_PC
            
            --Salto largo.
            when x"10B" => dout <= "110"& "000"& x"44F"& x"0001"; -- PC = PC + 1;
            when x"10C" => dout <= "110"& "000"& x"B4F"& x"0000"; -- addr = PC + 0x0000;
            when x"10D" => dout <= "110"& "010"& x"09F"& x"00FF"; -- R0 = din & 0x00FF
            when x"10E" => dout <= "110"& "000"& x"44F"& x"0001"; -- PC = PC + 1;
            when x"10F" => dout <= "110"& "000"& x"B4F"& x"0000"; -- addr = PC + 0x0000;
            when x"110" => dout <= "110"& "010"& x"19F"& x"FF00"; -- R1 = din & 0xFF00
            when x"111" => dout <= "110"& "001"& x"410"& x"0000"; -- PC = R1 | R0
            when x"112" => dout <= "001"& "000"& x"00F"& x"0100"; -- JMP Buscar OPCODE;
           
            --Cargar SP inmediato.
            when x"113" => dout <= "110"& "000"& x"44F"& x"0001"; -- PC = PC + 1;
            when x"114" => dout <= "110"& "000"& x"B4F"& x"0000"; -- addr = PC + 0x0000;
            when x"115" => dout <= "110"& "010"& x"59F"& x"00FF"; -- SP = din & 0x00FF
            when x"116" => dout <= "001"& "000"& x"00F"& x"0103"; -- jmp Inc_PC
            
            --Llamada a subrutina.
            when x"117" => dout <= "110"& "000"& x"24F"& x"0003"; -- R2 = PC + 3
            when x"118" => dout <= "110"& "000"& x"55F"& x"FFFF"; -- SP = SP - 1
            when x"119" => dout <= "110"& "000"& x"B5F"& x"0000"; -- addr = SP + 0;
            when x"11A" => dout <= "110"& "010"& x"E2F"& x"00FF"; -- dtot = R2 & 0xFF
            when x"11B" => dout <= "110"& "111"& x"A00"& x"0000"; -- wr
            when x"11C" => dout <= "110"& "000"& x"55F"& x"FFFF"; -- SP = SP - 1
            when x"11D" => dout <= "110"& "000"& x"B5F"& x"0000"; -- addr = SP + 0;
            when x"11E" => dout <= "110"& "010"& x"E3F"& x"00FF"; -- dtot = R2h & 0xFF
            when x"11F" => dout <= "110"& "111"& x"A00"& x"0000"; -- wr
            when x"120" => dout <= "110"& "000"& x"44F"& x"0001"; -- PC = PC + 1;
            when x"121" => dout <= "110"& "000"& x"B4F"& x"0000"; -- addr = PC + 0x0000;
            when x"122" => dout <= "110"& "010"& x"09F"& x"00FF"; -- R0 = din & 0x00FF
            when x"123" => dout <= "110"& "000"& x"44F"& x"0001"; -- PC = PC + 1;
            when x"124" => dout <= "110"& "000"& x"B4F"& x"0000"; -- addr = PC + 0x0000;
            when x"125" => dout <= "110"& "010"& x"19F"& x"FF00"; -- R1 = din & 0xFF00
            when x"126" => dout <= "110"& "001"& x"410"& x"0000"; -- PC = R1 | R0
            when x"127" => dout <= "001"& "000"& x"00F"& x"0100"; -- JMP Buscar OPCODE;
           
            --Retorno de Subrutina.
            when x"128" => dout <= "110"& "000"& x"B5F"& x"0000"; -- addr = SP + 0;
            when x"129" => dout <= "110"& "010"& x"09F"& x"FF00"; -- R0 = din & 0xFF00
            when x"12A" => dout <= "110"& "000"& x"55F"& x"0001"; -- SP = SP + 1
            when x"12B" => dout <= "110"& "000"& x"B5F"& x"0000"; -- addr = SP + 0;
            when x"12C" => dout <= "110"& "010"& x"19F"& x"00FF"; -- R1 = din & 0x00FF
            when x"12D" => dout <= "110"& "000"& x"55F"& x"0001"; -- SP = SP + 1
            when x"12E" => dout <= "110"& "001"& x"410"& x"0000"; -- PC = R1 | R0
            when x"12F" => dout <= "001"& "000"& x"00F"& x"0100"; -- JMP Buscar OPCODE;
 
            --Carga X inmediato.
            when x"130" => dout <= "110"& "000"& x"44F"& x"0001"; -- PC = PC + 1;
            when x"131" => dout <= "110"& "000"& x"B4F"& x"0000"; -- addr = PC + 0x0000;
            when x"132" => dout <= "110"& "010"& x"69F"& x"00FF"; -- X = din & 0x00FF
            when x"133" => dout <= "001"& "000"& x"00F"& x"0103"; -- jmp Inc_PC
            
            --MOV A, inm16+X 
            when x"134" => dout <= "100"& "000"& x"00F"& x"0300"; -- CALL buscar INM16+X
            when x"135" => dout <= "111"& "010"& x"80F"& x"00FF"; -- A = R0
            when x"136" => dout <= "100"& "000"& x"00F"& x"030A"; -- setZC()
            when x"137" => dout <= "001"& "000"& x"00F"& x"0103"; -- jmp Inc_PC
 
 
            --JNZ REL (-128, + 127)
            when x"138" => dout <= "110"& "000"& x"44F"& x"0001"; -- PC = PC + 1;
            when x"139" => dout <= "110"& "000"& x"B4F"& x"0000"; -- addr = PC + 0x0000;
            when x"13A" => dout <= "110"& "010"& x"09F"& x"00FF"; -- R0 = din & 0x00FF
            when x"13B" => dout <= "110"& "010"& x"10F"& x"0080"; -- R1 = R0 & 0x80
            when x"13C" => dout <= "010"& "101"& x"11F"& x"013E"; -- Sí R1 = 0 jmp to 0x13E
            when x"13D" => dout <= "110"& "001"& x"00F"& x"FF00"; -- R0 = 0xFF00 | R0
            when x"13E" => dout <= "110"& "010"& x"17F"& x"0008"; -- R1 = Z
            when x"13F" => dout <= "010"& "101"& x"11F"& x"0141"; -- Sí R1 = 0 jmp to 0x141
            when x"140" => dout <= "001"& "000"& x"00F"& x"0103"; -- jmp Inc_PC
            when x"141" => dout <= "110"& "000"& x"440"& x"0000"; -- PC = PC + R0
            when x"142" => dout <= "001"& "000"& x"00F"& x"0100"; -- JMP Buscar OPCODE;
 
            --CLR A
            when x"143" => dout <= "111"& "010"& x"88F"& x"0000"; -- A = A & 0x0000
            when x"144" => dout <= "100"& "000"& x"00F"& x"030A"; -- setZC()
            when x"145" => dout <= "001"& "000"& x"00F"& x"0103"; -- jmp Inc_PC
            
 
            --Subrutina de búsqueda para inm16+X (devuelve por R0)
            when x"300" => dout <= "110"& "000"& x"44F"& x"0001"; -- PC = PC + 1;
            when x"301" => dout <= "110"& "000"& x"B4F"& x"0000"; -- addr = PC + 0x0000;
            when x"302" => dout <= "110"& "010"& x"09F"& x"00FF"; -- R0 = din & 0x00FF
            when x"303" => dout <= "110"& "000"& x"44F"& x"0001"; -- PC = PC + 1;
            when x"304" => dout <= "110"& "000"& x"B4F"& x"0000"; -- addr = PC + 0x0000;
            when x"305" => dout <= "110"& "010"& x"19F"& x"FF00"; -- R1 = din & 0xFF00
            when x"306" => dout <= "110"& "001"& x"110"& x"0000"; -- R1 = R1 | R0
            when x"307" => dout <= "110"& "000"& x"B16"& x"0000"; -- addr = R1 + X
            when x"308" => dout <= "110"& "000"& x"09F"& x"0000"; -- R0 = [addr]
            when x"309" => dout <= "101"& "000"& x"00F"& x"0000"; -- RET
            
            --Subrutina que setea el Z y S
            when x"30A" => dout <= "110"& "010"& x"2DF"& x"000C"; -- R2 = STAT_REG & 0x0C.
            when x"30B" => dout <= "110"& "010"& x"77F"& x"0003"; -- CC = CC 0x03
            when x"30C" => dout <= "110"& "001"& x"772"& x"0000"; -- CC = CC | R2
            when x"30D" => dout <= "101"& "000"& x"00F"& x"0000"; -- RET
            
            --Tabla de cÃ³digos de operacion
            when x"000" => dout <= "001"& "000"& x"00F"& x"0103"; -- NOP  
            when x"001" => dout <= "001"& "000"& x"00F"& x"0105"; -- A = A + 1
            when x"002" => dout <= "001"& "000"& x"00F"& x"0108"; -- A = A - 1
            when x"003" => dout <= "001"& "000"& x"00F"& x"010B"; -- JMP largo
            when x"004" => dout <= "001"& "000"& x"00F"& x"0113"; -- MOV SP, imm8
            when x"005" => dout <= "001"& "000"& x"00F"& x"0117"; -- CALL inm16
            when x"006" => dout <= "001"& "000"& x"00F"& x"0128"; -- RET
            when x"007" => dout <= "001"& "000"& x"00F"& x"0130"; -- MOV X, inm8
            when x"008" => dout <= "001"& "000"& x"00F"& x"0134"; -- MOV A, [inm16+X]
            when x"009" => dout <= "001"& "000"& x"00F"& x"0138"; -- JNZ REL
            when x"00A" => dout <= "001"& "000"& x"00F"& x"0143"; -- CLR A
            when others => dout <= "001"& "000"& x"00F"& x"0103"; -- NOP
         end case;
      end if;
   end process;
end Behavioral;

