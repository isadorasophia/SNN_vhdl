-- Grupo 2

-- Nome: Leonardo Villani Filho   RA: 156197
-- Nome: Thiago Silva de Farias   RA: 148077

-- Jogo: Tetris


library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- extra components lib!
library extra_lib;
use extra_lib.extra_pkg.all;

entity OutputDriver is
  port (    
		CLOCK_27         : in std_logic;
		KEY			     : in std_logic_vector (3 downto 0 );
		tela             : in std_logic_vector(179 downto 0);
		peca             : in std_logic_vector(2 downto 0);
		red, green, blue : out std_logic_vector(3 downto 0);
		hsync, vsync     : out std_logic
		);
end entity;

architecture comportamento of OutputDriver is
  
  signal rstn : std_logic;              -- reset active low para nossos
                                        -- circuitos sequenciais.

  -- Interface com a memória de vídeo do controlador

  signal we : std_logic;                        -- write enable ('1' p/ escrita)
  signal addr : integer range 0 to 12287;       -- endereco mem. vga
  signal pixel : std_logic_vector(2 downto 0);  -- valor de cor do pixel
  signal pixel_bit1 : std_logic;                 -- um bit do vetor acima
  signal pixel_bit2 : std_logic;                 -- um bit do vetor acima
  signal pixel_bit3 : std_logic;                 -- um bit do vetor acima
  signal pixel_bit4 : std_logic;                 -- um bit do vetor acima

  -- Sinais dos contadores de linehas e colunas utilizados para percorrer
  -- as posições da memória de vídeo (pixels) no momento de construir um quadro.
  
  signal line : integer range 0 to 30;  -- lineha atual
  signal col : integer range 0 to 40;  -- coluna atual
  
  CONSTANT NUM_line : INTEGER := 30;

  signal col_rstn : std_logic;          -- reset do contador de colunas
  signal col_enable : std_logic;        -- enable do contador de colunas

  signal line_rstn : std_logic;          -- reset do contador de linehas
  signal line_enable : std_logic;        -- enable do contador de linehas

  signal fim_escrita : std_logic;       -- '1' quando um quadro terminou de ser
                                        -- escrito na memória de vídeo

  -- Sinais que armazem a posição de uma bola, que deverá ser desenhada
  -- na tela de acordo com sua posição.

  signal pos_x : integer range 0 to 39;  -- coluna atual da bola
  signal pos_y : integer range 0 to 29;   -- lineha atual da bola

  signal atualiza_pos_x : std_logic;    -- se '1' = bola muda sua pos. no eixo x
  signal atualiza_pos_y : std_logic;    -- se '1' = bola muda sua pos. no eixo y

  -- Especificação dos tipos e sinais da máquina de estados de controle
  type estado_t is (show_splash, inicio, constroi_quadro, move_bola);
  signal estado: estado_t := show_splash;
  signal proximo_estado: estado_t := show_splash;

  -- Sinais para um contador utilizado para atrasar a atualização da
  -- posição da bola, a fim de evitar que a animação fique excessivamente
  -- veloz. Aqui utilizamos um contador de 0 a 270000, de modo que quando
  -- alimentado com um clock de 27MHz, ele demore 10ms para contar até o final.
  
  signal contador : integer range 0 to 2700000 - 1;  -- contador
  signal timer : std_logic;        -- vale '1' quando o contador chegar ao fim
  signal timer_rstn, timer_enable : std_logic;
  
  signal peca_h : std_logic_vector(63 downto 0);

begin  -- comportamento

	-- Aqui identificamos o tipo da peca e
	-- criamos um sinal com seu formato.
process (peca)
  begin	
     if (peca = "000") then 
		peca_h   <= "00111100" &
		            "00111100" &
		            "11000011" &
		            "11000011" &
		            "11000011" &
		            "11000011" &
		            "00111100" &
		            "00111100" ;
	elsif(peca = "001") then 
		peca_h   <= "01111110" &
		            "01111110" &
		            "00011000" &
		            "00011000" &
		            "00011000" &
		            "00011110" &
		            "00011110" &
		            "00011000" ;
	elsif(peca = "010") then 
		peca_h   <= "01000000" &
		            "10100000" &
		            "10100000" &
		            "01000000" &
		            "10100000" &
		            "10100000" &
		            "10100000" &
		            "10100000" ;
	elsif(peca = "011") then 
		peca_h   <= "01000000" &
		            "10100000" &
		            "10100000" &
		            "01000000" &
		            "10100000" &
		            "10100000" &
		            "10100000" &
		            "10100000" ;
    elsif(peca = "100") then 
		peca_h   <= "01000000" &
		            "10100000" &
		            "10100000" &
		            "01000000" &
		            "10100000" &
		            "10100000" &
		            "10100000" &
		            "10100000" ;
	elsif(peca = "101") then 
		peca_h   <= "01000000" &
		            "10100000" &
		            "10100000" &
		            "01000000" &
		            "10100000" &
		            "10100000" &
		            "10100000" &
		            "10100000" ;
	elsif(peca = "110") then 
		peca_h   <= "01000000" &
		            "10100000" &
		            "10100000" &
		            "01000000" &
		            "10100000" &
		            "10100000" &
		            "10100000" &
		            "10100000" ;
	else
		peca_h   <= "01000000" &
		            "10100000" &
		            "10100000" &
		            "01000000" &
		            "10100000" &
		            "10100000" &
		            "10100000" &
		            "10100000" ;
	end if;
