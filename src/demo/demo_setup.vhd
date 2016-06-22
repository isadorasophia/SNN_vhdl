library ieee;
use ieee.std_logic_1164.all;

library work;
use work.fixed_pkg.all;

-- marvin lib!
library marvin_lib;
use marvin_lib.marvin_pkg.all;

-- extra components lib!
library extra_lib;
use extra_lib.extra_pkg.all;

-------------------------------------------------------
-- Setup of the Marvin and SNN modules
--	 link components to Cyclone II by pin assignment
-------------------------------------------------------
entity demo_setup is
	generic (
				A_SIZE_in   : natural := 2;								-- size of layers
				A_SIZE_HID  : natural := 2;
				A_SIZE_OUT  : natural := 1;
				DEC_SIZE  	: natural := 8;								-- operands size
				FRAC_SIZE 	: natural := 8
			);
	port(SW: in std_logic_vector(9 downto 0);
		 KEY: in std_logic_vector(3 downto 0);
		 CLOCK_27: in std_logic_vector(1 downto 0);
		 CLOCK_50: in std_logic;
		 CLOCK_24: in std_logic;
		 EXT_CLOCK: in std_logic;
		 LEDR: out std_logic_vector(0 to 9);
		 LEDG: out std_logic_vector(0 to 7);
		 HEX0: out std_logic_vector(0 to 6);
		 HEX1: out std_logic_vector(0 to 6);
		 HEX2: out std_logic_vector(0 to 6);
		 HEX3: out std_logic_vector(0 to 6);
		--tela             : in std_logic_vector(179 downto 0);
		--peca             : in std_logic_vector(2 downto 0);
		red, green, blue : out std_logic_vector(3 downto 0);
		hsync, vsync     : out std_logic
		 );
end demo_setup;

architecture dec of demo_setup is
	signal a : fixed_array(1 downto 0);
	signal w_hid : fixed_array(5 downto 0);
	signal w_out : fixed_array(2 downto 0);
	
	--subtype temp is std_logic_vector(output'length - 1 downto 0); -- in order to convert sfixed to std_logic_vector
	
	signal clk : std_logic;
	
	signal current_weights_hid_o 		:  fixed_array(A_SIZE_in*A_SIZE_HID + A_SIZE_HID - 1 downto 0);
	signal current_weights_out_o 		:  fixed_array(A_SIZE_HID*A_SIZE_OUT + A_SIZE_OUT-1 downto 0);
	
	subtype temp is std_logic_vector(10 - 1 downto 0); -- in order to convert sfixed to std_logic_vector
	signal t_o : temp;
	signal tela : std_logic_vector(179 downto 0);
	signal output : std_logic;
begin
	-- instantiate network!
	network: marvin port map(
									clear => SW(5),
									run => SW(4),
									to_learn => SW(9),
									clock => clk,
									input => SW(3) & SW(2) & SW(1) & SW(0),
									output => output,
									states => LEDR(1),
									stages => LEDR(2),
									current_weights_hid_o => current_weights_hid_o,
									current_weights_out_o => current_weights_out_o
									);
	
	-- set clock rate
	divisor: divisor_clk port map (CLOCK_50, clk);
	
	vga: OutputDriver port map (
									CLOCK_27	=> CLOCK_27(0),
									KEY			=> KEY,
									tela  		=> tela,
									peca        => "00" & output,
									red   		=> red,
									green 		=> green,
									blue  		=> blue,
									hsync 		=> hsync,
									vsync 		=> vsync
									);
									
	tela (179 downto 170) <= temp(current_weights_hid_o(0)(4 downto -5));
	tela (169 downto 160) <= temp(current_weights_hid_o(1)(4 downto -5));
	tela (159 downto 150) <= temp(current_weights_hid_o(2)(4 downto -5));
	tela (149 downto 140) <= temp(current_weights_hid_o(3)(4 downto -5));
	tela (139 downto 130) <= temp(current_weights_hid_o(4)(4 downto -5));
	tela (129 downto 120) <= temp(current_weights_hid_o(5)(4 downto -5));
	
	tela (59 downto 50) <= temp(current_weights_out_o(0)(4 downto -5));
	tela (49 downto 40) <= temp(current_weights_out_o(1)(4 downto -5));
	tela (39 downto 30) <= temp(current_weights_out_o(2)(4 downto -5));
	
	LEDR(0) <= output;
	
end dec;
		
		