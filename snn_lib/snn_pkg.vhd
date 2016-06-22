library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.fixed_pkg.all;

-- use extra library
library extra_lib;
use extra_lib.extra_pkg.all;

package snn_pkg is
	-- define learning rate
	constant lambda : sfixed(dec - 1 downto -frac) := to_sfixed(0.05, dec - 1, -frac);
	
	-- Super Neural Network
	component snn is
		generic (
			A_SIZE_IN   : NATURAL := 2;								-- size of layers
			A_SIZE_HID  : NATURAL := 2;
			A_SIZE_OUT  : NATURAL := 1;
			DEC_SIZE  	: NATURAL := 8;								-- operands size
			FRAC_SIZE 	: NATURAL := 8
		);
		port (    
			a 			: in fixed_array(A_SIZE_IN downto 1); -- inputs, without bias unit!
			w_hid 		: in fixed_array(A_SIZE_IN*A_SIZE_HID + A_SIZE_HID - 1 downto 0); -- total weights for the hidden and output layers, + bias unit!
			w_out 		: in fixed_array(A_SIZE_HID*A_SIZE_OUT + A_SIZE_OUT-1 downto 0); 
			output 		: out sfixed(DEC_SIZE - 1 downto -FRAC_SIZE); -- result!
			neurons_h 	: out fixed_array(A_SIZE_HID-1 downto 0);
			neurons_h_z : out fixed_array(A_SIZE_HID-1 downto 0);
			neurons_o_z : out fixed_array(A_SIZE_OUT-1 downto 0)
		);
	end component;
	
	-- Super Neural Network trainer!
	component snn_learn is
		generic (
			A_SIZE_IN   : NATURAL := 2;	-- size of layers
			A_SIZE_HID  : NATURAL := 2;
			A_SIZE_OUT  : NATURAL := 1;
			DEC_SIZE  	: NATURAL := 8;	-- operands size
			FRAC_SIZE 	: NATURAL := 8
		);
		port (
			input			 	: in fixed_array(A_SIZE_IN-1 downto 0);
			generated_output 	: in fixed_array(A_SIZE_OUT-1 downto 0); -- generated output by feedforward
			correct_output 		: in fixed_array(A_SIZE_OUT-1 downto 0);
			z 					: in fixed_array(A_SIZE_HID-1 downto 0);
			a_hid				: in fixed_array(A_SIZE_HID downto 1);
			w_out 				: in fixed_array(A_SIZE_HID*A_SIZE_OUT + A_SIZE_OUT - 1 downto 0); 
			
			ud_out 				: out fixed_array(A_SIZE_HID*A_SIZE_OUT + A_SIZE_OUT - 1  downto 0);
			ud_hid 				: out fixed_array(A_SIZE_IN*A_SIZE_HID + A_SIZE_HID - 1  downto 0) -- result!
		);
	end component;
	
	-- Neuron
	component neuron is
		generic (
			A_SIZE    : NATURAL := 2;								-- size of activation values
			DEC_SIZE  : NATURAL := 8;								-- operands size
			FRAC_SIZE : NATURAL := 8
		);
		port (    
			a : fixed_array(A_SIZE downto 1); -- inputs, without bias unit!
			w : fixed_array(A_SIZE downto 0); -- total weights, + bias unit!
			f : out sfixed(DEC_SIZE - 1 downto -FRAC_SIZE);
			z : out sfixed(DEC_SIZE - 1 downto -FRAC_SIZE)
		);
	end component;
	
	----------------------------------------------------------
	-- Components necessary for neural network
	----------------------------------------------------------
	component lower_delta_h is
		generic (
			out_size : natural := 1 			     	-- total of output neurons
		);
		port (
			d : in  fixed_array(out_size - 1 downto 0); -- lower delta from output
			w : in  fixed_array(out_size - 1 downto 0); -- weights i (from all neurons)
			z : in  sfixed(dec - 1 downto -frac);	    -- z value to be applied sig'
			a : out sfixed(dec - 1 downto -frac)	    -- output, aka. activation value from layer 2
		);
	end component;
	
	component lower_delta_o is
		port (    
			a: in sfixed(dec - 1 downto -frac);  -- generated output, by the network
			y: in sfixed(dec - 1 downto -frac);  -- correct output
			d: out sfixed(dec - 1 downto -frac)  -- final lower delta
		);
	end component;
	
	component upper_delta is
		port (
			a 		: in sfixed(dec - 1 downto -frac); -- activation value
			d   	: in sfixed(dec - 1 downto -frac); -- delta
			upper_d : out sfixed(dec - 1 downto -frac) -- output
		);
	end component;
	
	component new_weight is
		port (
			delta     : in sfixed(dec - 1 downto -frac); -- delta
			lambda    : in sfixed(dec - 1 downto -frac); -- learning rate
			old_w     : in sfixed(dec - 1 downto -frac); -- old weight
			new_w 	  : out sfixed(dec - 1 downto -frac) -- output
		);
	end component;
end package snn_pkg;