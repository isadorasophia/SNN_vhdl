-------------------------------------------------------------------------------
-- Title      : Marvin
-- Project    : SNN
-------------------------------------------------------------------------------
-- File       : marvin.vhd
-- Author     : Isadora Sophia e Matheus Diamantino
-- Company    : Unicamp!
-- Created    : 2016-06-11
-- Last update: 2016-06-11
-- Platform   : Cyclone II
-- Standard   : VHDL'2008
-------------------------------------------------------------------------------
-- Description: Controller component, makes sure user input, feedforward and backpropagation are talking to each other properly.
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  							Description
-- 2016-06-11  0.1      Isadora Sophia e Matheus Diamantino	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

library work;
use work.fixed_pkg.all;

-- snn lib!
library snn_lib;
use snn_lib.snn_pkg.all;

-- extra lib!
library extra_lib;
use extra_lib.extra_pkg.all;

entity marvin is
	generic (
			A_SIZE_in   : natural := 2;								-- size of layers
			A_SIZE_HID  : natural := 2;
			A_SIZE_OUT  : natural := 1;
			DEC_SIZE  	: natural := 8;								-- operands size
			FRAC_SIZE 	: natural := 8
		);
	PORT (
		clear,
		run,
		to_learn,
		clock			: in  STD_LOGIC;
		input			: in  std_logic_vector (3 DOWNTO 0);
		output			: out std_logic;
		states 			: out std_logic;
		stages			: out std_logic;
		out_ff			: out sfixed(DEC_SIZE -1 downto -FRAC_SIZE);
		current_weights_hid_o 		: out fixed_array(A_SIZE_in*A_SIZE_HID + A_SIZE_HID - 1 downto 0);
		current_weights_out_o 		: out fixed_array(A_SIZE_HID*A_SIZE_OUT + A_SIZE_OUT-1 downto 0)
	);
end entity;

ARCHITECTURE rose OF marvin IS
	type states_snn is (IDLE, RUNNinG);
	type process_stage is (GET_inPUT, LEARN);
	signal current_state : states_snn := IDLE;
	signal current_stage : process_stage := GET_inPUT;
	
	signal input_update : std_logic_vector(1 downto 0);
	signal input_learning : std_logic_vector(1 downto 0);

	signal current_weights_hid 		: fixed_array(A_SIZE_in*A_SIZE_HID + A_SIZE_HID - 1 downto 0);
	signal randomized_weights_hid  : fixed_array(A_SIZE_in*A_SIZE_HID + A_SIZE_HID - 1 downto 0);
	signal delta_weights_hid 		: fixed_array(A_SIZE_in*A_SIZE_HID + A_SIZE_HID - 1 downto 0);
	signal new_weights_hid  		: fixed_array(A_SIZE_in*A_SIZE_HID + A_SIZE_HID - 1 downto 0);

	signal current_weights_out 		: fixed_array(A_SIZE_HID*A_SIZE_OUT + A_SIZE_OUT-1 downto 0);
	signal randomized_weights_out  : fixed_array(A_SIZE_HID*A_SIZE_OUT + A_SIZE_OUT-1 downto 0);
	signal delta_weights_out 		: fixed_array(A_SIZE_HID*A_SIZE_OUT + A_SIZE_OUT-1 downto 0);
	signal new_weights_out  		: fixed_array(A_SIZE_HID*A_SIZE_OUT + A_SIZE_OUT-1 downto 0);

	signal out_feedforward			: fixed_array(A_SIZE_OUT-1 downto 0);

	signal fixed_input				: fixed_array(1 downto 0);

	signal temp						: std_logic_vector(15 downto 0);

	signal neurons_h 				: fixed_array(A_SIZE_HID-1 downto 0);
	signal neurons_h_z 				: fixed_array(A_SIZE_HID-1 downto 0);
	signal neurons_o_z 				: fixed_array(A_SIZE_OUT-1 downto 0);

	signal ud_out 					: fixed_array(A_SIZE_HID*A_SIZE_OUT + A_SIZE_OUT - 1  downto 0);
	signal ud_hid 					: fixed_array(A_SIZE_in*A_SIZE_HID + A_SIZE_HID - 1  downto 0);

	signal correct_output			: fixed_array(A_SIZE_OUT-1 downto 0);
	signal correct_output_logic		: fixed_array(3 downto 0);
	
	signal change_logic				: std_logic;



