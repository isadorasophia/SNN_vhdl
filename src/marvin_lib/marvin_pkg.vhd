library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.fixed_pkg.all;

-- use super neural network library
library snn_lib;
use snn_lib.snn_pkg.all;

-- extra lib
library extra_lib;
use extra_lib.extra_pkg.all;

---------------------------------------------------------
-- marvin_pkg
--   main controller for our neural network
---------------------------------------------------------
package marvin_pkg is
	-- Marvin
	component marvin is
		generic (
				A_SIZE_in   : natural := 2;								-- size of layers
				A_SIZE_HID  : natural := 2;
				A_SIZE_OUT  : natural := 1;
				DEC_SIZE  	: natural := 8;								-- operands size
				FRAC_SIZE 	: natural := 8
			);
		PORT (
			clear,																							 -- clear weights
			run,																							 -- set neural network to run!
			to_learn,																						 -- starting learning
			clock			: in  STD_LOGIC;																 -- clock rate
			input			: in  std_logic_vector (3 DOWNTO 0);											 -- input, currently 2 bits
			output			: out std_logic;																 -- output, currently 1 bit
			states 			: out std_logic;																 -- state machine
			stages			: out std_logic;																 -- if it is whether getting input from database or from user
			out_ff			: out sfixed(DEC_SIZE -1 downto -FRAC_SIZE);									 -- debug signal, ignore
			current_weights_hid_o 		: out fixed_array(A_SIZE_in*A_SIZE_HID + A_SIZE_HID - 1 downto 0);	 -- weights from hidden layer
			current_weights_out_o 		: out fixed_array(A_SIZE_HID*A_SIZE_OUT + A_SIZE_OUT-1 downto 0)	 -- weights from out layer
		);
	end component;
end package;