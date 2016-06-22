------------------------------------------------------------------------------
-- 							SRam Controller 								--
--		 This module will provide an interface to talk to the memory		--
--			 Specs: Number of Words = 256kB; Wordsize = 16 bits				--	
--																			--
-- It works as follows:														--
--																			--
-- -> If you want to read a value, set write_enable to 0					--
-- -> If you want to write a value, set write_enable to 1					--
--																			--
-- OBS: Note that the writting process is transparent to the value of		--
-- 		the variable, i.e. it will keep writing the value given until the 	--
-- 		variable is set back to 0.											--



library ieee;
use ieee.std_logic_1164.all;

entity sram_controller is
    port(
		write_enable	: in std_logic;								-- write enable given from user
        wr_addr			: in std_logic_vector(17 downto 0);			-- read/write address given from user (18 bits/ 256kB)
        data_in			: in std_logic_vector(15 downto 0);			-- data in from the user (16 bits/2 bytes)
        data_out		: out std_logic_vector(15 downto 0);		-- data out to the user (16 bits/2 bytes)
        
        SRAM_ADDR		: out std_logic_vector(17 downto 0);		-- address to give to srdam to read/write data
        SRAM_DQ			: inout std_logic_vector(15 downto 0);		-- data to receive/give from sram to read/write
        SRAM_CE_N		: out std_logic;							-- chip enable (always active)
        SRAM_OE_N		: out std_logic;							-- output enable
        SRAM_WE_N		: out std_logic;							-- write enable
        SRAM_UB_N		: out std_logic;							-- high byte data mask (always active)
        SRAM_LB_N		: out std_logic								-- low byte data mask (always active)
    );
end sram_controller;


architecture beto of sram_controller is

    signal address		: std_logic_vector(17 downto 0);	-- address to read/write
    signal data			: std_logic_vector(15 downto 0);	-- data to read/write
    signal output		: std_logic_vector(15 downto 0);	-- output data
    
begin

	-- Assigns the signals to the respective values
    address <= wr_addr;
    data <= data_in when write_enable = '1' else (others => 'Z');
    output <= SRAM_DQ;

	-- Sets write enable and output enable
    SRAM_WE_N <= not write_enable;
    SRAM_OE_N <= write_enable; -- Always active ??
    
    -- Sets the unused bits
    SRAM_CE_N <= '0';
    SRAM_UB_N <= '0';
    SRAM_LB_N <= '0';
    
    -- provide address and the value to use in the writing process
    SRAM_ADDR(17 downto 0) <= wr_addr;
    SRAM_DQ(15 downto 0) <= data;
    
    -- Assigns the output to its value
    data_out <= output;

end beto;