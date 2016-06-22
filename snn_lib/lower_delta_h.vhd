-------------------------------------------------------------------------------
-- Title      : lower_delta_h
-- Project    : SNN
-------------------------------------------------------------------------------
-- File       : lower_delta_h.vhd
-- Author     : Isadora Sophia e Matheus Diamantino
-- Company    : Unicamp!
-- Created    : 2016-06-11
-- Last update: 2016-06-11
-- Platform   : Cyclone II
-- Standard   : VHDL'2008
-------------------------------------------------------------------------------
-- Description: Component that makes operations regarding backpropagation.
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  							Description
-- 2016-06-11  1.0      Isadora Sophia e Matheus Diamantino	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.fixed_pkg.all;

library extra_lib;
use extra_lib.extra_pkg.all;

entity lower_delta_h is
	generic (
		out_size : natural := 1 			     	-- total of output neurons
	);
	port (
		d : in  fixed_array(out_size - 1 downto 0); -- lower delta from output
		w : in  fixed_array(out_size - 1 downto 0); -- weights i (from all neurons)
		z : in  sfixed(dec - 1 downto -frac);	    -- z value to be applied sig'
		a : out sfixed(dec - 1 downto -frac)	    -- output, aka. activation value from layer 2
	);
end lower_delta_h;

architecture backpropagation of lower_delta_h is
	constant a_add  : std_logic_vector(2 downto 0) := "000"; -- alu code for ADD
	constant a_mult : std_logic_vector(2 downto 0) := "010"; -- alu code for MULT
	
    signal   mul_r : fixed_array(out_size - 1 downto 0);
	signal   total : fixed_array(out_size - 1 downto 0);

	signal   d_sig : sfixed(dec - 1 downto -frac);
begin
	----------------------------------------------------------
	-- Backpropagation
	----------------------------------------------------------
	----
	-- apply first iteration, ie.
	--   total := w(0) * delta_out(0);
	first_mul: fixed_alu generic map (DEC_SIZE  => dec, 
							 	      FRAC_SIZE => frac)
			    	     port map (op => a_mult, A => d(0), B => w(0), result => mul_r(0));

	total(0) <= mul_r(0);

	-----
	-- for each of the delta values
	--   total := total + w(i) * delta_out(i)
	-- 
	-- w is the weight j, ie. from input j (previous layer), in each of the neurons 
	-- lower_delta_h is the delta i, ie. from neuron i (current layer)
	each_delta: for i in 1 to out_size - 1 generate
		mul: fixed_alu generic map (DEC_SIZE  => dec, 
									FRAC_SIZE => frac)
					   port map (op => a_mult, A => d(i), B => w(i), result => mul_r(i));
		add: fixed_alu generic map (DEC_SIZE  => dec, 
									FRAC_SIZE => frac)
					   port map (op => a_add, A => mul_r(i), B => total(i - 1), result => total(i));
	end generate;
	
	----
	-- finally, apply the derivative of sigmoid
	sig: d_sigmoid port map (i => z, o => d_sig);
	
	----
	-- multiply it to the final result
	--   d := total * d_sig(z)
	mul_d: fixed_alu generic map (DEC_SIZE  => dec,
								  FRAC_SIZE => frac)
					 port map (op => a_mult, A => total(out_size - 1), B => d_sig, result => a);
end backpropagation;