end process;
  -- Aqui instanciamos o controlador de vídeo, 128 colunas por 96 linehas
  -- (aspect ratio 4:3). Os sinais que iremos utilizar para comunicar
  -- com a memória de vídeo (para alterar o brilho dos pixels) são
  -- write_clk (nosso clock), write_enable ('1' quando queremos escrever
  -- o valor de um pixel), write_ (endereço do pixel a escrever)
  -- e data_in (valor do brilho do pixel RGB, 1 bit pra cada componente de cor)
  vga_controller: vgacon port map (
    CLOCK_27       => CLOCK_27,
    rstn         => '1',
    red          => red,
    green        => green,
    blue         => blue,
    hsync        => hsync,
    vsync        => vsync,
    write_clk    => CLOCK_27,
    write_enable => we,
    write_addr   => addr,
    data_in      => pixel);

  -----------------------------------------------------------------------------
  -- Processos que controlam contadores de linehas e coluna para varrer
  -- todos os endereços da memória de vídeo, no momento de construir um quadro.
  -----------------------------------------------------------------------------

  -- purpose: Este processo conta o número da coluna atual, quando habilitado
  --          pelo sinal "col_enable".
  -- type   : sequential
  -- inputs : CLOCK_27, col_rstn
  -- outputs: col
  conta_coluna: process (CLOCK_27, col_rstn)
  begin  -- process conta_coluna
    if col_rstn = '0' then                  -- asynchronous reset (active low)
      col <= 0;
    elsif CLOCK_27'event and CLOCK_27 = '1' then  -- rising clock edge
      if col_enable = '1' then
        if col = 40 then               -- conta de 0 a 127 (128 colunas)
          col <= 0;
        else
          col <= col + 1;  
        end if;
      end if;
    end if;
  end process conta_coluna;
    
  -- purpose: Este processo conta o número da lineha atual, quando habilitado
  --          pelo sinal "line_enable".
  -- type   : sequential
  -- inputs : CLOCK_27, line_rstn
  -- outputs: line
  conta_lineha: process (CLOCK_27, line_rstn)
  begin  -- process conta_lineha
    if line_rstn = '0' then                  -- asynchronous reset (active low)
      line <= 0;
    elsif CLOCK_27'event and CLOCK_27 = '1' then  -- rising clock edge
      -- o contador de lineha só incrementa quando o contador de colunas
      -- chegou ao fim (valor 127)
      if line_enable = '1' and col = 39 then
        if line = 30 then               -- conta de 0 a 95 (96 linehas)
          line <= 0;
        else
          line <= line + 1;  
        end if;        
      end if;
    end if;
  end process conta_lineha;

  -- Este sinal é útil para informar nossa lógica de controle quando
  -- o quadro terminou de ser escrito na memória de vídeo, para que
  -- possamos avançar para o próximo estado.
  fim_escrita <= '1' when (line = 30) and (col = 40)
                 else '0'; 



  -----------------------------------------------------------------------------
  -- Brilho do pixel
  -----------------------------------------------------------------------------
  -- O brilho do pixel é branco quando os contadores de lineha e coluna, que
  -- indicam o endereço do pixel sendo escrito para o quadro atual, casam com a
  -- posição da bola (sinais pos_x e pos_y). Caso contrário,
  -- o pixel é preto.

  pixel_bit1 <= '1'   WHEN ((peca_h(0) = '1') AND (col = 17) AND (line = 7))
					   OR ((peca_h(1) = '1') AND (col = 18) AND (line = 7))
					   OR ((peca_h(2) = '1') AND (col = 19) AND (line = 7))
					   OR ((peca_h(3) = '1') AND (col = 20) AND (line = 7))
					   OR ((peca_h(4) = '1') AND (col = 21) AND (line = 7))
					   OR ((peca_h(5) = '1') AND (col = 22) AND (line = 7))
					   OR ((peca_h(6) = '1') AND (col = 23) AND (line = 7))
					   OR ((peca_h(7) = '1') AND (col = 24) AND (line = 7))
					   OR ((peca_h(8) = '1') AND (col = 17) AND (line = 8))
					   OR ((peca_h(9) = '1') AND (col = 18) AND (line = 8))
					   OR ((peca_h(10) = '1') AND (col = 19) AND (line = 8))
					   OR ((peca_h(11) = '1') AND (col = 20) AND (line = 8))
					   OR ((peca_h(12) = '1') AND (col = 21) AND (line = 8))
					   OR ((peca_h(13) = '1') AND (col = 22) AND (line = 8))
					   OR ((peca_h(14) = '1') AND (col = 23) AND (line = 8))
					   OR ((peca_h(15) = '1') AND (col = 24) AND (line = 8))
					   OR ((peca_h(16) = '1') AND (col = 17) AND (line = 9))
					   OR ((peca_h(17) = '1') AND (col = 18) AND (line = 9))
					   OR ((peca_h(18) = '1') AND (col = 19) AND (line = 9))
					   OR ((peca_h(19) = '1') AND (col = 20) AND (line = 9))
					   OR ((peca_h(20) = '1') AND (col = 21) AND (line = 9))
					   OR ((peca_h(21) = '1') AND (col = 22) AND (line = 9))
					   OR ((peca_h(22) = '1') AND (col = 23) AND (line = 9))
					   OR ((peca_h(23) = '1') AND (col = 24) AND (line = 9))
					   OR ((peca_h(24) = '1') AND (col = 17) AND (line = 10))
					   OR ((peca_h(25) = '1') AND (col = 18) AND (line = 10))
					   OR ((peca_h(26) = '1') AND (col = 19) AND (line = 10))
					   OR ((peca_h(27) = '1') AND (col = 20) AND (line = 10))
					   OR ((peca_h(28) = '1') AND (col = 21) AND (line = 10))
					   OR ((peca_h(29) = '1') AND (col = 22) AND (line = 10))
					   OR ((peca_h(30) = '1') AND (col = 23) AND (line = 10))
					   OR ((peca_h(31) = '1') AND (col = 24) AND (line = 10))
					   
					   OR ((peca_h(32) = '1') AND (col = 17) AND (line = 11))
					   OR ((peca_h(33) = '1') AND (col = 18) AND (line = 11))
					   OR ((peca_h(34) = '1') AND (col = 19) AND (line = 11))
					   OR ((peca_h(35) = '1') AND (col = 20) AND (line = 11))
					   OR ((peca_h(36) = '1') AND (col = 21) AND (line = 11))
					   OR ((peca_h(37) = '1') AND (col = 22) AND (line = 11))
					   OR ((peca_h(38) = '1') AND (col = 23) AND (line = 11))
					   OR ((peca_h(39) = '1') AND (col = 24) AND (line = 11))
					   
					   OR ((peca_h(40) = '1') AND (col = 17) AND (line = 12))
					   OR ((peca_h(41) = '1') AND (col = 18) AND (line = 12))
					   OR ((peca_h(42) = '1') AND (col = 19) AND (line = 12))
					   OR ((peca_h(43) = '1') AND (col = 20) AND (line = 12))
					   OR ((peca_h(44) = '1') AND (col = 21) AND (line = 12))
					   OR ((peca_h(45) = '1') AND (col = 22) AND (line = 12))
					   OR ((peca_h(46) = '1') AND (col = 23) AND (line = 12))
					   OR ((peca_h(47) = '1') AND (col = 24) AND (line = 12))
					   
					   OR ((peca_h(48) = '1') AND (col = 17) AND (line = 13))
					   OR ((peca_h(49) = '1') AND (col = 18) AND (line = 13))
					   OR ((peca_h(50) = '1') AND (col = 19) AND (line = 13))
					   OR ((peca_h(51) = '1') AND (col = 20) AND (line = 13))
					   OR ((peca_h(52) = '1') AND (col = 21) AND (line = 13))
					   OR ((peca_h(53) = '1') AND (col = 22) AND (line = 13))
					   OR ((peca_h(54) = '1') AND (col = 23) AND (line = 13))
					   OR ((peca_h(55) = '1') AND (col = 24) AND (line = 13))
					   
					   OR ((peca_h(56) = '1') AND (col = 17) AND (line = 14))
					   OR ((peca_h(57) = '1') AND (col = 18) AND (line = 14))
					   OR ((peca_h(58) = '1') AND (col = 19) AND (line = 14))
					   OR ((peca_h(59) = '1') AND (col = 20) AND (line = 14))
					   OR ((peca_h(60) = '1') AND (col = 21) AND (line = 14))
					   OR ((peca_h(61) = '1') AND (col = 22) AND (line = 14))
					   OR ((peca_h(62) = '1') AND (col = 23) AND (line = 14))
					   OR ((peca_h(63) = '1') AND (col = 24) AND (line = 14))
					   
					   ELSE '0';
					   
