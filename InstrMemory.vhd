--------------------------------------------------------------------------------
--
-- LAB #6 - Instruction Memory
--
--------------------------------------------------------------------------------
LIBRARY ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity InstructionRAM is
    Port(Reset:	  in std_logic;
	 Clock:	  in std_logic;
	 Address: in std_logic_vector(29 downto 0);
	 DataOut: out std_logic_vector(31 downto 0));
end entity InstructionRAM;

architecture instrucRAM of InstructionRAM is

   type ram_type is array (0 to 31) of std_logic_vector(31 downto 0);
   signal i_ram : ram_type;
   signal i_address : std_logic_vector(4 downto 0);

begin

  RamProc: process(Clock, Reset) is
  begin
    if Reset = '1' then
	-- seperate instruction to test
       i_ram <= (0 => B"000000_00000_00000_10000_00000_100000",		-- add  $s0, $zero, $zero    
		 1 => B"001000_00000_10010_0111111111111111",		-- addi $s2, $zero, 0x00007FFF
		 2 => B"001000_00000_10011_0000000000000001",		-- addi $s3, $zero, 0x00000001 
		 3 => B"000000_10010_10011_10100_00000_100000",		-- add  $s4, $s2, $s3 -->overflow!     
		 4 => B"000000_10010_10011_10101_00000_100010",		-- sub  $s5, $s2, $s3       
		 5 => B"000000_10101_10011_10101_00000_100000",		-- add  $s5, $s5, $s3
		 6 => B"001000_10101_10101_1111111111111111",		-- addi $s5, $s5, 0x0000FFFF
		 7 => B"000100_00000_00000_1111111111111111",		-- beq	$zero, $zero, -1
		others => X"00000000");             
    end if;
  end process RamProc;

  -- Decode address and return instruction to execute
  i_address <= Address(4 downto 0);
  DataOut   <= i_ram(to_integer(unsigned(i_address)));
 
end instrucRAM;	

----------------------------------------------------------------------------------------------------------------------------------------------------------------
