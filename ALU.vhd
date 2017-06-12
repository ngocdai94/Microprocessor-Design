--------------------------------------------------------------------------------
--
-- LAB #4
-- Dai Nguyen
--
--------------------------------------------------------------------------------

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity ALU is
	Port(	DataIn1: in std_logic_vector(31 downto 0);
		DataIn2: in std_logic_vector(31 downto 0);
		Control: in std_logic_vector(4 downto 0);
		Zero: out std_logic;
		ALUResult: out std_logic_vector(31 downto 0);
		Overflow: out std_logic);
end entity ALU;

architecture ALU_Arch of ALU is
	signal add_sub_out: std_logic_vector(31 downto 0);
	signal add_sub_carry: std_logic;
	signal shift_reg_out: std_logic_vector(31 downto 0);
	signal and_op_out: std_logic_vector(31 downto 0);
	signal or_op_out: std_logic_vector(31 downto 0);
	signal result: std_logic_vector(31 downto 0);

	-- ALU components	
	component adder_subtracter
		port(	datain_a: in std_logic_vector(31 downto 0);
			datain_b: in std_logic_vector(31 downto 0);
			add_sub: in std_logic;
			dataout: out std_logic_vector(31 downto 0);
			co: out std_logic;
			overflow: out std_logic);
	end component adder_subtracter;

	component shift_register
		port(	datain: in std_logic_vector(31 downto 0);
		   	dir: in std_logic;
			shamt:	in std_logic_vector(4 downto 0);
			dataout: out std_logic_vector(31 downto 0));
	end component shift_register;

begin
	-- ALU VHDL port mapping
	addsub:		adder_subtracter port map(DataIn1, DataIn2, Control(2), add_sub_out, add_sub_carry, Overflow);
	shift_reg:	shift_register port map(DataIn1, Control(3), DataIn2(10 downto 6), shift_reg_out);
	
	and_op_out <= DataIn1 and DataIn2;
	or_op_out <= DataIn1 or DataIn2;

	with Control(1 downto 0) select
		result <= 	add_sub_out when "00",
				and_op_out when "01",
				or_op_out when "10",
				shift_reg_out when others;
	
	with result select
		Zero <=	'1' when "00000000000000000000000000000000",
			'0' when others;

	ALUResult <= result;
end architecture ALU_Arch;


