library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.fixed_pkg.all;

-- our own lib
use work.extra_pkg.all;

entity randomizer is
		generic (N : integer := 8);
	port (
		clk    	   		: in std_logic;						-- clock
		n_seed 			: in std_logic_vector(N-1 downto 0);
		random_fixed    : out sfixed(dec-1 downto -frac));			-- random number
end randomizer;

architecture Zorg of randomizer is
	signal seed   	   : std_logic_vector(N - 1 downto 0) := n_seed;		-- seed to be manipulated
	signal tmp         : std_logic := '0';									-- helper variable
	signal random      : std_logic_vector(N-1 downto 0);
begin
	process (clk)
	begin
		if rising_edge(clk) then
			-- make xnor between two random given values
			tmp <= seed(N - 1) xnor seed((N - 1)/2);
			
			seed(N - 1 downto 1) <= seed (N - 2 downto 0);
			seed(0) <= tmp;
		end if;	
		
		random <= seed;
	end process;

	random_fixed <= to_sfixed( ((dec + frac - N - 1) downto 0 => '0') & random, random_fixed'high, random_fixed'low);
end Zorg;