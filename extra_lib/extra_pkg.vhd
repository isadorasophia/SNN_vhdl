library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.fixed_pkg.all;

---------------------------------------------------------
-- extra_pkg
--   responsible for minor implementations regarding functionality
---------------------------------------------------------
package extra_pkg is
	---------------------------------------------------------
	-- Declare default decimals and fractions for array
	--   dec:  max size of decimal, with total value of 2^dec
	--   frac: precision, aka number of decimals
	----------------------------------------------------------
	constant dec    : natural := 8;
	constant frac   : natural := 8;
	
	subtype fixed_no is sfixed(dec - 1 downto -frac);
	type fixed_array is array(natural range <>) of fixed_no;
	
	-- sigmoid operations
	component sigmoid is
		port (
			i: in  sfixed(dec - 1 downto -frac);
			o: out sfixed(dec - 1 downto -frac)
		);
	end component;
	
	-- derivative of sigmoid
	component d_sigmoid is
		port (
			i: in  sfixed(dec - 1 downto -frac);
			o: out sfixed(dec - 1 downto -frac)
		);
	end component;
	
---------------------------------------------------
-- some helper components
---------------------------------------------------
	component divisor_clk is
		generic (T : integer := 10000);
		port (clk_in     : in std_logic;
			  clk_out    : out std_logic);
	end component;
	
	component randomizer is
		generic (N : integer := 8);
		port (
			clk    	   		: in std_logic;						 -- clock
			n_seed 			: in std_logic_vector(N-1 downto 0);
			random_fixed    : out sfixed(dec-1 downto -frac));	 -- random number
	end component;
	
	component sram_controller is
		port(
			write_enable	: in std_logic;								-- write enable given from user
			wr_addr			: in std_logic_vector(17 downto 0);			-- read/write address given from user (18 bits/ 256kB)
			data_in			: in std_logic_vector(15 downto 0);			-- data in from the user (16 bits/2 bytes)
			data_out		: out std_logic_vector(15 downto 0);		-- data out to the user (16 bits/2 bytes)
			
			SRAM_ADDR		: out std_logic_vector(17 downto 0);		-- address to give to srdam to read/write data
			SRAM_DQ			: inout std_logic_vector(15 downto 0);		-- data to receive/give from sram to read/write
			SRAM_CE_N		: out std_logic;							-- chip enable (always active)
			SRAM_OE_N		: out std_logic;							-- output enable
			SRAM_WE_N		: out std_logic;							-- write enable
			SRAM_UB_N		: out std_logic;							-- high byte data mask (always active)
			SRAM_LB_N		: out std_logic								-- low byte data mask (always active)
		);
	end component;
	
	component fixed_alu is
		generic (
			DEC_SIZE : NATURAL  := 8;								-- size of the operands
			FRAC_SIZE : NATURAL := 8	
		);
		port (
			op : in std_logic_vector(2 downto 0);					-- operation to do
			A, B : in sfixed(DEC_SIZE-1 downto -FRAC_SIZE);			-- operands
			result : out sfixed(DEC_SIZE-1 downto -FRAC_SIZE)		-- result
			);
	end component;
	
	component OutputDriver is
		port (    
			CLOCK_27         : in std_logic;
			KEY			     : in std_logic_vector (3 downto 0 );
			tela             : in std_logic_vector(179 downto 0);
			peca             : in std_logic_vector(2 downto 0);
			red, green, blue : out std_logic_vector(3 downto 0);
			hsync, vsync     : out std_logic
			);
	end component;
	
	component vgacon is
	    generic (
			--  When changing this, remember to keep 4:3 aspect ratio
			--  Must also keep in mind that our native resolution is 640x480, and
			--  you can't cross these bounds (although you will seldom have enough
			--  on-chip memory to instantiate this module with higher res).
			NUM_HORZ_PIXELS : natural := 40;  -- Number of horizontal pixels
			NUM_VERT_PIXELS : natural := 30);  -- Number of vertical pixels
	  
	    port (
			CLOCK_27, rstn              : in  std_logic;
			write_clk, write_enable   : in  std_logic;
			write_addr                : in  integer range 0 to NUM_HORZ_PIXELS * NUM_VERT_PIXELS - 1;
			data_in                   : in  std_logic_vector(2 downto 0);
			vga_clk                   : buffer std_logic;       -- Ideally 34.96 MHz
			red, green, blue          : out std_logic_vector(3 downto 0);
			hsync, vsync              : out std_logic);
	end component;
	
end package;