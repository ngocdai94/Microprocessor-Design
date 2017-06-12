--------------------------------------------------------------------------------
--
-- LAB #3
-- Dai Nguyen
--
--------------------------------------------------------------------------------

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity bitstorage is
	port(bitin: in std_logic;
		 enout: in std_logic;
		 writein: in std_logic;
		 bitout: out std_logic);
end entity bitstorage;

architecture memlike of bitstorage is
	signal q: std_logic := '0';
begin
	process(writein) is
	begin
		if (rising_edge(writein)) then
			q <= bitin;
		end if;
	end process;
	
	-- Note that data is output only when enout = 0	
	bitout <= q when enout = '0' else 'Z';
end architecture memlike;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity fulladder is
    port (a : in std_logic;
          b : in std_logic;
          cin : in std_logic;
          sum : out std_logic;
          carry : out std_logic
         );
end fulladder;

architecture addlike of fulladder is
begin
  sum   <= a xor b xor cin; 
  carry <= (a and b) or (a and cin) or (b and cin); 
end architecture addlike;


--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity register8 is
	port(datain: in std_logic_vector(7 downto 0);
	     enout:  in std_logic;
	     writein: in std_logic;
	     dataout: out std_logic_vector(7 downto 0));
end entity register8;

architecture memmy of register8 is
	component bitstorage
		port(bitin: in std_logic;
		 	 enout: in std_logic;
		 	 writein: in std_logic;
		 	 bitout: out std_logic);
	end component;
begin
	bit0: bitstorage port map (datain(0), enout, writein, dataout(0));
	bit1: bitstorage port map (datain(1), enout, writein, dataout(1));
	bit2: bitstorage port map (datain(2), enout, writein, dataout(2));
	bit3: bitstorage port map (datain(3), enout, writein, dataout(3));
	bit4: bitstorage port map (datain(4), enout, writein, dataout(4));
	bit5: bitstorage port map (datain(5), enout, writein, dataout(5));
	bit6: bitstorage port map (datain(6), enout, writein, dataout(6));
	bit7: bitstorage port map (datain(7), enout, writein, dataout(7));
end architecture memmy;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity register32 is
	port(datain: in std_logic_vector(31 downto 0);
		 enout32,enout16,enout8: in std_logic;
		 writein32, writein16, writein8: in std_logic;
		 dataout: out std_logic_vector(31 downto 0));
end entity register32;

architecture biggermem of register32 is
	signal x: std_logic_vector(2 downto 0);
	signal e: std_logic_vector(2 downto 0);
	signal y: std_logic_vector(2 downto 0);
	signal w: std_logic_vector(2 downto 0);
	component register8
		port(datain: in std_logic_vector(7 downto 0);
		     enout:  in std_logic;
	 	     writein: in std_logic;
		     dataout: out std_logic_vector(7 downto 0));
	end component;

begin
	x <= enout32 & enout16 & enout8;
	with x select
		e <= 	"111" when "111",	--enout is active-low
			"110" when "110",
			"100" when "101",
			"100" when "100",
			"000" when others;
	y <= writein32 & writein16 & writein8;
	with y select
		w <= 	"000" when "000",	--writein is active-high
			"001" when "001",
			"011" when "010",
			"011" when "011",
			"111" when others;
	register1: register8 port map (datain(7 downto 0), e(0), w(0), dataout(7 downto 0));
	register2: register8 port map (datain(15 downto 8), e(1), w(1), dataout(15 downto 8));
	register3: register8 port map (datain(23 downto 16), e(2), w(2), dataout(23 downto 16));
	register4: register8 port map (datain(31 downto 24), e(2), w(2), dataout(31 downto 24));
end architecture biggermem;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity adder_subtracter is
	port(	datain_a: in std_logic_vector(31 downto 0);
		datain_b: in std_logic_vector(31 downto 0);
		add_sub: in std_logic;
		dataout: out std_logic_vector(31 downto 0);
		co: out std_logic;
		overflow: out std_logic);
end entity adder_subtracter;

architecture calc of adder_subtracter is
	signal c: std_logic_vector(32 downto 1);
	signal data_b: std_logic_vector(31 downto 0);
	component fulladder is
		port (	a : in std_logic;
			b : in std_logic;
			cin : in std_logic;
			sum : out std_logic;
			carry : out std_logic
			);
	end component;

begin
	with add_sub select
		data_b <=	not(datain_b) when '1',	--'1' is sub
				datain_b when others;
	
	add_or_sub1: fulladder port map(datain_a(0), data_b(0), add_sub, dataout(0), c(1));
	gen: for i in 1 to 31 generate
		add_or_sub: fulladder port map(datain_a(i), data_b(i), c(i), dataout(i), c(i+1));
		co <= c(i+1);
	end generate gen;
	-- check overflow
	overflow <= c(16) xor c(15);
end architecture calc;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity shift_register is
	port(	datain: in std_logic_vector(31 downto 0);
	   	dir: in std_logic;		-- left if 0, right if 1
		shamt:	in std_logic_vector(4 downto 0);
		dataout: out std_logic_vector(31 downto 0));
end entity shift_register;

architecture shifter of shift_register is
	signal shift: std_logic_vector(5 downto 0);
	signal result: std_logic_vector(31 downto 0);
begin
	shift <= dir & shamt;
	with shift select
		result <=	datain(30 downto 0)&'0' when "000001",
				datain(29 downto 0)&"00" when "000010",
				datain(28 downto 0)&"000" when "000011",
				'0'&datain(31 downto 1) when "100001",
				"00"&datain(31 downto 2) when "100010",
				"000"&datain(31 downto 3) when "100011",
				datain(31 downto 0) when others;	
	dataout <= result;		
	
end architecture shifter;



