-------------------------------------------------------------------------------
-- Title      : lower_delta_output
-- Project    : SNN
-------------------------------------------------------------------------------
-- File       : lower_delta_output.vhd
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

entity lower_delta_o is
	port (    
		a: in sfixed(dec - 1 downto -frac);  -- generated output, by the network
		y: in sfixed(dec - 1 downto -frac);  -- correct output
		d: out sfixed(dec - 1 downto -frac)  -- final lower delta
	);
end lower_delta_o;

architecture backpropagation of lower_delta_o is
	constant a_sub   : std_logic_vector(2 downto 0) := "001"; -- alu code for SUB
begin
	----------------------------------------------------------
	-- Backpropagation
	----------------------------------------------------------
	-- apply delta(output) value according to current values,
	-- which is simply d = a - y
	sub: fixed_alu generic map (DEC_SIZE => dec, 
								FRAC_SIZE => frac)
			       port map (op => a_sub, A => a, B => y, result => d);
end backpropagation;