pixel_bit2 <= '1'   WHEN ((tela(0) = '1') AND (col = 5) AND (line = 6))
					   OR ((tela(1) = '1') AND (col = 6) AND (line = 6))
					   OR ((tela(2) = '1') AND (col = 7) AND (line = 6))
					   OR ((tela(3) = '1') AND (col = 8) AND (line = 6))
					   OR ((tela(4) = '1') AND (col = 9) AND (line = 6))
					   OR ((tela(5) = '1') AND (col = 10) AND (line = 6))
					   OR ((tela(6) = '1') AND (col = 11) AND (line = 6))
					   OR ((tela(7) = '1') AND (col = 12) AND (line = 6))
					   OR ((tela(8) = '1') AND (col = 13) AND (line = 6))
					   OR ((tela(9) = '1') AND (col = 14) AND (line = 6))
					   OR ((tela(10) = '1') AND (col = 5) AND (line = 7))
					   OR ((tela(11) = '1') AND (col = 6) AND (line = 7))
					   OR ((tela(12) = '1') AND (col = 7) AND (line = 7))
					   OR ((tela(13) = '1') AND (col = 8) AND (line = 7))
					   OR ((tela(14) = '1') AND (col = 9) AND (line = 7))
					   OR ((tela(15) = '1') AND (col = 10) AND (line = 7))
					   OR ((tela(16) = '1') AND (col = 11) AND (line = 7))
					   OR ((tela(17) = '1') AND (col = 12) AND (line = 7))
					   OR ((tela(18) = '1') AND (col = 13) AND (line = 7))
					   OR ((tela(19) = '1') AND (col = 14) AND (line = 7))
					   OR ((tela(20) = '1') AND (col = 5) AND (line = 8))
					   OR ((tela(21) = '1') AND (col = 6) AND (line = 8))
					   OR ((tela(22) = '1') AND (col = 7) AND (line = 8))
					   OR ((tela(23) = '1') AND (col = 8) AND (line = 8))
					   OR ((tela(24) = '1') AND (col = 9) AND (line = 8))
					   OR ((tela(25) = '1') AND (col = 10) AND (line = 8))
					   OR ((tela(26) = '1') AND (col = 11) AND (line = 8))
					   OR ((tela(27) = '1') AND (col = 12) AND (line = 8))
					   OR ((tela(28) = '1') AND (col = 13) AND (line = 8))
					   OR ((tela(29) = '1') AND (col = 14) AND (line = 8))
					   OR ((tela(30) = '1') AND (col = 5) AND (line = 9))
					   OR ((tela(31) = '1') AND (col = 6) AND (line = 9))
					   OR ((tela(32) = '1') AND (col = 7) AND (line = 9))
					   OR ((tela(33) = '1') AND (col = 8) AND (line = 9))
					   OR ((tela(34) = '1') AND (col = 9) AND (line = 9))
					   OR ((tela(35) = '1') AND (col = 10) AND (line = 9))
					   OR ((tela(36) = '1') AND (col = 11) AND (line = 9))
					   OR ((tela(37) = '1') AND (col = 12) AND (line = 9))
					   OR ((tela(38) = '1') AND (col = 13) AND (line = 9))
					   OR ((tela(39) = '1') AND (col = 14) AND (line = 9))
					   OR ((tela(40) = '1') AND (col = 5) AND (line = 10))
					   OR ((tela(41) = '1') AND (col = 6) AND (line = 10))
					   OR ((tela(42) = '1') AND (col = 7) AND (line = 10))
					   OR ((tela(43) = '1') AND (col = 8) AND (line = 10))
					   OR ((tela(44) = '1') AND (col = 9) AND (line = 10))
					   OR ((tela(45) = '1') AND (col = 10) AND (line = 10))
					   OR ((tela(46) = '1') AND (col = 11) AND (line = 10))
					   OR ((tela(47) = '1') AND (col = 12) AND (line = 10))
					   OR ((tela(48) = '1') AND (col = 13) AND (line = 10))
					   OR ((tela(49) = '1') AND (col = 14) AND (line = 10))
					   OR ((tela(50) = '1') AND (col = 5) AND (line = 11))
					   OR ((tela(51) = '1') AND (col = 6) AND (line = 11))
					   OR ((tela(52) = '1') AND (col = 7) AND (line = 11))
					   OR ((tela(53) = '1') AND (col = 8) AND (line = 11))
					   OR ((tela(54) = '1') AND (col = 9) AND (line = 11))
					   OR ((tela(55) = '1') AND (col = 10) AND (line = 11))
					   OR ((tela(56) = '1') AND (col = 11) AND (line = 11))
					   OR ((tela(57) = '1') AND (col = 12) AND (line = 11))
					   OR ((tela(58) = '1') AND (col = 13) AND (line = 11))
					   OR ((tela(59) = '1') AND (col = 14) AND (line = 11))
					   OR ((tela(60) = '1') AND (col = 5) AND (line = 12))
					   OR ((tela(61) = '1') AND (col = 6) AND (line = 12))
					   OR ((tela(62) = '1') AND (col = 7) AND (line = 12))
					   OR ((tela(63) = '1') AND (col = 8) AND (line = 12))
					   OR ((tela(64) = '1') AND (col = 9) AND (line = 12))
					   OR ((tela(65) = '1') AND (col = 10) AND (line = 12))
					   OR ((tela(66) = '1') AND (col = 11) AND (line = 12))
					   OR ((tela(67) = '1') AND (col = 12) AND (line = 12))
					   OR ((tela(68) = '1') AND (col = 13) AND (line = 12))
					   OR ((tela(69) = '1') AND (col = 14) AND (line = 12))
					   OR ((tela(70) = '1') AND (col = 5) AND (line = 13))
					   OR ((tela(71) = '1') AND (col = 6) AND (line = 13))
					   OR ((tela(72) = '1') AND (col = 7) AND (line = 13))
					   OR ((tela(73) = '1') AND (col = 8) AND (line = 13))
					   OR ((tela(74) = '1') AND (col = 9) AND (line = 13))
					   OR ((tela(75) = '1') AND (col = 10) AND (line = 13))
					   OR ((tela(76) = '1') AND (col = 11) AND (line = 13))
					   OR ((tela(77) = '1') AND (col = 12) AND (line = 13))
					   OR ((tela(78) = '1') AND (col = 13) AND (line = 13))
					   OR ((tela(79) = '1') AND (col = 14) AND (line = 13))
					   OR ((tela(80) = '1') AND (col = 5) AND (line = 14))
					   OR ((tela(81) = '1') AND (col = 6) AND (line = 14))
					   OR ((tela(82) = '1') AND (col = 7) AND (line = 14))
					   OR ((tela(83) = '1') AND (col = 8) AND (line = 14))
					   OR ((tela(84) = '1') AND (col = 9) AND (line = 14))
					   OR ((tela(85) = '1') AND (col = 10) AND (line = 14))
					   OR ((tela(86) = '1') AND (col = 11) AND (line = 14))
					   OR ((tela(87) = '1') AND (col = 12) AND (line = 14))
					   OR ((tela(88) = '1') AND (col = 13) AND (line = 14))
					   OR ((tela(89) = '1') AND (col = 14) AND (line = 14))
					   OR ((tela(90) = '1') AND (col = 5) AND (line = 15))
					   OR ((tela(91) = '1') AND (col = 6) AND (line = 15))
					   OR ((tela(92) = '1') AND (col = 7) AND (line = 15))
					   OR ((tela(93) = '1') AND (col = 8) AND (line = 15))
					   OR ((tela(94) = '1') AND (col = 9) AND (line = 15))
					   OR ((tela(95) = '1') AND (col = 10) AND (line = 15))
					   OR ((tela(96) = '1') AND (col = 11) AND (line = 15))
					   OR ((tela(97) = '1') AND (col = 12) AND (line = 15))
					   OR ((tela(98) = '1') AND (col = 13) AND (line = 15))
					   OR ((tela(99) = '1') AND (col = 14) AND (line = 15))
					   OR ((tela(100) = '1') AND (col = 5) AND (line = 16))
					   OR ((tela(101) = '1') AND (col = 6) AND (line = 16))
					   OR ((tela(102) = '1') AND (col = 7) AND (line = 16))
					   OR ((tela(103) = '1') AND (col = 8) AND (line = 16))
					   OR ((tela(104) = '1') AND (col = 9) AND (line = 16))
					   OR ((tela(105) = '1') AND (col = 10) AND (line = 16))
					   OR ((tela(106) = '1') AND (col = 11) AND (line = 16))
					   OR ((tela(107) = '1') AND (col = 12) AND (line = 16))
					   OR ((tela(108) = '1') AND (col = 13) AND (line = 16))
					   OR ((tela(109) = '1') AND (col = 14) AND (line = 16))
					   OR ((tela(110) = '1') AND (col = 5) AND (line = 17))
					   OR ((tela(111) = '1') AND (col = 6) AND (line = 17))
					   OR ((tela(112) = '1') AND (col = 7) AND (line = 17))
					   OR ((tela(113) = '1') AND (col = 8) AND (line = 17))
					   OR ((tela(114) = '1') AND (col = 9) AND (line = 17))
					   OR ((tela(115) = '1') AND (col = 10) AND (line = 17))
					   OR ((tela(116) = '1') AND (col = 11) AND (line = 17))
					   OR ((tela(117) = '1') AND (col = 12) AND (line = 17))
					   OR ((tela(118) = '1') AND (col = 13) AND (line = 17))
					   OR ((tela(119) = '1') AND (col = 14) AND (line = 17))
					   OR ((tela(120) = '1') AND (col = 5) AND (line = 18))
					   OR ((tela(121) = '1') AND (col = 6) AND (line = 18))
					   OR ((tela(122) = '1') AND (col = 7) AND (line = 18))
					   OR ((tela(123) = '1') AND (col = 8) AND (line = 18))
					   OR ((tela(124) = '1') AND (col = 9) AND (line = 18))
					   OR ((tela(125) = '1') AND (col = 10) AND (line = 18))
					   OR ((tela(126) = '1') AND (col = 11) AND (line = 18))
					   OR ((tela(127) = '1') AND (col = 12) AND (line = 18))
					   OR ((tela(128) = '1') AND (col = 13) AND (line = 18))
					   OR ((tela(129) = '1') AND (col = 14) AND (line = 18))
					   OR ((tela(130) = '1') AND (col = 5) AND (line = 19))
					   OR ((tela(131) = '1') AND (col = 6) AND (line = 19))
					   OR ((tela(132) = '1') AND (col = 7) AND (line = 19))
					   OR ((tela(133) = '1') AND (col = 8) AND (line = 19))
					   OR ((tela(134) = '1') AND (col = 9) AND (line = 19))
					   OR ((tela(135) = '1') AND (col = 10) AND (line = 19))
					   OR ((tela(136) = '1') AND (col = 11) AND (line = 19))
					   OR ((tela(137) = '1') AND (col = 12) AND (line = 19))
					   OR ((tela(138) = '1') AND (col = 13) AND (line = 19))
					   OR ((tela(139) = '1') AND (col = 14) AND (line = 19))
					   OR ((tela(140) = '1') AND (col = 5) AND (line = 20))
					   OR ((tela(141) = '1') AND (col = 6) AND (line = 20))
					   OR ((tela(142) = '1') AND (col = 7) AND (line = 20))
					   OR ((tela(143) = '1') AND (col = 8) AND (line = 20))
					   OR ((tela(144) = '1') AND (col = 9) AND (line = 20))
					   OR ((tela(145) = '1') AND (col = 10) AND (line = 20))
					   OR ((tela(146) = '1') AND (col = 11) AND (line = 20))
					   OR ((tela(147) = '1') AND (col = 12) AND (line = 20))
					   OR ((tela(148) = '1') AND (col = 13) AND (line = 20))
					   OR ((tela(149) = '1') AND (col = 14) AND (line = 20))
					   OR ((tela(150) = '1') AND (col = 5) AND (line = 21))
					   OR ((tela(151) = '1') AND (col = 6) AND (line = 21))
					   OR ((tela(152) = '1') AND (col = 7) AND (line = 21))
					   OR ((tela(153) = '1') AND (col = 8) AND (line = 21))
					   OR ((tela(154) = '1') AND (col = 9) AND (line = 21))
					   OR ((tela(155) = '1') AND (col = 10) AND (line = 21))
					   OR ((tela(156) = '1') AND (col = 11) AND (line = 21))
					   OR ((tela(157) = '1') AND (col = 12) AND (line = 21))
					   OR ((tela(158) = '1') AND (col = 13) AND (line = 21))
					   OR ((tela(159) = '1') AND (col = 14) AND (line = 21))
					   OR ((tela(160) = '1') AND (col = 5) AND (line = 22))
					   OR ((tela(161) = '1') AND (col = 6) AND (line = 22))
					   OR ((tela(162) = '1') AND (col = 7) AND (line = 22))
					   OR ((tela(163) = '1') AND (col = 8) AND (line = 22))
					   OR ((tela(164) = '1') AND (col = 9) AND (line = 22))
					   OR ((tela(165) = '1') AND (col = 10) AND (line = 22))
					   OR ((tela(166) = '1') AND (col = 11) AND (line = 22))
					   OR ((tela(167) = '1') AND (col = 12) AND (line = 22))
					   OR ((tela(168) = '1') AND (col = 13) AND (line = 22))
					   OR ((tela(169) = '1') AND (col = 14) AND (line = 22))
					   OR ((tela(170) = '1') AND (col = 5) AND (line = 23))
					   OR ((tela(171) = '1') AND (col = 6) AND (line = 23))
					   OR ((tela(172) = '1') AND (col = 7) AND (line = 23))
					   OR ((tela(173) = '1') AND (col = 8) AND (line = 23))
					   OR ((tela(174) = '1') AND (col = 9) AND (line = 23))
					   OR ((tela(175) = '1') AND (col = 10) AND (line = 23))
					   OR ((tela(176) = '1') AND (col = 11) AND (line = 23))
					   OR ((tela(177) = '1') AND (col = 12) AND (line = 23))
					   OR ((tela(178) = '1') AND (col = 13) AND (line = 23))
					   OR ((tela(179) = '1') AND (col = 14) AND (line = 23))
					   ELSE '0';
					   
	pixel_bit3 <= '1'   WHEN ((col = 5) AND (line = 6))
					   OR ((col = 6) AND (line = 6))
					   OR ((col = 7) AND (line = 6))
					   OR ((col = 8) AND (line = 6))
					   OR ((col = 9) AND (line = 6))
					   OR ((col = 10) AND (line = 6))
					   OR ((col = 11) AND (line = 6))
					   OR ((col = 12) AND (line = 6))
					   OR ((col = 13) AND (line = 6))
					   OR ((col = 14) AND (line = 6))
					   OR ((col = 5) AND (line = 7))
					   OR ((col = 6) AND (line = 7))
					   OR ((col = 7) AND (line = 7))
					   OR ((col = 8) AND (line = 7))
					   OR ((col = 9) AND (line = 7))
					   OR ((col = 10) AND (line = 7))
					   OR ((col = 11) AND (line = 7))
					   OR ((col = 12) AND (line = 7))
					   OR ((col = 13) AND (line = 7))
					   OR ((col = 14) AND (line = 7))
					   OR ((col = 5) AND (line = 8))
					   OR ((col = 6) AND (line = 8))
					   OR ((col = 7) AND (line = 8))
					   OR ((col = 8) AND (line = 8))
					   OR ((col = 9) AND (line = 8))
					   OR ((col = 10) AND (line = 8))
					   OR ((col = 11) AND (line = 8))
					   OR ((col = 12) AND (line = 8))
					   OR ((col = 13) AND (line = 8))
					   OR ((col = 14) AND (line = 8))
					   OR ((col = 5) AND (line = 9))
					   OR ((col = 6) AND (line = 9))
					   OR ((col = 7) AND (line = 9))
					   OR ((col = 8) AND (line = 9))
					   OR ((col = 9) AND (line = 9))
					   OR ((col = 10) AND (line = 9))
					   OR ((col = 11) AND (line = 9))
					   OR ((col = 12) AND (line = 9))
					   OR ((col = 13) AND (line = 9))
					   OR ((col = 14) AND (line = 9))
					   OR ((col = 5) AND (line = 10))
					   OR ((col = 6) AND (line = 10))
					   OR ((col = 7) AND (line = 10))
					   OR ((col = 8) AND (line = 10))
					   OR ((col = 9) AND (line = 10))
					   OR ((col = 10) AND (line = 10))
					   OR ((col = 11) AND (line = 10))
					   OR ((col = 12) AND (line = 10))
					   OR ((col = 13) AND (line = 10))
					   OR ((col = 14) AND (line = 10))
					   OR ((col = 5) AND (line = 11))
					   OR ((col = 6) AND (line = 11))
					   OR ((col = 7) AND (line = 11))
					   OR ((col = 8) AND (line = 11))
					   OR ((col = 9) AND (line = 11))
					   OR ((col = 10) AND (line = 11))
					   OR ((col = 11) AND (line = 11))
					   OR ((col = 12) AND (line = 11))
					   OR ((col = 13) AND (line = 11))
					   OR ((col = 14) AND (line = 11))
					   OR ((col = 5) AND (line = 12))
					   OR ((col = 6) AND (line = 12))
					   OR ((col = 7) AND (line = 12))
					   OR ((col = 8) AND (line = 12))
					   OR ((col = 9) AND (line = 12))
					   OR ((col = 10) AND (line = 12))
					   OR ((col = 11) AND (line = 12))
					   OR ((col = 12) AND (line = 12))
					   OR ((col = 13) AND (line = 12))
					   OR ((col = 14) AND (line = 12))
					   OR ((col = 5) AND (line = 13))
					   OR ((col = 6) AND (line = 13))
					   OR ((col = 7) AND (line = 13))
					   OR ((col = 8) AND (line = 13))
					   OR ((col = 9) AND (line = 13))
					   OR ((col = 10) AND (line = 13))
					   OR ((col = 11) AND (line = 13))
					   OR ((col = 12) AND (line = 13))
					   OR ((col = 13) AND (line = 13))
					   OR ((col = 14) AND (line = 13))
					   OR ((col = 5) AND (line = 14))
					   OR ((col = 6) AND (line = 14))
					   OR ((col = 7) AND (line = 14))
					   OR ((col = 8) AND (line = 14))
					   OR ((col = 9) AND (line = 14))
					   OR ((col = 10) AND (line = 14))
					   OR ((col = 11) AND (line = 14))
					   OR ((col = 12) AND (line = 14))
					   OR ((col = 13) AND (line = 14))
					   OR ((col = 14) AND (line = 14))
					   OR ((col = 5) AND (line = 15))
					   OR ((col = 6) AND (line = 15))
					   OR ((col = 7) AND (line = 15))
					   OR ((col = 8) AND (line = 15))
					   OR ((col = 9) AND (line = 15))
					   OR ((col = 10) AND (line = 15))
					   OR ((col = 11) AND (line = 15))
					   OR ((col = 12) AND (line = 15))
					   OR ((col = 13) AND (line = 15))
					   OR ((col = 14) AND (line = 15))
					   OR ((col = 5) AND (line = 16))
					   OR ((col = 6) AND (line = 16))
					   OR ((col = 7) AND (line = 16))
					   OR ((col = 8) AND (line = 16))
					   OR ((col = 9) AND (line = 16))
					   OR ((col = 10) AND (line = 16))
					   OR ((col = 11) AND (line = 16))
					   OR ((col = 12) AND (line = 16))
					   OR ((col = 13) AND (line = 16))
					   OR ((col = 14) AND (line = 16))
					   OR ((col = 5) AND (line = 17))
					   OR ((col = 6) AND (line = 17))
					   OR ((col = 7) AND (line = 17))
					   OR ((col = 8) AND (line = 17))
					   OR ((col = 9) AND (line = 17))
					   OR ((col = 10) AND (line = 17))
					   OR ((col = 11) AND (line = 17))
					   OR ((col = 12) AND (line = 17))
					   OR ((col = 13) AND (line = 17))
					   OR ((col = 14) AND (line = 17))
					   OR ((col = 5) AND (line = 18))
					   OR ((col = 6) AND (line = 18))
					   OR ((col = 7) AND (line = 18))
					   OR ((col = 8) AND (line = 18))
					   OR ((col = 9) AND (line = 18))
					   OR ((col = 10) AND (line = 18))
					   OR ((col = 11) AND (line = 18))
					   OR ((col = 12) AND (line = 18))
					   OR ((col = 13) AND (line = 18))
					   OR ((col = 14) AND (line = 18))
					   OR ((col = 5) AND (line = 19))
					   OR ((col = 6) AND (line = 19))
					   OR ((col = 7) AND (line = 19))
					   OR ((col = 8) AND (line = 19))
					   OR ((col = 9) AND (line = 19))
					   OR ((col = 10) AND (line = 19))
					   OR ((col = 11) AND (line = 19))
					   OR ((col = 12) AND (line = 19))
					   OR ((col = 13) AND (line = 19))
					   OR ((col = 14) AND (line = 19))
					   OR ((col = 5) AND (line = 20))
					   OR ((col = 6) AND (line = 20))
					   OR ((col = 7) AND (line = 20))
					   OR ((col = 8) AND (line = 20))
					   OR ((col = 9) AND (line = 20))
					   OR ((col = 10) AND (line = 20))
					   OR ((col = 11) AND (line = 20))
					   OR ((col = 12) AND (line = 20))
					   OR ((col = 13) AND (line = 20))
					   OR ((col = 14) AND (line = 20))
					   OR ((col = 5) AND (line = 21))
					   OR ((col = 6) AND (line = 21))
					   OR ((col = 7) AND (line = 21))
					   OR ((col = 8) AND (line = 21))
					   OR ((col = 9) AND (line = 21))
					   OR ((col = 10) AND (line = 21))
					   OR ((col = 11) AND (line = 21))
					   OR ((col = 12) AND (line = 21))
					   OR ((col = 13) AND (line = 21))
					   OR ((col = 14) AND (line = 21))
					   OR ((col = 5) AND (line = 22))
					   OR ((col = 6) AND (line = 22))
					   OR ((col = 7) AND (line = 22))
					   OR ((col = 8) AND (line = 22))
					   OR ((col = 9) AND (line = 22))
					   OR ((col = 10) AND (line = 22))
					   OR ((col = 11) AND (line = 22))
					   OR ((col = 12) AND (line = 22))
					   OR ((col = 13) AND (line = 22))
					   OR ((col = 14) AND (line = 22))
					   OR ((col = 5) AND (line = 23))
					   OR ((col = 6) AND (line = 23))
					   OR ((col = 7) AND (line = 23))
					   OR ((col = 8) AND (line = 23))
					   OR ((col = 9) AND (line = 23))
					   OR ((col = 10) AND (line = 23))
					   OR ((col = 11) AND (line = 23))
					   OR ((col = 12) AND (line = 23))
					   OR ((col = 13) AND (line = 23))
					   OR ((col = 14) AND (line = 23))
					   ELSE '0';
	
	pixel_bit4 <= '1'   					 WHEN ((col = 17) AND (line = 7))
					   OR ((col = 18) AND (line = 7))
					   OR ((col = 19) AND (line = 7))
					   OR ((col = 20) AND (line = 7))
					   OR ((col = 21) AND (line = 7))
					   OR ((col = 22) AND (line = 7))
					   OR ((col = 23) AND (line = 7))
					   OR ((col = 24) AND (line = 7))
					   OR ((col = 17) AND (line = 8))
					   OR ((col = 18) AND (line = 8))
					   OR ((col = 19) AND (line = 8))
					   OR ((col = 20) AND (line = 8))
					   OR ((col = 21) AND (line = 8))
					   OR ((col = 22) AND (line = 8))
					   OR ((col = 23) AND (line = 8))
					   OR ((col = 24) AND (line = 8))
					   OR ((col = 17) AND (line = 9))
					   OR ((col = 18) AND (line = 9))
					   OR ((col = 19) AND (line = 9))
					   OR ((col = 20) AND (line = 9))
					   OR ((col = 21) AND (line = 9))
					   OR ((col = 22) AND (line = 9))
					   OR ((col = 23) AND (line = 9))
					   OR ((col = 24) AND (line = 9))
					   OR ((col = 17) AND (line = 10))
					   OR ((col = 18) AND (line = 10))
					   OR ((col = 19) AND (line = 10))
					   OR ((col = 20) AND (line = 10))
					   OR ((col = 21) AND (line = 10))
					   OR ((col = 22) AND (line = 10))
					   OR ((col = 23) AND (line = 10))
					   OR ((col = 24) AND (line = 10))
					   
					   OR ((col = 17) AND (line = 11))
					   OR ((col = 18) AND (line = 11))
					   OR ((col = 19) AND (line = 11))
					   OR ((col = 20) AND (line = 11))
					   OR ((col = 21) AND (line = 11))
					   OR ((col = 22) AND (line = 11))
					   OR ((col = 23) AND (line = 11))
					   OR ((col = 24) AND (line = 11))
					   
					   OR ((col = 17) AND (line = 12))
					   OR ((col = 18) AND (line = 12))
					   OR ((col = 19) AND (line = 12))
					   OR ((col = 20) AND (line = 12))
					   OR ((col = 21) AND (line = 12))
					   OR ((col = 22) AND (line = 12))
					   OR ((col = 23) AND (line = 12))
					   OR ((col = 24) AND (line = 12))
					   
					   OR ((col = 17) AND (line = 13))
					   OR ((col = 18) AND (line = 13))
					   OR ((col = 19) AND (line = 13))
					   OR ((col = 20) AND (line = 13))
					   OR ((col = 21) AND (line = 13))
					   OR ((col = 22) AND (line = 13))
					   OR ((col = 23) AND (line = 13))
					   OR ((col = 24) AND (line = 13))
					   
					   OR ((col = 17) AND (line = 14))
					   OR ((col = 18) AND (line = 14))
					   OR ((col = 19) AND (line = 14))
					   OR ((col = 20) AND (line = 14))
					   OR ((col = 21) AND (line = 14))
					   OR ((col = 22) AND (line = 14))
					   OR ((col = 23) AND (line = 14))
					   OR ((col = 24) AND (line = 14))
					   
					   ELSE '0';


		
  pixel <= (others => pixel_bit1 or pixel_bit2) when (pixel_bit4 nor pixel_bit3) = '1'
					  else "011" when (pixel_bit3 = '1') and ( pixel_bit2 = '1')
					  else "000" when (pixel_bit3 = '1') and ( pixel_bit2 = '0')
					  else "110" when (pixel_bit4 = '1') and ( pixel_bit1 = '1')
					  else "000" when (pixel_bit4 = '1') and ( pixel_bit1 = '0');
  
  -- O endereço de memória pode ser construído com essa fórmula simples,
  -- a partir da lineha e coluna atual
  addr  <= col + (40 * line);

  -----------------------------------------------------------------------------
  -- Processos que definem a FSM (finite state machine), nossa máquina
  -- de estados de controle.
  -----------------------------------------------------------------------------

  -- purpose: Esta é a lógica combinacional que calcula sinais de saída a partir
  --          do estado atual e alguns sinais de entrada (Máquina de Mealy).
  -- type   : combinational
  -- inputs : estado, fim_escrita, timer
  -- outputs: proximo_estado, atualiza_pos_x, atualiza_pos_y, line_rstn,
  --          line_enable, col_rstn, col_enable, we, timer_enable, timer_rstn
  logica_mealy: process (estado, fim_escrita, timer)
  begin  -- process logica_mealy
    case estado is
      when inicio         => if timer = '1' then              
                               proximo_estado <= constroi_quadro;
                             else
                               proximo_estado <= inicio;
                             end if;
                             line_rstn      <= '0';  --  é active low!
                             line_enable    <= '0';
                             col_rstn       <= '0';  -- reset é active low!
                             col_enable     <= '0';
                             we             <= '0';
                             timer_rstn     <= '1';  -- reset é active low!
                             timer_enable   <= '1';

      when constroi_quadro=> if fim_escrita = '1' then
                               proximo_estado <= move_bola;
                             else
                               proximo_estado <= constroi_quadro;
                             end if;
                             line_rstn      <= '1';
                             line_enable    <= '1';
                             col_rstn       <= '1';
                             col_enable     <= '1';
                             we             <= '1';
                             timer_rstn     <= '0'; 
                             timer_enable   <= '0';

      when move_bola      => proximo_estado <= inicio;
                             line_rstn      <= '1';
                             line_enable    <= '0';
                             col_rstn       <= '1';
                             col_enable     <= '0';
                             we             <= '0';
                             timer_rstn     <= '0'; 
                             timer_enable   <= '0';

      when others         => proximo_estado <= inicio;
                             line_rstn      <= '1';
                             line_enable    <= '0';
                             col_rstn       <= '1';
                             col_enable     <= '0';
                             we             <= '0';
                             timer_rstn     <= '1'; 
                             timer_enable   <= '0';
      
    end case;
  end process logica_mealy;
  
  -- purpose: Avança a FSM para o próximo estado
  -- type   : sequential
  -- inputs : CLOCK_27, rstn, proximo_estado
  -- outputs: estado
  seq_fsm: process (CLOCK_27, rstn)
  begin  -- process seq_fsm
    if rstn = '0' then                  -- asynchronous reset (active low)
      estado <= inicio;
    elsif CLOCK_27'event and CLOCK_27 = '1' then  -- rising clock edge
      estado <= proximo_estado;
    end if;
  end process seq_fsm;

  -----------------------------------------------------------------------------
  -- Processos do contador utilizado para atrasar a animação (evitar
  -- que a atualização de quadros fique excessivamente veloz).
  -----------------------------------------------------------------------------
  -- purpose: Incrementa o contador a cada ciclo de clock
  -- type   : sequential
  -- inputs : CLOCK_27, timer_rstn
  -- outputs: contador, timer
  p_contador: process (CLOCK_27, timer_rstn)
  begin  -- process p_contador
    if timer_rstn = '0' then            -- asynchronous reset (active low)
      contador <= 0;
    elsif CLOCK_27'event and CLOCK_27 = '1' then  -- rising clock edge
      if timer_enable = '1' then       
        if contador = 27000 - 1 then
          contador <= 0;
        else
          contador <=  contador + 1;        
        end if;
      end if;
    end if;
  end process p_contador;

  -- purpose: Calcula o sinal "timer" que indica quando o contador chegou ao
  --          final
  -- type   : combinational
  -- inputs : contador
  -- outputs: timer
  p_timer: process (contador)
  begin  -- process p_timer
    if contador = 27000 - 1 then
      timer <= '1';
    else
      timer <= '0';
    end if;
  end process p_timer;

  -----------------------------------------------------------------------------
  -- Processos que sincronizam sinais assíncronos, de preferência com mais
  -- de 1 flipflop, para evitar metaestabilidade.
  -----------------------------------------------------------------------------
  
  -- purpose: Aqui sincronizamos nosso sinal de reset vindo do botão da DE1
  -- type   : sequential
  -- inputs : CLOCK_27
  -- outputs: rstn
  build_rstn: process (CLOCK_27)
    variable temp : std_logic;          -- flipflop intermediario
  begin  -- process build_rstn
    if CLOCK_27'event and CLOCK_27 = '1' then  -- rising clock edge
      rstn <= temp;
      temp := KEY(0);      
    end if;
  end process build_rstn;

  
end comportamento;