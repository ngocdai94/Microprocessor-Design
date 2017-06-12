--------------------------------------------------------------------------------
--
-- LAB #6 - Processor 
-- Dai Nguyen
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Processor is
    Port ( reset : in  std_logic;
	   clock : in  std_logic);
end Processor;

architecture holistic of Processor is
	component Control
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
	end component;

	component ALU
		Port(DataIn1: in std_logic_vector(31 downto 0);
		     DataIn2: in std_logic_vector(31 downto 0);
		     Control: in std_logic_vector(4 downto 0);
		     Zero: out std_logic;
		     ALUResult: out std_logic_vector(31 downto 0) );
	end component;
	
	component Registers
	    Port(ReadReg1: in std_logic_vector(4 downto 0); 
                 ReadReg2: in std_logic_vector(4 downto 0); 
                 WriteReg: in std_logic_vector(4 downto 0);
		 WriteData: in std_logic_vector(31 downto 0);
		 WriteCmd: in std_logic;
		 ReadData1: out std_logic_vector(31 downto 0);
		 ReadData2: out std_logic_vector(31 downto 0));
	end component;

	component InstructionRAM
    	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;

	component RAM 
	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;	 
		 OE:      in std_logic;
		 WE:      in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataIn:  in std_logic_vector(31 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;
	
	component BusMux2to1
		Port(selector: in std_logic;
		     In0, In1: in std_logic_vector(31 downto 0);
		     Result: out std_logic_vector(31 downto 0) );
	end component;
	
	component SmallBusMux2to1
		Port(selector: in std_logic;
		     In0, In1: in std_logic_vector(4 downto 0);
		     Result: out std_logic_vector(4 downto 0) );
	end component;

	component ProgramCounter
	    Port(Reset: in std_logic;
		 Clock: in std_logic;
		 PCin: in std_logic_vector(31 downto 0);
		 PCout: out std_logic_vector(31 downto 0));
	end component;

	component adder_subtracter
		port(	datain_a: in std_logic_vector(31 downto 0);
			datain_b: in std_logic_vector(31 downto 0);
			add_sub: in std_logic;
			dataout: out std_logic_vector(31 downto 0);
			co: out std_logic);
	end component adder_subtracter;

	component sign_extend
	    Port(input: in std_logic_vector(15 downto 0);
		 output: out std_logic_vector(31 downto 0));
	end component;
	
	component shift_left_32
	    Port(input: in std_logic_vector(31 downto 0);
		 output: out std_logic_vector(31 downto 0));
	end component;

----- signals declaration------
signal PCin: std_logic_vector(31 downto 0);
signal PCout: std_logic_vector(31 downto 0);
signal add_4_result: std_logic_vector(31 downto 0);

--- I-Mem ---
signal inst: std_logic_vector(31 downto 0);   -- instructions

--- Control ---
signal RegSrc: std_logic;
signal RegDst: std_logic;
signal Branch: std_logic_vector(1 downto 0);
signal MemRead: std_logic;
signal MemtoReg: std_logic;
signal ALUop: std_logic_vector(4 downto 0);
signal Memwrite: std_logic;
signal ALUSrc: std_logic;
signal RegWrite:std_logic;

-- Register and Data Memory
signal read1: std_logic_vector(31 downto 0);
signal read2: std_logic_vector(31 downto 0);
signal write_reg: std_logic_vector(4 downto 0);
signal read_reg: std_logic_vector(4 downto 0);
signal write_data: std_logic_vector(31 downto 0);
signal read_data_out1: std_logic_vector(31 downto 0);
signal read_data_out2: std_logic_vector(31 downto 0);
signal read_data: std_logic_vector(31 downto 0);   -- Data Memory Block

-- ALU near Data Memory Block
signal alu_result1: std_logic_vector(31 downto 0); 
signal zero: std_logic;

-- ALU near Shift Left 2 and MUX 2x2
signal alu_result2: std_logic_vector(31 downto 0); 
signal sl32: std_logic_vector(31 downto 0); -- Shift Left 2 Block
signal sign32: std_logic_vector(31 downto 0);  -- Sign Extended
signal Branch_Zero: std_logic_vector(2 downto 0);
signal BranchToMux: std_logic;

signal carryout: std_logic;	  -- adder: adder_subtracter


begin
	-- Add your code here
	-- BNE OR BEQ
	 Branch_Zero <= zero&Branch;	 
	 with Branch_Zero select
		BranchToMux <= '1' when "110" | "001",
			       '0' when others;

	--PC
	PC: ProgramCounter port map(reset, clock, PCin, PCout);

	--PC+4
	add_4: adder_subtracter port map(PCout, X"00000004", '0', add_4_result, carryout); --add is '0', sub is '1'
	instMem: InstructionRAM port map(reset, clock, PCout(31 downto 2), inst);

	--branch off instructions
	ctrl: Control port map(clock, inst(31 downto 26), inst(5 downto 0), RegSrc, RegDst, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite);
	mux_1_1: SmallBusMux2to1 port map(RegDst, inst(20 downto 16), inst(15 downto 11), write_reg); -- mux at write register
	mux_1_2: SmallBusMux2to1 port map(RegSrc, inst(25 downto 21), inst(20 downto 16), read_reg);  -- mux at read register 1
	i_reg: Registers port map(read_reg, inst(20 downto 16), write_reg, write_data, RegWrite, read1, read2);

	--sign-extend or or not?
	sign_ext: sign_extend port map(inst(15 downto 0), sign32);

	--first and second input to ALU
	mux_3: BusMux2to1 port map(ALUSrc, read2, sign32, read_data_out2);

	--sll 2 for branching and PC+4
	sl2: shift_left_32 port map(sign32, sl32);
	adder: adder_subtracter port map(add_4_result, sl32, '0', alu_result2, carryout); --add is '0', sub is '1'

	--ALU, DataMem, MUX for writing data (MUX 4) and MUX for next PC (MUX 5)
	--read 1 is read_data_out1
	alu1: ALU port map(read1, read_data_out2, ALUOp, zero, alu_result1);
	datamem: RAM port map(reset, clock, MemRead, MemWrite, alu_result1(31 downto 2), read2, read_data);
	mux_4: BusMux2to1 port map(MemtoReg, alu_result1, read_data, write_data);
	mux_5: BusMux2to1 port map(BranchToMux, add_4_result, alu_result2, PCin);

end holistic;

