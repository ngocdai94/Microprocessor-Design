--------------------------------------------------------------------------------
--
-- LAB #6 - Processor Elements
-- Dai Nguyen
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SmallBusMux2to1 is
	Port(selector: in std_logic;
	     In0, In1: in std_logic_vector(4 downto 0);
	     Result:   out std_logic_vector(4 downto 0) );
end entity SmallBusMux2to1;

architecture switching of SmallBusMux2to1 is
begin
    with selector select
	Result <= In0 when '0',
		  In1 when others;
end architecture switching;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BusMux2to1 is
	Port(	selector: in std_logic;
			In0, In1: in std_logic_vector(31 downto 0);
			Result: out std_logic_vector(31 downto 0) );
end entity BusMux2to1;

architecture selection of BusMux2to1 is
begin
	-- Add your code here
	with selector select
		Result <= In0 when '0',
			  In1 when others;
end architecture selection;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Control is
      Port(clk : in  STD_LOGIC;
           opcode : in  STD_LOGIC_VECTOR (5 downto 0);
           funct  : in  STD_LOGIC_VECTOR (5 downto 0);
           RegSrc : out  STD_LOGIC;
           RegDst : out  STD_LOGIC;
           Branch : out  STD_LOGIC_VECTOR(1 downto 0);
           MemRead : out  STD_LOGIC;
           MemtoReg : out  STD_LOGIC;
           ALUOp : out  STD_LOGIC_VECTOR(4 downto 0);
           MemWrite : out  STD_LOGIC;
           ALUSrc : out  STD_LOGIC;
           RegWrite : out  STD_LOGIC);
end Control;

architecture Boss of Control is
signal result: std_logic_vector(10 downto 0);
signal tempOp: std_logic_vector(2 downto 0);
signal funct1: std_logic_vector(2 downto 0);
signal select_ctrl1: std_logic_vector(8 downto 0);
signal select_ctrl2: std_logic_vector(5 downto 0);
begin
	-- Add your code here
	with opcode select
		result <= "01111000000"	when "100011", --lw
			  "01001100000" when "101011", --sw
			  "00001010011" when "000100", --beq --> branch = 10
			  "00001001011" when "000101", --bne --> branch = 01
			  "01011000001" when "001000", --addi
			  "01011000010" when "001101", --ori
			  "10011000111" when others;   --r-type (add, subtract, and, or)
	RegDst <= result(10);
	ALUSrc <= result(9);
	MemtoReg <= result(8);
	RegWrite <= not(clk) and result(7);
	MemRead <= result(6);
	MemWrite <= result(5);
	Branch <= result(4 downto 3);
	tempOp <= result(2 downto 0); 

	with funct select
		funct1 <= "000" when "100000", --add
		  	  "001" when "100010", --sub
		  	  "010" when "100100", --and
	  	  	  "011" when "100101", --or
	          	  "100" when "000000", --sll
		  	  "101" when "000010", --srl
	         	  "111" when others; --i-type
			
	-- double check to set ALUSrc = '1' --- sll, srl
	with opcode&funct select
		ALUSrc <= '1' when "000000000000" | "000000000010", --sll, srl
			  '0' when others;

	with opcode&funct select
		RegSrc <= '1' when "000000000000" | "000000000010",
			  '0' when others;
	
	select_ctrl2 <= tempOp&funct1;	
	with select_ctrl2 select
		ALUOp <= "00001" when "111010", --and
			 "00010" when "111011", --or
			 "00010" when "010111", --ori
			 "00011" when "111100", --sll
			 "00111" when "111101", --srl
			 "00100" when "111001", --sub
			 "00100" when "011111", --bne/beq
			 "00000" when others; --add/addi/lw/sw
	
end architecture Boss;
------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ProgramCounter is
    Port(Reset: in std_logic;
	 Clock: in std_logic;
	 PCin: in std_logic_vector(31 downto 0);
	 PCout: out std_logic_vector(31 downto 0));
end entity ProgramCounter;

architecture executive of ProgramCounter is
signal new_address: std_logic_vector(31 downto 0);
begin
-- Add your code here
process(Clock, Reset)
	begin
	if (Reset = '1') then
		new_address <= X"00400000";
	end if;
	if (falling_edge(Clock)) then
		new_address <= PCin;
	end if;
	if (rising_edge(Clock)) then
		PCOut <= new_address;
	end if;
end process;
end executive;
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sign_extend is
    Port(input: in std_logic_vector(15 downto 0);
	 output: out std_logic_vector(31 downto 0));
end entity sign_extend;

architecture behav of sign_extend is
begin
	with input(15) select
		output <= X"0000"&input(15 downto 0) when '0',
			  X"FFFF"&input(15 downto 0) when others;
end behav;
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity shift_left_32 is
    Port(input: in std_logic_vector(31 downto 0);
	 output: out std_logic_vector(31 downto 0));
end entity shift_left_32;

architecture behav of shift_left_32 is
begin
	output <= input(29 downto 0)&"00";
end behav;
--------------------------------------------------------------------------------