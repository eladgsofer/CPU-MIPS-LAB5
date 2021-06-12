		-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY control IS
   PORT( 	
	Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	RegDst 		: OUT 	STD_LOGIC;
	ALUSrc 		: OUT 	STD_LOGIC;
	MemtoReg 	: OUT 	STD_LOGIC;
	RegWrite 	: OUT 	STD_LOGIC;
	MemRead 		: OUT 	STD_LOGIC;
	MemWrite 	: OUT 	STD_LOGIC;
	Branch 		: OUT 	STD_LOGIC;
	ALUop 		: OUT 	STD_LOGIC_VECTOR( 2 DOWNTO 0 );
	clock, reset	: IN 	STD_LOGIC );

END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  R_format, OpcodeZero, I_format, Lw, Sw, Beq, Mul 	: STD_LOGIC;

BEGIN           
				-- Code to generate control signals using opcode bits
	R_format 	<=  '1'  WHEN  Opcode = "000000" ELSE '0';
    I_format    <=  '1'  WHEN  Opcode(5 DOWNTO 3) = "001" ELSE '0';
	Lw          <=  '1'  WHEN  Opcode = "100011"  ELSE '0';
 	Sw          <=  '1'  WHEN  Opcode = "101011"  ELSE '0';
   	Beq         <=  '1'  WHEN  Opcode = "000100"  ELSE '0';
   	Mul         <=  '1'  WHEN  Opcode = "011100"  ELSE '0';
  	RegDst    	<=  R_format;
 	ALUSrc  	<=  Lw OR Sw OR I_format;
	MemtoReg 	<=  Lw;
  	RegWrite 	<=  R_format OR Lw;
  	MemRead 	<=  Lw;
   	MemWrite 	<=  Sw; 
 	Branch      <=  Beq;
	--ALUOp( 1 ) 	<=  R_format;
	--ALUOp( 0 ) 	<=  Beq; 
	ALUOP   <= "000" when (Opcode = "001111" OR Opcode = "001000")  ELSE  --- LUI & ADDI = add 
			   "001" when (Opcode = "001010" OR Opcode = "000100" OR Opcode = "000101")  ELSE  --- SLTI, BEQ, BNQ = sub
			   "010" when Opcode = "001110" ELSE  --- XOR
               "011" when Opcode = "001101" ELSE  --- OR
			   "100" when Opcode = "001100" ELSE  --- ANDI
               "101" when Opcode = "011100" ELSE  --- MUL
               "111" when Opcode = "000000" ELSE  --- R-Type
               "000";
-- ALUOP to function:
-- 000 : add  - LUI,ADDI
-- 001 : sub  - SLTI,BEQ,BNQ
-- 010 : xor  - XORI
-- 011 : or   - ORI 
-- 100 : and  - ANDI
-- 101 : mul  - MUL

   END behavior;


