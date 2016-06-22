-------------------------------------------------------------------------------
-- Title      : upper_delta
-- Project    : SNN
-------------------------------------------------------------------------------
-- File       : upper_delta.vhd
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

entity upper_delta is
	port (
		a 		: in sfixed(dec - 1 downto -frac); -- activation value
		d   	: in sfixed(dec - 1 downto -frac); -- delta
		upper_d : out sfixed(dec - 1 downto -frac) -- output
	);
end upper_delta;

architecture backpropagation of upper_delta is
	constant a_mult : std_logic_vector(2 downto 0) := "010"; -- alu code for MULT
	
    signal   lr     : sfixed(dec - 1 downto -frac); -- learning rate (multiplied by minus)
	signal   p_d    : sfixed(dec - 1 downto -frac); -- partial delta
begin
	----------------------------------------------------------
	-- Backpropagation, upper delta calculation!
	----------------------------------------------------------
	----
	-- get the final value!
	final: fixed_alu generic map (DEC_SIZE  => dec,
								  FRAC_SIZE => frac)
					 port map (op => a_mult, A => a, B => d, result => upper_d);
end backpropagation;
