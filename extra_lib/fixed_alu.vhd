------------------------------------------------------------------------------
-- 							Fixed Point ALU 								--
--	This module will make the requested operation and return the result		--
--			 																--	
--																			--
-- It works as follows:														--
--																			--
--	--> OP = operation														--
--			- 000 = addition												--
--			- 001 = subtraction												--
--			- 010 = multiplication											--
--			- 011 = division												--
--			- 100 = absolute value											--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;

library work;
use work.fixed_pkg.all;

entity fixed_alu is
	generic (
		DEC_SIZE : NATURAL := 8;								-- size of the operands
		FRAC_SIZE : NATURAL := 8	
	);
	port (
		op : in std_logic_vector(2 downto 0);					-- operation to do
		A, B : in sfixed(DEC_SIZE-1 downto -FRAC_SIZE);			-- operands
		result : out sfixed(DEC_SIZE-1 downto -FRAC_SIZE)		-- result
		);
end entity;

architecture hello_world of fixed_alu is
	
begin
	
	process (op, A, B)
	variable result_t 	: sfixed(DEC_SIZE downto -FRAC_SIZE);
	variable result_tt 	: sfixed(2*DEC_SIZE-1 downto -2*FRAC_SIZE);
	begin
		
		case op is
			when "000" =>		-- add
				result_t :=  A+B;
			when "001" =>		-- sub
				result_t := A-B;
			when "010" =>		-- multiplication
				result_tt := A * B;
				result_t := result_tt(DEC_SIZE downto -FRAC_SIZE);
			when "011" =>		-- division
				result_tt := A / B;
				result_t := result_tt(DEC_SIZE-1 downto -FRAC_SIZE-1);
			when "100" =>		-- absolute value
				result_t := abs(A);
			when others =>		-- nothing (?)
		end case;
		
		result <= result_t(DEC_SIZE-1 downto -FRAC_SIZE);
		
	end process;
	
	
end hello_world;