BEGin

	output <= out_feedforward(0)(0) or out_feedforward(0)(-1);
	out_ff <= out_feedforward(0);
	current_weights_hid_o <= current_weights_hid;
	current_weights_out_o <= current_weights_out;

	----------------------------------------------------------------------------------
	-- Process functions
	----------------------------------------------------------------------------------

	process (input(3 downto 2), clock)
		variable current_logic : std_logic_vector(1 downto 0);
	begin
		
		if rising_edge(clock) then
		
			if input(3 downto 2) /= current_logic then
				current_logic := input(3 downto 2);
				change_logic <= '1';
			else
				change_logic <= '0';
			end if;
		end if;
		
	end process;
	
	-- update the state of the NN
	process (clear, run)
	begin
		
		if clear = '1' then
			current_state <= IDLE;

			-- debug signal
			states <= '0';
		elsif rising_edge(run) then
			current_state <= RUNNinG;

			-- debug signal
			states <= '1';
		end if;

	end process;

	-- if running, keeps the process going
	process (current_state, clock, change_logic)
	begin
		
		
		if current_state = RUNNinG then

			if rising_edge(clock) then
				
				if change_logic = '1' then
					current_weights_hid <= randomized_weights_hid;
					current_weights_out <= randomized_weights_out;
				end if;
		
				
				if current_stage = GET_inPUT then
					input_learning <= std_logic_vector(unsigned(input_learning) + 1);
					-- update input
					if to_learn = '0' then
						input_update <= input(1 downto 0);
					else
						input_update <= input_learning;
					end if;

					-- next state!
					current_stage <= LEARN;

					--debug signal
					stages <= '0';
				elsif current_stage = LEARN then

					-- weights are updated
					if to_learn = '1' then
						current_weights_hid <= new_weights_hid;
						current_weights_out <= new_weights_out;
						-- debug signal
					stages <= '1';
					end if;

					-- next state!
					current_stage <= GET_inPUT;

				end if;
					
			end if;

		elsif current_state = IDLE then
			-- randomize weights
			current_weights_hid <= randomized_weights_hid;
			current_weights_out <= randomized_weights_out;
		end if;


	end process;
	
--	process (clock, input(3 downto 2))
--	begin
--		
--		if rising_edge(clock) then
--			
--			if input (3 downto 2) = "00" then
--				correct_output(0) <= correct_output_logic(0);
--			elsif input (3 downto 2) = "01" then
--				correct_output(0) <= correct_output_logic(1);
--			elsif input (3 downto 2) = "10" then
--				correct_output(0) <= correct_output_logic(2);
--			elsif input (3 downto 2) = "11" then
--				correct_output(0) <= correct_output_logic(3);
--			end if;
--			
--		end if;
--		
--	end process;

	----------------------------------------------------------------------------------
	-- Component instantiation
	----------------------------------------------------------------------------------

	-- cast input to fixed point representation
	fixed_input(0)(0) <= input_update(0);
	fixed_input(1)(0) <= input_update(1);

	-- get the correct values for the output
	correct_output_logic(0) <= to_sfixed(1.0, DEC_SIZE-1, -FRAC_SIZE) when (input_update(0) xor input_update(1)) = '1'
						else to_sfixed(0.0, DEC_SIZE-1, -FRAC_SIZE);
	correct_output_logic(1) <= to_sfixed(1.0, DEC_SIZE-1, -FRAC_SIZE) when (input_update(0) and input_update(1)) = '1'
						else to_sfixed(0.0, DEC_SIZE-1, -FRAC_SIZE);
	correct_output_logic(2) <= to_sfixed(1.0, DEC_SIZE-1, -FRAC_SIZE) when (input_update(0) or input_update(1)) = '1'
						else to_sfixed(0.0, DEC_SIZE-1, -FRAC_SIZE);
	correct_output_logic(3) <= to_sfixed(1.0, DEC_SIZE-1, -FRAC_SIZE) when (input_update(0) xnor input_update(1)) = '1'
						else to_sfixed(0.0, DEC_SIZE-1, -FRAC_SIZE);
						
						
	with input(3 downto 2) select
		correct_output(0) <= correct_output_logic(0) when "00",
							 correct_output_logic(1) when "01",
							 correct_output_logic(2) when "10",
							 correct_output_logic(3) when others;


	-- intantiates the module that will take care of feedforward
	snn_c: snn port map (
						a => fixed_input, 
						w_hid => current_weights_hid, 
						w_out => current_weights_out, 
						output => out_feedforward(0),
						neurons_h => neurons_h,
						neurons_o_z => neurons_o_z,
						neurons_h_z => neurons_h_z
						);

	-- instantiates the module that will take care of backpropagation
	snn_learn_c: snn_learn port map (
										  input => fixed_input,
										  generated_output => out_feedforward,
										  correct_output => correct_output,
										  z => neurons_h_z,
										  a_hid => neurons_h,
										  w_out => current_weights_out,
										  ud_out => ud_out,
										  ud_hid => ud_hid
										  );

