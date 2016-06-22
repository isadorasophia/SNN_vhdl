-------------------------------------------------------------------------------
-- Title      : new_weight
-- Project    : SNN
-------------------------------------------------------------------------------
-- File       : new_weight.vhd
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

entity new_weight is
	port (
		delta     : in sfixed(dec - 1 downto -frac); -- delta
		lambda    : in sfixed(dec - 1 downto -frac); -- learning rate
		old_w     : in sfixed(dec - 1 downto -frac); -- old weight
		new_w 	  : out sfixed(dec - 1 downto -frac) -- output
	);
end new_weight;

architecture backpropagation of new_weight is
	constant a_add  : std_logic_vector(2 downto 0) := "000"; -- alu code for ADD
	constant a_mult : std_logic_vector(2 downto 0) := "010"; -- alu code for MULT
	
    signal   lr     : sfixed(dec - 1 downto -frac); -- learning rate (multiplied by minus)
	signal   d_w    : sfixed(dec - 1 downto -frac); -- delta weight
begin
	----------------------------------------------------------
	-- Backpropagation, upper delta calculation!
	----------------------------------------------------------
	----
	-- apply minus signal to lambda
	--   total := -lambda 
	lambda_mul: fixed_alu generic map (DEC_SIZE  => dec, 
							 	       FRAC_SIZE => frac)
			    	      port map (op => a_mult, A => lambda, B => to_sfixed(-1.0, lambda), result => lr);
	
	----
	-- get delta weight
	final: fixed_alu generic map (DEC_SIZE  => dec,
								  FRAC_SIZE => frac)
					 port map (op => a_mult, A => lr, B => delta, result => d_w);

	----
	-- finally, get the final value!
	final_value: fixed_alu generic map (DEC_SIZE  => dec, 
							 	       FRAC_SIZE => frac)
			    	      port map (op => a_add, A => old_w, B => d_w, result => new_w);
end backpropagation;
