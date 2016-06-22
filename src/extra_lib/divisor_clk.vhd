library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity divisor_clk is
	generic (T : integer := 10);
	port (clk_in     : in std_logic;
		  clk_out    : out std_logic);
end divisor_clk;

architecture mauricio of divisor_clk is
signal clk_t : std_logic;
signal count : std_logic_vector(23 downto 0);  
begin
	-- toggle clk_out every 12.5MHz
	process(clk_in)
	begin
		if rising_edge(clk_in) then
			count <= count + 1;
			
			if count = T then
				clk_t <= not clk_t;
				
				-- good job, start over!
				count <= (others => '0');
			end if;
		end if;
	end process;
	
	-- assign output
	clk_out <= clk_t;
end mauricio;