--	-- generate the LFSR component with diferent seeds
--	random_number_hid: for i in 0 to A_SIZE_in*A_SIZE_HID + A_SIZE_HID - 1 generate
--		lfsr: work.randomizer generic map (N => DEC_SIZE + FRAC_SIZE) 
--							  port map (
--							  			clk => clock,
--							  			n_seed => conv_std_logic_vector(i,16), 
--							  			random_fixed => randomized_weights_hid(i));
--	end generate;
--
--	random_number_out: for i in 0 to A_SIZE_HID*A_SIZE_OUT + A_SIZE_OUT-1 generate
--		lfsr: work.randomizer generic map (N => DEC_SIZE + FRAC_SIZE) 
--							  port map (
--							  			clk => clock,
--							  			n_seed => conv_std_logic_vector(i+32,16),
--							  			random_fixed => randomized_weights_out(i));
--	end generate;

	randomized_weights_hid(0) <= to_sfixed(0.8, DEC_SIZE-1, -FRAC_SIZE);
	randomized_weights_hid(1) <= to_sfixed(0.7, DEC_SIZE-1, -FRAC_SIZE);
	randomized_weights_hid(2) <= to_sfixed(0.8, DEC_SIZE-1, -FRAC_SIZE);
	randomized_weights_hid(3) <= to_sfixed(0.8, DEC_SIZE-1, -FRAC_SIZE);
	randomized_weights_hid(4) <= to_sfixed(0.9, DEC_SIZE-1, -FRAC_SIZE);
	randomized_weights_hid(5) <= to_sfixed(0.55, DEC_SIZE-1, -FRAC_SIZE);
	
	randomized_weights_out(0) <= to_sfixed(0.5, DEC_SIZE-1, -FRAC_SIZE);
	randomized_weights_out(1) <= to_sfixed(0.8, DEC_SIZE-1, -FRAC_SIZE);
	randomized_weights_out(2) <= to_sfixed(0.6, DEC_SIZE-1, -FRAC_SIZE);



	update_weights_hid: for i in 0 to A_SIZE_in*A_SIZE_HID + A_SIZE_HID - 1  generate
		new_weight_hid: new_weight port map (lambda => lambda,
											  old_w => current_weights_hid(i),
											  delta => ud_hid(i),
											  new_w => new_weights_hid(i)
											  );
	end generate;

	update_weights_out: for i in 0 to A_SIZE_HID*A_SIZE_OUT + A_SIZE_OUT - 1  generate
		alu_hid: new_weight port map(
									lambda => lambda,
									old_w => current_weights_out(i),
									delta => ud_out(i),
									new_w => new_weights_out(i)
									);
	end generate;
	
END ARCHITECTURE;
