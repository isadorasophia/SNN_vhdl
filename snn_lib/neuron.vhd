-------------------------------------------------------------------------------
-- Title      : neuron
-- Project    : SNN
-------------------------------------------------------------------------------
-- File       : neuron.vhd
-- Author     : Isadora Sophia e Matheus Diamantino
-- Company    : Unicamp!
-- Created    : 2016-06-11
-- Last update: 2016-06-11
-- Platform   : Cyclone II
-- Standard   : VHDL'2008
-------------------------------------------------------------------------------
-- Description: Neuron component that make operations regarding feedforward.
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

entity neuron is
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
end neuron;

architecture feedforward of neuron is
	constant a_add   : std_logic_vector(2 downto 0) := "000"; -- alu code for ADD
	constant a_mult  : std_logic_vector(2 downto 0) := "010"; -- alu code for MULT
	
    signal   mul_r : fixed_array(A_SIZE downto 1);
	signal   total : fixed_array(A_SIZE downto 0);
begin
	----------------------------------------------------------
	-- Feedforward
	----------------------------------------------------------
	-- apply bias value, which is w(0) times 1;
	-- proceed by adding it to its total(0)
	total(0) <= w(0);
	
	-- get each of the values, as a(i) * w(i)
	-- add it to its total(i), by adding total(i - 1)	   
	apply: for i in 1 to A_SIZE generate
		op:  fixed_alu generic map (DEC_SIZE  => DEC_SIZE, 
								    FRAC_SIZE => FRAC_SIZE)
					   port map (op => a_mult, A => a(i), B => w(i), result => mul_r(i));
		add: fixed_alu generic map (DEC_SIZE  => DEC_SIZE, 
								    FRAC_SIZE => FRAC_SIZE)
					   port map (op => a_add, A => mul_r(i), B => total(i - 1), result => total(i));
	end generate;
	
	-- apply sigmoid to our sum and direct it to the output
	sigmoid_c: sigmoid port map (i => total(A_SIZE) , o => f);
	
	-- now get z value, which is the total sum
	z <= total(A_SIZE);
end feedforward;
