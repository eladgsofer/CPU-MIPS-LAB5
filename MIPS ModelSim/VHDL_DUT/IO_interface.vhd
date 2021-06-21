LIBRARY ieee;
USE ieee.std_logic_1164.all;

-------------------------------------
ENTITY IO_interface IS
  GENERIC (BUS_W : INTEGER := 8); -- QUARTUS MODE = 12; | MODELSIM = 8;
  PORT (    datain : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			address : IN STD_LOGIC_VECTOR (BUS_W-1 DOWNTO 0);
			SW : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			clk, MemRead, MemWrite: IN std_logic;
			LEDG, LEDR : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			HEX0, HEX1, HEX2, HEX3 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
            dataout: OUT STD_LOGIC_VECTOR(31 downto 0));
END IO_interface;
--------------------------------------------------------------
architecture dfl of IO_interface is
  component HexGen is
		port(
			HexIn : in std_logic_vector(3 downto 0);
			----------------------------------------
			HexOut : out std_logic_vector(6 downto 0)
		);
	end component;
	
    component RW_interface IS
        GENERIC (n : INTEGER := 8);
        PORT (LatchDataIn  : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
              MemRead, MemWrite, CSi, clk : IN STD_LOGIC;
              MipsDataBus  : OUT STD_LOGIC_VECTOR(31 downto 0);
              IoDeviceDataIn     : OUT STD_LOGIC_VECTOR(n-1 downto 0));
    END component;
	
	component R_interface IS
		PORT (datain : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			  MemRead, CS7 : IN STD_LOGIC;
			  dataout : OUT STD_LOGIC_VECTOR(31 downto 0));
	END component;
	
	component Decoder4_7 IS
		PORT (Address : IN STD_LOGIC_VECTOR (3 DOWNTO 0); 
			  CS: OUT STD_LOGIC_VECTOR(6 downto 0));
	END component;
	-----------------------------------------------------------
	SIGNAL Out_SW, Out_LEDG, Out_LEDR, Out_HEX0, Out_HEX1, Out_HEX2, Out_HEX3 : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL CS : STD_LOGIC_VECTOR (6 DOWNTO 0);
	SIGNAL disp_LEDG,disp_LEDR : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL disp_HEX0,disp_HEX1,disp_HEX2,disp_HEX3 : STD_LOGIC_VECTOR (3 DOWNTO 0);
	SIGNAL D_adress : STD_LOGIC_VECTOR (3 DOWNTO 0);
begin
    D_adress <= (3=>address(BUS_W-1),2=>address(4),1=>address(3),0=>address(2)); FOR QUARTUS!!!
	--D_adress <= (3=>address(BUS_W-1),2=>address(2),1=>address(1),0=>address(0));
	
	B1 : Decoder4_7 port map(D_adress, CS);
	
	B2 : R_interface port map(SW,MemRead,CS(6),Out_SW);
	
	B3 : RW_interface generic map(8) port map(datain(7 DOWNTO 0),MemRead,MemWrite,CS(0),clk,Out_LEDG,disp_LEDG);
	
	B4 : RW_interface generic map(8) port map(datain(7 DOWNTO 0),MemRead,MemWrite,CS(1),clk,Out_LEDR,disp_LEDR);
	
	B5 : RW_interface generic map(4) port map(datain(7 DOWNTO 0),MemRead,MemWrite,CS(2),clk,Out_HEX0,disp_HEX0);
	
	B6 : RW_interface generic map(4) port map(datain(7 DOWNTO 0),MemRead,MemWrite,CS(3),clk,Out_HEX1,disp_HEX1);
	
	B7 : RW_interface generic map(4) port map(datain(7 DOWNTO 0),MemRead,MemWrite,CS(4),clk,Out_HEX2,disp_HEX2);
	
	B8 : RW_interface generic map(4) port map(datain(7 DOWNTO 0),MemRead,MemWrite,CS(5),clk,Out_HEX3,disp_HEX3);
	
	H0 : HexGen port map(HexIn=>disp_HEX0,HexOut=>HEX0);

	H1 : HexGen port map(disp_HEX1,HEX1);

	H2 : HexGen port map(disp_HEX2,HEX2);

	H3 : HexGen port map(disp_HEX3,HEX3);
	
	LEDG<=disp_LEDG;
	LEDR<=disp_LEDR;
    
	dataout <= Out_SW   WHEN CS(6) = '1' ELSE
			   Out_LEDG WHEN CS(0) = '1' ELSE
			   Out_LEDR WHEN CS(1) = '1' ELSE
			   Out_HEX0 WHEN CS(2) = '1' ELSE
			   Out_HEX1 WHEN CS(3) = '1' ELSE
			   Out_HEX2 WHEN CS(4) = '1' ELSE
			   Out_HEX3 WHEN CS(5) = '1' ELSE
			   X"00000000";
	
END dfl;

