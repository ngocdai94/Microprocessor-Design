--------------------------------------------------------------------------------
--
-- LAB #5 - Memory and Register Bank
--
--------------------------------------------------------------------------------
LIBRARY ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity RAM is
    Port(Reset:	  in std_logic;
	 Clock:	  in std_logic;	 
	 OE:      in std_logic;
	 WE:      in std_logic;
	 Address: in std_logic_vector(29 downto 0);
	 DataIn:  in std_logic_vector(31 downto 0);
	 DataOut: out std_logic_vector(31 downto 0));
end entity RAM;

architecture staticRAM of RAM is

   type ram_type is array (0 to 127) of std_logic_vector(31 downto 0);
   signal i_ram : ram_type;

begin

  RamProc: process(Clock, Reset, OE, WE) is

  begin
    if Reset = '1' then
	i_ram <= (others => (others => '0'));
    end if;

    if falling_edge(Clock) then
	if (WE = '1') then
		if (to_integer(unsigned(Address)) < 128) then
			i_ram(to_integer(unsigned(Address))) <= DataIn;
		end if;
	end if;
    end if;

	if (OE = '0') then
		if (to_integer(unsigned(Address)) < 128) then
			DataOut <= i_ram(to_integer(unsigned(Address)));
		else
			DataOut <= (others => 'Z');
		end if;
   	 end if;
  end process RamProc;

end staticRAM;	


--------------------------------------------------------------------------------
LIBRARY ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity Registers is
    Port(ReadReg1: in std_logic_vector(4 downto 0); 
         ReadReg2: in std_logic_vector(4 downto 0); 
         WriteReg: in std_logic_vector(4 downto 0);
	 WriteData: in std_logic_vector(31 downto 0);
	 WriteCmd: in std_logic;
	 ReadData1: out std_logic_vector(31 downto 0);
	 ReadData2: out std_logic_vector(31 downto 0));
end entity Registers;

architecture remember of Registers is
	type reg_type is array (0 to 31) of std_logic_vector(31 downto 0);
	-- reg_type(0) => $zero
	-- reg_type(16) => $s0
	-- ...
	-- reg_type(23) => $s7
	signal i_reg : reg_type;	

begin

RegProc: process(WriteCmd, ReadReg1, ReadReg2) is

	begin
		i_reg(0) <= X"00000000";

		ReadData1 <= i_reg(to_integer(unsigned(ReadReg1)));
		ReadData2 <= i_reg(to_integer(unsigned(ReadReg2)));

		if(WriteCmd = '1') then
			if(WriteReg /= "00000") then
				i_reg(to_integer(unsigned(WriteReg))) <= WriteData;			
			end if;
		end if;

end process RegProc;


end remember;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
