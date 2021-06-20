----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 30.11.2020 10:51:40
-- Module Name: Implementacion fisica y test en placa
-- Design Name: Controlador para la implementacion fisica y test en placa
-- File Name: controlador.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description: Controlador que genera la señal de 12 MHz a partir de la señal de reloj 
--              de 100 MHz de la placa.
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.package_dsed.all;

entity controlador is
    Port ( clk_100Mhz : in STD_LOGIC;
           reset : in STD_LOGIC;
           --To/From the microphone
           micro_clk : out STD_LOGIC;
           micro_data : in STD_LOGIC;
           micro_LR : out STD_LOGIC;
           --To/From the mini-jack
           jack_sd : out STD_LOGIC;
           jack_pwm : out STD_LOGIC);
end controlador;

architecture Behavioral of controlador is

component clk_wiz_12Mhz is 
    Port (reset : in STD_LOGIC;
          clk_in1 : in STD_LOGIC;
          clk_out1 : out STD_LOGIC);
end component;

component audio_interface is
    Port ( clk_12megas : in STD_LOGIC;
           reset : in STD_LOGIC;
           
           --Recording ports
           --To/From the controller
           record_enable : in STD_LOGIC;
           sample_out : out STD_LOGIC_VECTOR (sample_size - 1 downto 0);
           sample_out_ready : out STD_LOGIC;
           
           --To/From the microphone
           micro_clk : out STD_LOGIC;
           micro_data : in STD_LOGIC;
           micro_LR : out STD_LOGIC;

           --Playing ports
           --To/From the controller
           play_enable : in STD_LOGIC;
           sample_in : in STD_LOGIC_VECTOR (sample_size - 1 downto 0);
           sample_request : out STD_LOGIC;
           
           --To/From the mini-jack
           jack_sd : out STD_LOGIC;
           jack_pwm : out STD_LOGIC);
end component;

--input signal declaration
signal clk_12megas: STD_LOGIC := '0';
signal record_enable, play_enable : STD_LOGIC := '1';

--output signals declaration
signal sample_out_ready, sample_request : STD_LOGIC := '0';
signal sample_out: STD_LOGIC_VECTOR (sample_size - 1 downto 0) := (others => '0');

begin

uut_wiz: clk_wiz_12Mhz 
    port map( 
    reset => reset,
    clk_in1 => clk_100Mhz,
    clk_out1 => clk_12megas);
    
uut_audio_interface : audio_interface
        PORT MAP (
        clk_12megas => clk_12megas,
        reset => reset,
        record_enable => record_enable, -- Permanece siempre activado
        sample_out => sample_out,
        sample_out_ready => sample_out_ready,
        micro_clk => micro_clk,
        micro_data => micro_data,
        micro_LR => micro_LR,
        play_enable => play_enable, -- Permanece siempre activado
        sample_in => sample_out, -- Se conecta la entrada con la salida
        sample_request => sample_request,
        jack_sd => jack_sd,
        jack_pwm => jack_pwm);

end Behavioral;
