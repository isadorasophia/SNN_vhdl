-------------------------------------------------------------------------------
-- Title      : sigmoid derivative
-- Project    : SNN
-------------------------------------------------------------------------------
-- File       : d_sigmoid.vhd
-- Author     : Isadora Sophia e Matheus Diamantino
-- Company    : Unicamp!
-- Created    : 2016-06-11
-- Last update: 2016-06-11
-- Platform   : Cyclone II
-- Standard   : VHDL'2008
-------------------------------------------------------------------------------
-- Description: Sigmoid derivative function (f(1-f)), implemented with a lookup table
-------------------------------------------------------------------------------
-- Copyright (c) 2016
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  							Description
-- 2016-06-11  0.1      Isadora Sophia e Matheus Diamantino	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- fixed point lib
library work;
use work.fixed_pkg.all;

-- our own lib
use work.extra_pkg.all;

entity d_sigmoid is
    port (
		i: in  sfixed(dec - 1 downto -frac);
		o: out sfixed(dec - 1 downto -frac)
	);
end d_sigmoid;

architecture lut of d_sigmoid is
	subtype temp is std_logic_vector(i'length - 1 downto 0); -- in order to convert sfixed to std_logic_vector
	signal t_i, t_o : temp;
begin
	-- convert input to std_logic
	t_i <= temp(i);
	
	-- convert output back to sfixed
	o <= to_sfixed(t_o, o'high, o'low);
	
	-- lookup table
	t_o <=
		"0000000000000000" when to_integer(signed(t_i(i'length - 1 downto 3))) > 176 else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010110000" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010101111" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010101110" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010101101" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010101100" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010101011" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010101010" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010101001" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010101000" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010100111" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010100110" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010100101" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010100100" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010100011" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010100010" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010100001" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010100000" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010011111" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010011110" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010011101" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010011100" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010011011" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "0000010011010" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "0000010011001" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "0000010011000" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "0000010010111" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "0000010010110" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "0000010010101" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "0000010010100" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "0000010010011" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "0000010010010" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "0000010010001" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "0000010010000" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "0000010001111" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "0000010001110" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "0000010001101" else
		"0000000000000011" when t_i(i'length - 1 downto 3) = "0000010001100" else
		"0000000000000011" when t_i(i'length - 1 downto 3) = "0000010001011" else
		"0000000000000011" when t_i(i'length - 1 downto 3) = "0000010001010" else
		"0000000000000011" when t_i(i'length - 1 downto 3) = "0000010001001" else
		"0000000000000011" when t_i(i'length - 1 downto 3) = "0000010001000" else
		"0000000000000011" when t_i(i'length - 1 downto 3) = "0000010000111" else
		"0000000000000011" when t_i(i'length - 1 downto 3) = "0000010000110" else
		"0000000000000011" when t_i(i'length - 1 downto 3) = "0000010000101" else
		"0000000000000011" when t_i(i'length - 1 downto 3) = "0000010000100" else
		"0000000000000100" when t_i(i'length - 1 downto 3) = "0000010000011" else
		"0000000000000100" when t_i(i'length - 1 downto 3) = "0000010000010" else
		"0000000000000100" when t_i(i'length - 1 downto 3) = "0000010000001" else
		"0000000000000100" when t_i(i'length - 1 downto 3) = "0000010000000" else
		"0000000000000100" when t_i(i'length - 1 downto 3) = "0000001111111" else
		"0000000000000100" when t_i(i'length - 1 downto 3) = "0000001111110" else
		"0000000000000100" when t_i(i'length - 1 downto 3) = "0000001111101" else
		"0000000000000100" when t_i(i'length - 1 downto 3) = "0000001111100" else
		"0000000000000101" when t_i(i'length - 1 downto 3) = "0000001111011" else
		"0000000000000101" when t_i(i'length - 1 downto 3) = "0000001111010" else
		"0000000000000101" when t_i(i'length - 1 downto 3) = "0000001111001" else
		"0000000000000101" when t_i(i'length - 1 downto 3) = "0000001111000" else
		"0000000000000101" when t_i(i'length - 1 downto 3) = "0000001110111" else
		"0000000000000101" when t_i(i'length - 1 downto 3) = "0000001110110" else
		"0000000000000110" when t_i(i'length - 1 downto 3) = "0000001110101" else
		"0000000000000110" when t_i(i'length - 1 downto 3) = "0000001110100" else
		"0000000000000110" when t_i(i'length - 1 downto 3) = "0000001110011" else
		"0000000000000110" when t_i(i'length - 1 downto 3) = "0000001110010" else
		"0000000000000110" when t_i(i'length - 1 downto 3) = "0000001110001" else
		"0000000000000111" when t_i(i'length - 1 downto 3) = "0000001110000" else
		"0000000000000111" when t_i(i'length - 1 downto 3) = "0000001101111" else
		"0000000000000111" when t_i(i'length - 1 downto 3) = "0000001101110" else
		"0000000000000111" when t_i(i'length - 1 downto 3) = "0000001101101" else
		"0000000000000111" when t_i(i'length - 1 downto 3) = "0000001101100" else
		"0000000000001000" when t_i(i'length - 1 downto 3) = "0000001101011" else
		"0000000000001000" when t_i(i'length - 1 downto 3) = "0000001101010" else
		"0000000000001000" when t_i(i'length - 1 downto 3) = "0000001101001" else
		"0000000000001000" when t_i(i'length - 1 downto 3) = "0000001101000" else
		"0000000000001001" when t_i(i'length - 1 downto 3) = "0000001100111" else
		"0000000000001001" when t_i(i'length - 1 downto 3) = "0000001100110" else
		"0000000000001001" when t_i(i'length - 1 downto 3) = "0000001100101" else
		"0000000000001010" when t_i(i'length - 1 downto 3) = "0000001100100" else
		"0000000000001010" when t_i(i'length - 1 downto 3) = "0000001100011" else
		"0000000000001010" when t_i(i'length - 1 downto 3) = "0000001100010" else
		"0000000000001010" when t_i(i'length - 1 downto 3) = "0000001100001" else
		"0000000000001011" when t_i(i'length - 1 downto 3) = "0000001100000" else
		"0000000000001011" when t_i(i'length - 1 downto 3) = "0000001011111" else
		"0000000000001011" when t_i(i'length - 1 downto 3) = "0000001011110" else
		"0000000000001100" when t_i(i'length - 1 downto 3) = "0000001011101" else
		"0000000000001100" when t_i(i'length - 1 downto 3) = "0000001011100" else
		"0000000000001100" when t_i(i'length - 1 downto 3) = "0000001011011" else
		"0000000000001101" when t_i(i'length - 1 downto 3) = "0000001011010" else
		"0000000000001101" when t_i(i'length - 1 downto 3) = "0000001011001" else
		"0000000000001110" when t_i(i'length - 1 downto 3) = "0000001011000" else
		"0000000000001110" when t_i(i'length - 1 downto 3) = "0000001010111" else
		"0000000000001110" when t_i(i'length - 1 downto 3) = "0000001010110" else
		"0000000000001111" when t_i(i'length - 1 downto 3) = "0000001010101" else
		"0000000000001111" when t_i(i'length - 1 downto 3) = "0000001010100" else
		"0000000000010000" when t_i(i'length - 1 downto 3) = "0000001010011" else
		"0000000000010000" when t_i(i'length - 1 downto 3) = "0000001010010" else
		"0000000000010001" when t_i(i'length - 1 downto 3) = "0000001010001" else
		"0000000000010001" when t_i(i'length - 1 downto 3) = "0000001010000" else
		"0000000000010010" when t_i(i'length - 1 downto 3) = "0000001001111" else
		"0000000000010010" when t_i(i'length - 1 downto 3) = "0000001001110" else
		"0000000000010010" when t_i(i'length - 1 downto 3) = "0000001001101" else
		"0000000000010011" when t_i(i'length - 1 downto 3) = "0000001001100" else
		"0000000000010011" when t_i(i'length - 1 downto 3) = "0000001001011" else
		"0000000000010100" when t_i(i'length - 1 downto 3) = "0000001001010" else
		"0000000000010101" when t_i(i'length - 1 downto 3) = "0000001001001" else
		"0000000000010101" when t_i(i'length - 1 downto 3) = "0000001001000" else
		"0000000000010110" when t_i(i'length - 1 downto 3) = "0000001000111" else
		"0000000000010110" when t_i(i'length - 1 downto 3) = "0000001000110" else
		"0000000000010111" when t_i(i'length - 1 downto 3) = "0000001000101" else
		"0000000000010111" when t_i(i'length - 1 downto 3) = "0000001000100" else
		"0000000000011000" when t_i(i'length - 1 downto 3) = "0000001000011" else
		"0000000000011001" when t_i(i'length - 1 downto 3) = "0000001000010" else
		"0000000000011001" when t_i(i'length - 1 downto 3) = "0000001000001" else
		"0000000000011010" when t_i(i'length - 1 downto 3) = "0000001000000" else
		"0000000000011010" when t_i(i'length - 1 downto 3) = "0000000111111" else
		"0000000000011011" when t_i(i'length - 1 downto 3) = "0000000111110" else
		"0000000000011100" when t_i(i'length - 1 downto 3) = "0000000111101" else
		"0000000000011100" when t_i(i'length - 1 downto 3) = "0000000111100" else
		"0000000000011101" when t_i(i'length - 1 downto 3) = "0000000111011" else
		"0000000000011110" when t_i(i'length - 1 downto 3) = "0000000111010" else
		"0000000000011110" when t_i(i'length - 1 downto 3) = "0000000111001" else
		"0000000000011111" when t_i(i'length - 1 downto 3) = "0000000111000" else
		"0000000000100000" when t_i(i'length - 1 downto 3) = "0000000110111" else
		"0000000000100001" when t_i(i'length - 1 downto 3) = "0000000110110" else
		"0000000000100001" when t_i(i'length - 1 downto 3) = "0000000110101" else
		"0000000000100010" when t_i(i'length - 1 downto 3) = "0000000110100" else
		"0000000000100011" when t_i(i'length - 1 downto 3) = "0000000110011" else
		"0000000000100100" when t_i(i'length - 1 downto 3) = "0000000110010" else
		"0000000000100100" when t_i(i'length - 1 downto 3) = "0000000110001" else
		"0000000000100101" when t_i(i'length - 1 downto 3) = "0000000110000" else
		"0000000000100110" when t_i(i'length - 1 downto 3) = "0000000101111" else
		"0000000000100111" when t_i(i'length - 1 downto 3) = "0000000101110" else
		"0000000000100111" when t_i(i'length - 1 downto 3) = "0000000101101" else
		"0000000000101000" when t_i(i'length - 1 downto 3) = "0000000101100" else
		"0000000000101001" when t_i(i'length - 1 downto 3) = "0000000101011" else
		"0000000000101010" when t_i(i'length - 1 downto 3) = "0000000101010" else
		"0000000000101010" when t_i(i'length - 1 downto 3) = "0000000101001" else
		"0000000000101011" when t_i(i'length - 1 downto 3) = "0000000101000" else
		"0000000000101100" when t_i(i'length - 1 downto 3) = "0000000100111" else
		"0000000000101101" when t_i(i'length - 1 downto 3) = "0000000100110" else
		"0000000000101101" when t_i(i'length - 1 downto 3) = "0000000100101" else
		"0000000000101110" when t_i(i'length - 1 downto 3) = "0000000100100" else
		"0000000000101111" when t_i(i'length - 1 downto 3) = "0000000100011" else
		"0000000000110000" when t_i(i'length - 1 downto 3) = "0000000100010" else
		"0000000000110000" when t_i(i'length - 1 downto 3) = "0000000100001" else
		"0000000000110001" when t_i(i'length - 1 downto 3) = "0000000100000" else
		"0000000000110010" when t_i(i'length - 1 downto 3) = "0000000011111" else
		"0000000000110011" when t_i(i'length - 1 downto 3) = "0000000011110" else
		"0000000000110011" when t_i(i'length - 1 downto 3) = "0000000011101" else
		"0000000000110100" when t_i(i'length - 1 downto 3) = "0000000011100" else
		"0000000000110101" when t_i(i'length - 1 downto 3) = "0000000011011" else
		"0000000000110101" when t_i(i'length - 1 downto 3) = "0000000011010" else
		"0000000000110110" when t_i(i'length - 1 downto 3) = "0000000011001" else
		"0000000000110111" when t_i(i'length - 1 downto 3) = "0000000011000" else
		"0000000000110111" when t_i(i'length - 1 downto 3) = "0000000010111" else
		"0000000000111000" when t_i(i'length - 1 downto 3) = "0000000010110" else
		"0000000000111001" when t_i(i'length - 1 downto 3) = "0000000010101" else
		"0000000000111001" when t_i(i'length - 1 downto 3) = "0000000010100" else
		"0000000000111010" when t_i(i'length - 1 downto 3) = "0000000010011" else
		"0000000000111010" when t_i(i'length - 1 downto 3) = "0000000010010" else
		"0000000000111011" when t_i(i'length - 1 downto 3) = "0000000010001" else
		"0000000000111011" when t_i(i'length - 1 downto 3) = "0000000010000" else
		"0000000000111100" when t_i(i'length - 1 downto 3) = "0000000001111" else
		"0000000000111100" when t_i(i'length - 1 downto 3) = "0000000001110" else
		"0000000000111101" when t_i(i'length - 1 downto 3) = "0000000001101" else
		"0000000000111101" when t_i(i'length - 1 downto 3) = "0000000001100" else
		"0000000000111101" when t_i(i'length - 1 downto 3) = "0000000001011" else
		"0000000000111110" when t_i(i'length - 1 downto 3) = "0000000001010" else
		"0000000000111110" when t_i(i'length - 1 downto 3) = "0000000001001" else
		"0000000000111110" when t_i(i'length - 1 downto 3) = "0000000001000" else
		"0000000000111111" when t_i(i'length - 1 downto 3) = "0000000000111" else
		"0000000000111111" when t_i(i'length - 1 downto 3) = "0000000000110" else
		"0000000000111111" when t_i(i'length - 1 downto 3) = "0000000000101" else
		"0000000000111111" when t_i(i'length - 1 downto 3) = "0000000000100" else
		"0000000000111111" when t_i(i'length - 1 downto 3) = "0000000000011" else
		"0000000000111111" when t_i(i'length - 1 downto 3) = "0000000000010" else
		"0000000000111111" when t_i(i'length - 1 downto 3) = "0000000000001" else
		"0000000000111111" when t_i(i'length - 1 downto 3) = "0000000000000" else
		"0000000000111111" when t_i(i'length - 1 downto 3) = "1111111111111" else
		"0000000000111111" when t_i(i'length - 1 downto 3) = "1000000000000" else
		"0000000000111111" when t_i(i'length - 1 downto 3) = "1000000000001" else
		"0000000000111111" when t_i(i'length - 1 downto 3) = "1000000000010" else
		"0000000000111111" when t_i(i'length - 1 downto 3) = "1000000000011" else
		"0000000000111111" when t_i(i'length - 1 downto 3) = "1000000000100" else
		"0000000000111111" when t_i(i'length - 1 downto 3) = "1000000000101" else
		"0000000000111111" when t_i(i'length - 1 downto 3) = "1000000000110" else
		"0000000000111110" when t_i(i'length - 1 downto 3) = "1000000000111" else
		"0000000000111110" when t_i(i'length - 1 downto 3) = "1000000001000" else
		"0000000000111110" when t_i(i'length - 1 downto 3) = "1000000001001" else
		"0000000000111110" when t_i(i'length - 1 downto 3) = "1000000001010" else
		"0000000000111101" when t_i(i'length - 1 downto 3) = "1000000001011" else
		"0000000000111101" when t_i(i'length - 1 downto 3) = "1000000001100" else
		"0000000000111100" when t_i(i'length - 1 downto 3) = "1000000001101" else
		"0000000000111100" when t_i(i'length - 1 downto 3) = "1000000001110" else
		"0000000000111100" when t_i(i'length - 1 downto 3) = "1000000001111" else
		"0000000000111011" when t_i(i'length - 1 downto 3) = "1000000010000" else
		"0000000000111011" when t_i(i'length - 1 downto 3) = "1000000010001" else
		"0000000000111010" when t_i(i'length - 1 downto 3) = "1000000010010" else
		"0000000000111010" when t_i(i'length - 1 downto 3) = "1000000010011" else
		"0000000000111001" when t_i(i'length - 1 downto 3) = "1000000010100" else
		"0000000000111000" when t_i(i'length - 1 downto 3) = "1000000010101" else
		"0000000000111000" when t_i(i'length - 1 downto 3) = "1000000010110" else
		"0000000000110111" when t_i(i'length - 1 downto 3) = "1000000010111" else
		"0000000000110111" when t_i(i'length - 1 downto 3) = "1000000011000" else
		"0000000000110110" when t_i(i'length - 1 downto 3) = "1000000011001" else
		"0000000000110101" when t_i(i'length - 1 downto 3) = "1000000011010" else
		"0000000000110101" when t_i(i'length - 1 downto 3) = "1000000011011" else
		"0000000000110100" when t_i(i'length - 1 downto 3) = "1000000011100" else
		"0000000000110011" when t_i(i'length - 1 downto 3) = "1000000011101" else
		"0000000000110010" when t_i(i'length - 1 downto 3) = "1000000011110" else
		"0000000000110010" when t_i(i'length - 1 downto 3) = "1000000011111" else
		"0000000000110001" when t_i(i'length - 1 downto 3) = "1000000100000" else
		"0000000000110000" when t_i(i'length - 1 downto 3) = "1000000100001" else
		"0000000000110000" when t_i(i'length - 1 downto 3) = "1000000100010" else
		"0000000000101111" when t_i(i'length - 1 downto 3) = "1000000100011" else
		"0000000000101110" when t_i(i'length - 1 downto 3) = "1000000100100" else
		"0000000000101101" when t_i(i'length - 1 downto 3) = "1000000100101" else
		"0000000000101100" when t_i(i'length - 1 downto 3) = "1000000100110" else
		"0000000000101100" when t_i(i'length - 1 downto 3) = "1000000100111" else
		"0000000000101011" when t_i(i'length - 1 downto 3) = "1000000101000" else
		"0000000000101010" when t_i(i'length - 1 downto 3) = "1000000101001" else
		"0000000000101001" when t_i(i'length - 1 downto 3) = "1000000101010" else
		"0000000000101001" when t_i(i'length - 1 downto 3) = "1000000101011" else
		"0000000000101000" when t_i(i'length - 1 downto 3) = "1000000101100" else
		"0000000000100111" when t_i(i'length - 1 downto 3) = "1000000101101" else
		"0000000000100110" when t_i(i'length - 1 downto 3) = "1000000101110" else
		"0000000000100110" when t_i(i'length - 1 downto 3) = "1000000101111" else
		"0000000000100101" when t_i(i'length - 1 downto 3) = "1000000110000" else
		"0000000000100100" when t_i(i'length - 1 downto 3) = "1000000110001" else
		"0000000000100011" when t_i(i'length - 1 downto 3) = "1000000110010" else
		"0000000000100011" when t_i(i'length - 1 downto 3) = "1000000110011" else
		"0000000000100010" when t_i(i'length - 1 downto 3) = "1000000110100" else
		"0000000000100001" when t_i(i'length - 1 downto 3) = "1000000110101" else
		"0000000000100000" when t_i(i'length - 1 downto 3) = "1000000110110" else
		"0000000000100000" when t_i(i'length - 1 downto 3) = "1000000110111" else
		"0000000000011111" when t_i(i'length - 1 downto 3) = "1000000111000" else
		"0000000000011110" when t_i(i'length - 1 downto 3) = "1000000111001" else
		"0000000000011110" when t_i(i'length - 1 downto 3) = "1000000111010" else
		"0000000000011101" when t_i(i'length - 1 downto 3) = "1000000111011" else
		"0000000000011100" when t_i(i'length - 1 downto 3) = "1000000111100" else
		"0000000000011100" when t_i(i'length - 1 downto 3) = "1000000111101" else
		"0000000000011011" when t_i(i'length - 1 downto 3) = "1000000111110" else
		"0000000000011010" when t_i(i'length - 1 downto 3) = "1000000111111" else
		"0000000000011010" when t_i(i'length - 1 downto 3) = "1000001000000" else
		"0000000000011001" when t_i(i'length - 1 downto 3) = "1000001000001" else
		"0000000000011000" when t_i(i'length - 1 downto 3) = "1000001000010" else
		"0000000000011000" when t_i(i'length - 1 downto 3) = "1000001000011" else
		"0000000000010111" when t_i(i'length - 1 downto 3) = "1000001000100" else
		"0000000000010111" when t_i(i'length - 1 downto 3) = "1000001000101" else
		"0000000000010110" when t_i(i'length - 1 downto 3) = "1000001000110" else
		"0000000000010110" when t_i(i'length - 1 downto 3) = "1000001000111" else
		"0000000000010101" when t_i(i'length - 1 downto 3) = "1000001001000" else
		"0000000000010100" when t_i(i'length - 1 downto 3) = "1000001001001" else
		"0000000000010100" when t_i(i'length - 1 downto 3) = "1000001001010" else
		"0000000000010011" when t_i(i'length - 1 downto 3) = "1000001001011" else
		"0000000000010011" when t_i(i'length - 1 downto 3) = "1000001001100" else
		"0000000000010010" when t_i(i'length - 1 downto 3) = "1000001001101" else
		"0000000000010010" when t_i(i'length - 1 downto 3) = "1000001001110" else
		"0000000000010001" when t_i(i'length - 1 downto 3) = "1000001001111" else
		"0000000000010001" when t_i(i'length - 1 downto 3) = "1000001010000" else
		"0000000000010000" when t_i(i'length - 1 downto 3) = "1000001010001" else
		"0000000000010000" when t_i(i'length - 1 downto 3) = "1000001010010" else
		"0000000000010000" when t_i(i'length - 1 downto 3) = "1000001010011" else
		"0000000000001111" when t_i(i'length - 1 downto 3) = "1000001010100" else
		"0000000000001111" when t_i(i'length - 1 downto 3) = "1000001010101" else
		"0000000000001110" when t_i(i'length - 1 downto 3) = "1000001010110" else
		"0000000000001110" when t_i(i'length - 1 downto 3) = "1000001010111" else
		"0000000000001110" when t_i(i'length - 1 downto 3) = "1000001011000" else
		"0000000000001101" when t_i(i'length - 1 downto 3) = "1000001011001" else
		"0000000000001101" when t_i(i'length - 1 downto 3) = "1000001011010" else
		"0000000000001100" when t_i(i'length - 1 downto 3) = "1000001011011" else
		"0000000000001100" when t_i(i'length - 1 downto 3) = "1000001011100" else
		"0000000000001100" when t_i(i'length - 1 downto 3) = "1000001011101" else
		"0000000000001011" when t_i(i'length - 1 downto 3) = "1000001011110" else
		"0000000000001011" when t_i(i'length - 1 downto 3) = "1000001011111" else
		"0000000000001011" when t_i(i'length - 1 downto 3) = "1000001100000" else
		"0000000000001010" when t_i(i'length - 1 downto 3) = "1000001100001" else
		"0000000000001010" when t_i(i'length - 1 downto 3) = "1000001100010" else
		"0000000000001010" when t_i(i'length - 1 downto 3) = "1000001100011" else
		"0000000000001001" when t_i(i'length - 1 downto 3) = "1000001100100" else
		"0000000000001001" when t_i(i'length - 1 downto 3) = "1000001100101" else
		"0000000000001001" when t_i(i'length - 1 downto 3) = "1000001100110" else
		"0000000000001001" when t_i(i'length - 1 downto 3) = "1000001100111" else
		"0000000000001000" when t_i(i'length - 1 downto 3) = "1000001101000" else
		"0000000000001000" when t_i(i'length - 1 downto 3) = "1000001101001" else
		"0000000000001000" when t_i(i'length - 1 downto 3) = "1000001101010" else
		"0000000000001000" when t_i(i'length - 1 downto 3) = "1000001101011" else
		"0000000000000111" when t_i(i'length - 1 downto 3) = "1000001101100" else
		"0000000000000111" when t_i(i'length - 1 downto 3) = "1000001101101" else
		"0000000000000111" when t_i(i'length - 1 downto 3) = "1000001101110" else
		"0000000000000111" when t_i(i'length - 1 downto 3) = "1000001101111" else
		"0000000000000111" when t_i(i'length - 1 downto 3) = "1000001110000" else
		"0000000000000110" when t_i(i'length - 1 downto 3) = "1000001110001" else
		"0000000000000110" when t_i(i'length - 1 downto 3) = "1000001110010" else
		"0000000000000110" when t_i(i'length - 1 downto 3) = "1000001110011" else
		"0000000000000110" when t_i(i'length - 1 downto 3) = "1000001110100" else
		"0000000000000110" when t_i(i'length - 1 downto 3) = "1000001110101" else
		"0000000000000101" when t_i(i'length - 1 downto 3) = "1000001110110" else
		"0000000000000101" when t_i(i'length - 1 downto 3) = "1000001110111" else
		"0000000000000101" when t_i(i'length - 1 downto 3) = "1000001111000" else
		"0000000000000101" when t_i(i'length - 1 downto 3) = "1000001111001" else
		"0000000000000101" when t_i(i'length - 1 downto 3) = "1000001111010" else
		"0000000000000101" when t_i(i'length - 1 downto 3) = "1000001111011" else
		"0000000000000100" when t_i(i'length - 1 downto 3) = "1000001111100" else
		"0000000000000100" when t_i(i'length - 1 downto 3) = "1000001111101" else
		"0000000000000100" when t_i(i'length - 1 downto 3) = "1000001111110" else
		"0000000000000100" when t_i(i'length - 1 downto 3) = "1000001111111" else
		"0000000000000100" when t_i(i'length - 1 downto 3) = "1000010000000" else
		"0000000000000100" when t_i(i'length - 1 downto 3) = "1000010000001" else
		"0000000000000100" when t_i(i'length - 1 downto 3) = "1000010000010" else
		"0000000000000011" when t_i(i'length - 1 downto 3) = "1000010000011" else
		"0000000000000011" when t_i(i'length - 1 downto 3) = "1000010000100" else
		"0000000000000011" when t_i(i'length - 1 downto 3) = "1000010000101" else
		"0000000000000011" when t_i(i'length - 1 downto 3) = "1000010000110" else
		"0000000000000011" when t_i(i'length - 1 downto 3) = "1000010000111" else
		"0000000000000011" when t_i(i'length - 1 downto 3) = "1000010001000" else
		"0000000000000011" when t_i(i'length - 1 downto 3) = "1000010001001" else
		"0000000000000011" when t_i(i'length - 1 downto 3) = "1000010001010" else
		"0000000000000011" when t_i(i'length - 1 downto 3) = "1000010001011" else
		"0000000000000011" when t_i(i'length - 1 downto 3) = "1000010001100" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "1000010001101" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "1000010001110" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "1000010001111" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "1000010010000" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "1000010010001" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "1000010010010" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "1000010010011" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "1000010010100" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "1000010010101" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "1000010010110" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "1000010010111" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "1000010011000" else
		"0000000000000010" when t_i(i'length - 1 downto 3) = "1000010011001" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010011010" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010011011" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010011100" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010011101" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010011110" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010011111" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010100000" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010100001" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010100010" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010100011" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010100100" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010100101" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010100110" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010100111" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010101000" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010101001" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010101010" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010101011" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010101100" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010101101" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010101110" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010101111" else
		"0000000000000001" when t_i(i'length - 1 downto 3) = "1000010110000" else
		"0000000000000000";

end lut;