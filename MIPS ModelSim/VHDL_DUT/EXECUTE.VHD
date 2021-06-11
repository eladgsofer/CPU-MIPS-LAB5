--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY  Execute IS
	PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Sign_extend 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Function_opcode : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			ALUOp 			: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			ALUSrc 			: IN 	STD_LOGIC;
			Zero 			: OUT	STD_LOGIC;
			ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Add_Result 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PC_plus_4 		: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			clock, reset	: IN 	STD_LOGIC );
END Execute;

ARCHITECTURE behavior OF Execute IS
SIGNAL Ainput, Binput 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL ALU_output_mux		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL Branch_Add 			: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
SIGNAL ALU_ctl				: STD_LOGIC_VECTOR( 5 DOWNTO 0 );
SIGNAL Function_translation	: STD_LOGIC_VECTOR( 5 DOWNTO 0 );
BEGIN
	Ainput <= Read_data_1;
						-- ALU input mux
	Binput <= Read_data_2 
		WHEN ( ALUSrc = '0' ) 
  		ELSE  Sign_extend( 31 DOWNTO 0 );
    -- AluOp 00 - lw/sw || ALUOP 01 - Beq || ALUOP 10 - Rtype 
    -- ALU_CTRL = command to ALU 
    -- 010
    -- 101
    -- OP = 00 -> ALUT_CTRL = 010
    -- OP = 01 -> 110

    --XOR op 00 func 100110
						-- Generate ALU control bits
	--ALU_ctl( 0 ) <= ( Function_opcode( 0 ) OR Function_opcode( 3 ) ) AND ALUOp(1 );
	--ALU_ctl( 1 ) <= ( NOT Function_opcode( 2 ) ) OR (NOT ALUOp( 1 ) );
	--ALU_ctl( 2 ) <= ( Function_opcode( 1 ) AND ALUOp( 1 )) OR ALUOp( 0 );
    Function_translation <= "101111" when Function_opcode = "001000" ELSE -- TODO:  JR CHANGE OPCODE
                            "000111" when Function_opcode = "000010" ELSE -- TODO:  SRL CHANGE OPCODE
                            Function_opcode;                              -- all other commands
    ALU_ctl <= Function_translation when ALUOp = "000000"  else ALUOp;
    
    
						-- Generate Zero Flag
	Zero <= '1' 
		WHEN ( ALU_output_mux( 31 DOWNTO 0 ) = X"00000000"  )
		ELSE '0';    
						-- Select ALU output        
	ALU_result <= X"0000000" & B"000"  & ALU_output_mux( 31 ) 
		WHEN  ALU_ctl = "111" 
		ELSE  	ALU_output_mux( 31 DOWNTO 0 );
						-- Adder to compute Branch Address
	Branch_Add	<= PC_plus_4( 9 DOWNTO 2 ) +  Sign_extend( 7 DOWNTO 0 ) ;
		Add_result 	<= Branch_Add( 7 DOWNTO 0 );

PROCESS ( ALU_ctl, Ainput, Binput )
	BEGIN
					-- Select ALU operation
 	CASE ALU_ctl IS
    ------------------ Arithmetic Instructions
						-- add
		WHEN "100000" 	=>	ALU_output_mux 	<= Ainput + Binput; 
						-- subtract
     	WHEN "100010" 	=>	ALU_output_mux 	<= Ainput - Binput;
						-- add immediate
	 	WHEN "001000" 	=>	ALU_output_mux 	<= Ainput + Binput;
						-- Multiply (without overflow)
        WHEN "011100" 	=>	ALU_output_mux <= X"00000000";                
    ------------------ Logical Instructions
                        -- and
 	 	WHEN "100100" 	=>	ALU_output_mux <= Ainput AND Binput; 
						-- or
 	 	WHEN "100101" 	=>	ALU_output_mux 	<= Ainput OR Binput; 
						-- xor
 	 	WHEN "100110" 	=>	ALU_output_mux 	<= Ainput XOR Binput; 
						-- andi
 	 	WHEN "001100" 	=>	ALU_output_mux <= Ainput AND Binput; 
						-- ori
  	 	WHEN "001101" 	=>	ALU_output_mux <= Ainput OR Binput; 
                        -- xori
        WHEN "001110" 	=>	ALU_output_mux <= Ainput XOR Binput; 
                        -- shift left logical
        WHEN "000000" 	=>	ALU_output_mux <= X"00000000";
                        -- shift right logical
        WHEN "000111"   => ALU_output_mux <= X"00000000";
        
    ------------------Data Transfer Instructions
                        -- lw
        WHEN "100011" 	=>	ALU_output_mux <= X"00000000";
                        -- sw
        WHEN "101011" 	=>	ALU_output_mux <= X"00000000";
                        -- lui Load constant into upper 16 bits. Lower 16 bits are set to zero.
        WHEN "001111" 	=>	ALU_output_mux <= X"00000000";
        -- MOVE - addu opcode - Rtype,  with $0
        WHEN "100001" 	=>	ALU_output_mux <= X"00000000";
        
    ------------------ Conditional Branch Instructions
        WHEN "100001" 	=>	ALU_output_mux <= X"00000000";
                        -- beq
        WHEN "000100" 	=>	ALU_output_mux <= X"00000000";
                        -- bneq
    ------------------ Comparsion Instructions
                        -- set on less then
        WHEN "101010" 	=>	ALU_output_mux <= X"00000000";
                        -- set on less then immediate 
        WHEN "001010" 	=>	ALU_output_mux <= X"00000000";
    ------------------ Unconditional Jump Instructions
                            -- jump
        WHEN "000010" 	=>	ALU_output_mux <= X"00000000";
                            -- jump register ???
        WHEN "101111" 	=>	ALU_output_mux <= X"00000000";
                            -- jump and link
        WHEN "000011" 	=>	ALU_output_mux <= X"00000000";
        
 	 	WHEN OTHERS	=>	ALU_output_mux 	<= X"00000000" ;
  	END CASE;
  END PROCESS;
END behavior;

