-------------------------------------------------------------------------------
-- Title      : Learning Network
-- Project    : SNN
-------------------------------------------------------------------------------
-- File       : learning_network.vhd
-- Author     : Isadora Sophia e Matheus Diamantino
-- Company    : Unicamp!
-- Created    : 2016-06-11
-- Last update: 2016-06-11
-- Platform   : Cyclone II
-- Standard   : VHDL'2008
-------------------------------------------------------------------------------
-- Description: Learning Network component that make operations regarding Back Propagation.
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

library extra_lib;
use extra_lib.extra_pkg.all;

use work.snn_pkg.all;

entity snn_learn is
	generic (
		A_SIZE_IN   : NATURAL := 2;								-- size of layers
		A_SIZE_HID  : NATURAL := 2;
		A_SIZE_OUT  : NATURAL := 1;
		DEC_SIZE  	: NATURAL := 8;								-- operands size
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
end snn_learn;

architecture backpropagation of snn_learn is

	signal lower_delta_out : fixed_array(A_SIZE_OUT-1 downto 0);
	signal lower_delta_hid : fixed_array(A_SIZE_HID-1 downto 0);

	signal upper_delta_out : fixed_array(A_SIZE_HID*A_SIZE_OUT + A_SIZE_OUT-1  downto 0);
	signal upper_delta_hid : fixed_array(A_SIZE_IN*A_SIZE_HID + A_SIZE_HID - 1  downto 0);

	signal act_in			:  fixed_array(A_SIZE_IN downto 0);
	signal act_hid			:  fixed_array(A_SIZE_HID downto 0);

begin

	act_in <= input & to_sfixed(1.0, dec-1, -frac);
	act_hid <= a_hid & to_sfixed(1.0, dec-1, -frac);

	ud_out <= upper_delta_out;
	ud_hid <= upper_delta_hid;


	----------------------------------------------------------
	-- Backpropagation
	----------------------------------------------------------

	lower_delta_output: for i in 0 to A_SIZE_OUT-1 generate

		deltineo_da_saida: lower_delta_o port map (
														a => generated_output(i),
														y => correct_output(i),
														d => lower_delta_out(i)
														);

	end generate;

	lower_delta_hidden: for i in 1 to A_SIZE_HID generate

		deltineo: lower_delta_h generic map (out_size => A_SIZE_OUT) port map (
																			d => lower_delta_out,
																			w => w_out(i downto i),
																			z => z(i-1),
																			a => lower_delta_hid(i-1)
																			);

	end generate;


	upper_delta_out_1: for i in 0 to A_SIZE_HID generate

		upper_delta_out_2: for f in 0 to A_SIZE_OUT-1 generate
			delta: upper_delta port map (d => lower_delta_out(f),
										 a => act_hid(i),
										 upper_d => upper_delta_out(i*A_SIZE_OUT + f)
										 );
		end generate;

	end generate;

	upper_delta_hid_1: for i in 0 to A_SIZE_IN generate

		upper_delta_hid_2: for f in 0 to A_SIZE_HID-1 generate
			delta: upper_delta port map (d => lower_delta_hid(f),
										 a => act_in(i),
										 upper_d => upper_delta_hid(i*A_SIZE_HID + f)
										 );
		end generate;

	end generate;

	
	-- final result of feedforward
	-- output <= neurons_output(0);
end backpropagation;
