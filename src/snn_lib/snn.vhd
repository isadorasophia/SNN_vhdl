-------------------------------------------------------------------------------
-- Title      : Network
-- Project    : SNN
-------------------------------------------------------------------------------
-- File       : network.vhd
-- Author     : Isadora Sophia e Matheus Diamantino
-- Company    : Unicamp!
-- Created    : 2016-06-11
-- Last update: 2016-06-11
-- Platform   : Cyclone II
-- Standard   : VHDL'2008
-------------------------------------------------------------------------------
-- Description: Network component that make operations regarding feedforward.
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  							Description
-- 2016-06-11  0.1      Isadora Sophia e Matheus Diamantino	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.fixed_pkg.all;

-- extra lib!
library extra_lib;
use extra_lib.extra_pkg.all;

-- snn lib!
use work.snn_pkg.all;

entity snn is
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
end snn;

architecture feedforward of snn is
	signal neurons_hidden : fixed_array(A_SIZE_HID-1 downto 0);		
	signal neurons_output : fixed_array(A_SIZE_OUT-1 downto 0);

	signal neurons_hidden_z : fixed_array(A_SIZE_HID-1 downto 0);		
	signal neurons_output_z : fixed_array(A_SIZE_OUT-1 downto 0);
begin


	----------------------------------------------------------
	-- Feedforward
	----------------------------------------------------------
	
	-- instantiate the hidden layer and the output layer   
	hidden_layer: for i in 0 to A_SIZE_HID-1 generate
		hidden:  neuron generic map (
									A_SIZE => A_SIZE_IN,
									DEC_SIZE  => DEC_SIZE, 
								    FRAC_SIZE => FRAC_SIZE)
					   port map (
					   				a => a, 
					   				w => w_hid((i+1) * A_SIZE_IN + 1*i downto i * (A_SIZE_IN+1)),
					   				f => neurons_hidden(i),
					   				z => neurons_hidden_z(i)
					   				);
	end generate;

	output_layer: for i in 0 to A_SIZE_OUT-1 generate
		output: neuron generic map (
										A_SIZE => A_SIZE_HID,
										DEC_SIZE  => DEC_SIZE, 
									    FRAC_SIZE => FRAC_SIZE)
						   port map (
						   				a => neurons_hidden, 
						   				w => w_out((i+1) * A_SIZE_HID + 1*i downto i * (A_SIZE_HID+1)), 
						   				f => neurons_output(i),
						   				z => neurons_output_z(i)
						   			);
	
	end generate;

	-- debug output
	neurons_h <= neurons_hidden;
	-- final result of feedforward
	output <= neurons_output(0);
	neurons_h_z <= neurons_hidden_z;
	neurons_o_z <= neurons_output_z;
end feedforward;
